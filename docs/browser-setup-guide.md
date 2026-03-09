# 🌐 Browser 啟用指南 (Docker/VPS)

**創建日期：** 2026-03-09 00:05 (GMT+8)  
**作者：** 機票達人 ✈️  
**狀態：** 待實施

---

## 📋 問題描述

喺容器/VPS 環境運行 OpenClaw 時，Browser 服務無法啟動：

```
❌ Can't reach the OpenClaw browser control service (timed out after 15000ms)
❌ systemd user services unavailable
```

**原因：**
- 容器無 DISPLAY
- 缺少 Chromium 依賴
- Sandbox 權限問題
- 無 init system (systemd)

---

## ✅ 解決方案 (3 個選項)

---

### 🥇 選項 A: Docker Compose 完整配置 (推薦)

#### docker-compose.yml

```yaml
version: '3.8'

services:
  openclaw:
    image: openclaw/openclaw:latest
    container_name: openclaw
    restart: unless-stopped
    
    # 關鍵設定
    environment:
      - OPENCLAW_BROWSER_ENABLED=true
      - BROWSER_HEADLESS=true
      - BROWSER_NO_SANDBOX=true
      - CHROMIUM_FLAGS=--no-sandbox,--disable-dev-shm-usage,--disable-gpu
    
    # 需要嘅權限
    cap_add:
      - SYS_ADMIN
    
    # 共享記憶體 (重要！)
    shm_size: '2gb'
    
    # volumes
    volumes:
      - ./openclaw-data:/data/.openclaw
      - /tmp/.X11-unix:/tmp/.X11-unix:ro  # 如果需要 X11
    
    # 網絡
    ports:
      - "18789:18789"  # Gateway
      - "18800:18800"  # Browser CDP
    
    # 資源限制
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
```

#### 重啟容器

```bash
docker-compose down
docker-compose up -d
```

---

### 🥈 選項 B: VPS/Server 手動安裝 (Ubuntu/Debian)

#### 步驟 1: 安裝 Chromium 及依賴

```bash
# 更新系統
sudo apt update && sudo apt upgrade -y

# 安裝 Chromium 及依賴
sudo apt install -y \
    chromium \
    chromium-driver \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    xvfb  # 虛擬顯示器

# 驗證安裝
chromium --version
```

#### 步驟 2: 設定環境變數

```bash
# 編輯 ~/.bashrc 或 ~/.zshrc
cat >> ~/.bashrc << 'EOF'

# OpenClaw Browser Settings
export OPENCLAW_BROWSER_ENABLED=true
export BROWSER_HEADLESS=true
export BROWSER_NO_SANDBOX=true
export CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --disable-software-rasterizer"
export DISPLAY=:99
EOF

source ~/.bashrc
```

#### 步驟 3: 啟動虛擬顯示器 (Xvfb)

```bash
# 安裝 Xvfb (如果未裝)
sudo apt install -y xvfb

# 啟動虛擬顯示器
Xvfb :99 -screen 0 1024x768x24 &

# 驗證
echo $DISPLAY  # 應該顯示 :99
```

#### 步驟 4: 重啟 OpenClaw Gateway

```bash
# 停止現有服務
openclaw gateway stop

# 清理瀏覽器進程
pkill -f chromium
pkill -f openclaw-gateway

# 重新啟動
openclaw gateway start

# 檢查狀態
openclaw gateway status
```

#### 步驟 5: 驗證 Browser 服務

```bash
# 檢查 browser 端口
netstat -tlnp | grep 18800

# 或者用 curl
curl http://127.0.0.1:18800/json/version
```

---

### 🥉 選項 C: 快速修復 (當前容器)

```bash
# 1. 安裝缺少嘅依賴
apt-get update
apt-get install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2

# 2. 設定共享記憶體
mount -o remount,size=2G /dev/shm

# 3. 設定環境變數
export CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu"
export OPENCLAW_BROWSER_ENABLED=true

# 4. 重啟 gateway
openclaw gateway restart

# 5. 手動啟動 browser 服務 (如果自動啟動失敗)
node -e "
const { BrowserControl } = require('openclaw/browser');
const bc = new BrowserControl({
  headless: true,
  noSandbox: true,
  port: 18800
});
bc.start();
" &
```

---

## 🔍 驗證 Browser 是否工作

```bash
# 方法 1: 檢查進程
ps aux | grep chromium

# 方法 2: 檢查端口
ss -tlnp | grep 18800

# 方法 3: 用 OpenClaw browser tool
browser action=status

# 方法 4: 直接測試 CDP
curl http://127.0.0.1:18800/json/version
```

**成功輸出應該係：**
```json
{
  "Browser": "Chromium/145.0.7632.116",
  "Protocol-Version": "1.3",
  "User-Agent": "...",
  "V8-Version": "...",
  "WebKit-Version": "..."
}
```

---

## 📊 方案對比

| 方法 | 難度 | 穩定性 | 推薦場景 |
|------|------|--------|----------|
| **Docker Compose** | ⭐⭐ | ⭐⭐⭐⭐⭐ | 生產環境 |
| **VPS 手動安裝** | ⭐⭐⭐ | ⭐⭐⭐⭐ | 自有伺服器 |
| **快速修復** | ⭐ | ⭐⭐ | 測試/臨時 |

---

## 🎯 建議

| 情況 | 建議 |
|------|------|
| **用 Docker** | 選項 A (docker-compose.yml) |
| **用 VPS (Ubuntu)** | 選項 B (手動安裝) |
| **想快速測試** | 選項 C (快速修復) |
| **唔急住用** | 繼續用 web_search (已經夠用) |

---

## 📝 實施記錄

| 日期 | 行動 | 結果 | 備註 |
|------|------|------|------|
| 2026-03-09 00:05 | 創建文檔 | ✅ 完成 | 待用戶實施 |
| - | - | - | - |

---

## 🔗 相關文件

- [hkg-cdg-price-monitor.md](../hkg-cdg-price-monitor.md) - 機票價格監測報告
- [hkg-tpe-next-24h.md](../hkg-tpe-next-24h.md) - TPE 24 小時航班資訊
- [HEARTBEAT.md](../HEARTBEAT.md) - 定期檢查設定

---

**最後更新：** 2026-03-09 00:05 (GMT+8)  
**GitHub:** https://github.com/dr55621008/openclaw_1/blob/master/docs/browser-setup-guide.md
