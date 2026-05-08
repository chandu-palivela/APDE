Tool workflow:
Passive OSINT urls + Historical urls + Crawled urls + bruteforce parameter urls -> filter urls with parameters -> Remove noise parameter urls -> Filter live urls -> Normalize parameters -> Categorize parameters -> Test (XSS - dalfox, SQLi - sqlmap, Open redirect → manual + automation, LFI/RFI → fuzz payloads)
