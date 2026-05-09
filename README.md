Tool workflow:

Passive OSINT urls' parameters + Historical urls' parameters + Crawled urls' parameters + bruteforce parameter -> filter urls with parameters -> Remove noise parameter urls -> Filter live urls -> Normalize parameters -> Categorize parameters -> Test (XSS - dalfox, SQLi - sqlmap, Open redirect → manual + automation, LFI/RFI → fuzz payloads)

Precautions:
1. Be aware of websites hosted on CSP, as they have rate-limit.
2. 
