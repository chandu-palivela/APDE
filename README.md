Tool workflow:
Passive OSINT urls + Historical urls + Crawled urls + bruteforce parameter urls -> filter urls with parameters -> Remove noise parameter urls -> Filter live urls -> Normalize parameters -> Categorize parameters -> Test (XSS - dalfox, SQLi - sqlmap, Open redirect → manual + automation, LFI/RFI → fuzz payloads)

Internal tools used: Add API keys at speified files for better results
gau - Common crawl, URLScan, OTX, wayback - $HOME/.gau.toml or %USERPROFILE%\.gau.toml
waybackurls - Wayback machine
waymore - wayback machine, Common crawl, OTX, URLScan, Virustotal, intelligenceX (intelx.io) - %APPDATA%\waymore\config.yml or $HOME/.config/waymore/config.yml
katana
