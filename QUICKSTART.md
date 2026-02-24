# 快速啟動指南

## 1. 設定環境變數

在 `backend/` 目錄下手動建立 `.env` 檔案，內容如下：

```
VERCEL_API_KEY=你的_Vercel_API_Key
DATABASE_URL=sqlite:///./ideageneration.db
```

Vercel API Key 取得方式：
- 前往 https://vercel.com/account/tokens
- 建立新的 Token
- 複製後貼入上方 `VERCEL_API_KEY=` 後面

## 2. 啟動後端

**Windows：**
```
start.bat
```

**macOS / Linux：**
```bash
chmod +x start.sh
./start.sh
```

後端啟動後：
- API 位址：http://localhost:8000
- API 互動文件：http://localhost:8000/docs

## 3. 啟動 Flutter App

```bash
cd frontend
flutter pub get
flutter run
```

選擇目標裝置（iOS 模擬器 / Android 模擬器 / 實機）

## 4. 完整流程驗證

1. 後端啟動後，等待首次自動抓取新聞（約 30 秒）
2. 或手動觸發：`curl -X POST http://localhost:8000/api/news/fetch`
3. 開啟 Flutter App → 首頁自動顯示兩則隨機新聞
4. 點擊「Forge It ⚡」→ AI 生成商業點子（約 15-30 秒）
5. 點擊「Call the Devil」→ AI 魔鬼審計（約 15-30 秒）
6. 點擊「匯出 Markdown」→ 複製到剪貼板 → 貼入 Obsidian
