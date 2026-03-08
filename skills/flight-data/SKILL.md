# SKILL.md - 機票價錢數據

從各網站攞機票價錢資訊。

## 數據來源

### Free Sources
- **Skyscanner** — https://www.skyscanner.com
- **Google Flights** — https://www.google.com/travel/flights
- **Expedia** — https://www.expedia.com
- **Kayak** — https://www.kayak.com

### APIs (需要API Key)
- **FlightAPI.io** — 有免費tier
- **Amadeus** — 免費注冊有credit
- **Skyscanner API** — 需要申請

## 用法

### Web Search
```bash
# 搜尋最新價錢
web_search "HK to Paris flights April 2026 cheapest"
```

### Web Fetch
```bash
# Fetch特定頁面
web_fetch https://www.skyscanner.com/transport/flights/hkg/par/
```

### 常見搜尋
- "HK to Tokyo cheapest"
- "HK to London business class"
- "HKG to CDG 26/4"

## 輸出格式

話俾用家知：
- 航空公司
- 價錢 (USD/HKD)
- 單程/來回
- 備註 (轉機/直通)

## 記住

- 價錢成日變，要注明係幾時既data
- 黃金週/假期會貴啲
- 最好provide多個source既價錢
- 唔同日期價錢可以差好遠