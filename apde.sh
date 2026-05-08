#!/bin/bash

usage() {
  echo "Usage:"
  echo "  $0 -u domain.com"
  echo "  $0 -U domains.txt"
  exit 1
}

MODE=""
TARGET=""
FILE=""

while getopts "u:U:" opt; do
  case $opt in
    u) MODE="single"; TARGET="$OPTARG" ;;
    U) MODE="list"; FILE="$OPTARG" ;;
    *) usage ;;
  esac
done

if [ -z "$MODE" ]; then
  usage
fi


run_pipeline() {

  TARGET=$1
  SAFE_TARGET=$(echo "$TARGET" | sed 's/[^a-zA-Z0-9]/_/g')

  mkdir -p output/$SAFE_TARGET

  echo "[+] Running pipeline for: $TARGET"

  #########################
  # 1. PASSIVE COLLECTION
  #########################

  gau $TARGET > output/$SAFE_TARGET/gau.txt
  waybackurls $TARGET > output/$SAFE_TARGET/wayback.txt

  cat output/$SAFE_TARGET/gau.txt output/$SAFE_TARGET/wayback.txt \
    | sort -u > output/$SAFE_TARGET/passive.txt


  #########################
  # 2. LIVE CRAWL
  #########################

  katana -u "https://$TARGET" -jc -silent > output/$SAFE_TARGET/katana.txt

  cat output/$SAFE_TARGET/passive.txt output/$SAFE_TARGET/katana.txt \
    | sort -u > output/$SAFE_TARGET/all_urls.txt


  #########################
  # 3. PARAM FILTER
  #########################

  cat output/$SAFE_TARGET/all_urls.txt | grep "?" > output/$SAFE_TARGET/params.txt


  #########################
  # 4. CLEAN NOISE
  #########################

  cat output/$SAFE_TARGET/params.txt | uro > output/$SAFE_TARGET/clean.txt


  #########################
  # 5. LIVE CHECK
  #########################

  httpx -l output/$SAFE_TARGET/clean.txt -silent -status-code \
    > output/$SAFE_TARGET/live.txt

  cat output/$SAFE_TARGET/live.txt | awk '{print $1}' \
    > output/$SAFE_TARGET/live_urls.txt


  #########################
  # 6. PARAM EXTRACTION
  #########################

  cat output/$SAFE_TARGET/live_urls.txt \
    | unfurl format %q \
    | tr '&' '\n' \
    | cut -d= -f1 \
    | sort -u \
    > output/$SAFE_TARGET/params_only.txt


  #########################
  # 7. CATEGORIZATION
  #########################

  cat output/$SAFE_TARGET/params_only.txt | while read p; do

    if echo "$p" | grep -Ei "redirect|url|next|return" >/dev/null; then
      echo "$p => redirect"
    elif echo "$p" | grep -Ei "file|path|template|include" >/dev/null; then
      echo "$p => file"
    elif echo "$p" | grep -Ei "q|search|query" >/dev/null; then
      echo "$p => search"
    elif echo "$p" | grep -Ei "id|uid|user|account" >/dev/null; then
      echo "$p => id"
    else
      echo "$p => other"
    fi

  done > output/$SAFE_TARGET/categorized.txt


  #########################
  # 8. REFLECTION CHECK
  #########################

  MARKER="XSS_TEST_123"

  cat output/$SAFE_TARGET/live_urls.txt | while read url; do

    test_url=$(echo "$url" | sed "s/=.*/=$MARKER/")

    resp=$(curl -s "$test_url")

    echo "$resp" | grep -q "$MARKER" && echo "[REFLECTED] $url"

  done > output/$SAFE_TARGET/reflected.txt


  #########################
  # 9. SPLIT FOR TESTING
  #########################

  grep -Ei "search|q=|query=" output/$SAFE_TARGET/live_urls.txt \
    > output/$SAFE_TARGET/xss.txt

  grep -Ei "id=|user=|account=" output/$SAFE_TARGET/live_urls.txt \
    > output/$SAFE_TARGET/sqli.txt

  grep -Ei "redirect|url=|next=" output/$SAFE_TARGET/live_urls.txt \
    > output/$SAFE_TARGET/redirect.txt

  grep -Ei "file=|path=|download=" output/$SAFE_TARGET/live_urls.txt \
    > output/$SAFE_TARGET/file.txt


  echo "[+] DONE: $TARGET"
}


#########################
# EXECUTION MODES
#########################

if [ "$MODE" == "single" ]; then

  run_pipeline "$TARGET"

elif [ "$MODE" == "list" ]; then

  while read domain; do
    run_pipeline "$domain"
  done < "$FILE"

fi
