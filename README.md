# Idea Generation

新聞到點子生成器 - 讓專業人士在 3 分鐘內從新聞產生商業想法

[![GitHub](https://img.shields.io/badge/GitHub-colaman7014%2FIdeaGeneration-blue)](https://github.com/colaman7014/IdeaGeneration)

## 📖 專案介紹

Idea Generation 是一個創新工具，將新聞內容轉化為商業點子。結合 Flutter 前端與 Python FastAPI 後端，提供直觀的介面讓使用者從最新新聞中快速生成創新商業想法，並進行專業的魔鬼審計。

## ✨ 主要功能

- 📰 **新聞自動抓取**：自動從網路抓取最新新聞內容
- ⚡ **AI 點子生成**：使用先進 AI 技術從新聞中生成商業點子
- 👹 **魔鬼審計**：專業的商業點子審計與建議
- 📝 **Markdown 匯出**：支援將點子匯出為 Markdown 格式，方便在 Obsidian 等工具中使用
- 🎨 **美觀介面**：使用 Flutter 打造的現代化行動應用程式

## 🛠️ 技術架構

- **前端**：Flutter (Dart)
- **後端**：FastAPI (Python)
- **資料庫**：SQLite
- **AI 整合**：支援 Vercel AI API

## 🚀 快速開始

### 環境需求

- Flutter SDK (3.0.0+)
- Python 3.8+
- Git

### 安裝步驟

1. **複製專案**
   ```bash
   git clone https://github.com/colaman7014/IdeaGeneration.git
   cd IdeaGeneration
   ```

2. **設定環境變數**
   
   在 `backend/` 目錄下建立 `.env` 檔案：
   ```
   VERCEL_API_KEY=你的_Vercel_API_Key
   DATABASE_URL=sqlite:///./ideageneration.db
   ```

3. **啟動後端**
   
   **Windows：**
   ```cmd
   start.bat
   ```
   
   **macOS / Linux：**
   ```bash
   chmod +x start.sh
   ./start.sh
   ```

4. **啟動前端**
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

### 驗證安裝

- 後端 API：http://localhost:8000
- API 文件：http://localhost:8000/docs
- 前端應用程式將自動啟動

## 📱 使用指南

1. 啟動應用程式後，首頁會顯示隨機新聞
2. 點擊「Forge It ⚡」生成商業點子
3. 點擊「Call the Devil」進行魔鬼審計
4. 點擊「匯出 Markdown」將結果複製到剪貼板

## 🤝 貢獻指南

歡迎貢獻！請遵循以下步驟：

1. Fork 此專案
2. 建立功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

## 📄 授權條款

此專案採用 MIT 授權條款 - 詳見 [LICENSE](LICENSE) 檔案

## 📞 聯絡資訊

- 專案連結：[GitHub](https://github.com/colaman7014/IdeaGeneration)
- 問題回報：[Issues](https://github.com/colaman7014/IdeaGeneration/issues)

---

**讓新聞成為你的下一個大點子！** 🚀