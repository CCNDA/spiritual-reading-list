# 屬靈共同書目 Spiritual Common Bibliography

> 由 CCNDA 開發的屬靈共同書目網站服務

## 簡介

本專案為 CCNDA 屬靈共同書目網站服務，提供靈性書籍、文章與資源的整理與推薦。

## 技術棧

- 前端：HTML / CSS / JavaScript（或依實際技術棧更新）
- 後端：PHP（Nginx + PHP-FPM）
- 資料庫：MySQL
- 版本控管：Git + GitHub
- 專案管理：monday.com
- 進度通知：Discord

## 分支策略

| 分支 | 用途 |
|------|------|
| `main` | 穩定版本，可部署 |
| `dev` | 開發整合分支 |
| `feature/*` | 個別功能開發 |

## 開始開發

```bash
# Clone 專案
git clone https://github.com/CCNDA/spiritual-reading-list.git
cd spiritual-reading-list

# 建立開發分支
git checkout -b dev

# 開始功能開發
git checkout -b feature/你的功能名稱
```

## 提交規範

```text
feat: 新增功能
fix: 修復 bug
docs: 文件更新
style: 樣式調整
refactor: 程式重構
chore: 其他雜項
```

## 部署環境紀錄

### 系統與網路

- 作業系統: Ubuntu 22.04 LTS
- 網域: books.oursweb.net
- 通訊協定: HTTPS (443)

### Web 與 Runtime

- Web Server: Nginx
- PHP: 8.3
- PHP 執行模式: PHP-FPM
- 主要 PHP 擴充:
  - pdo_mysql
  - mbstring
  - curl
  - json
  - openssl
  - fileinfo

### 資料庫

- 資料庫: MariaDB 10.11.13
- 編碼: utf8mb4
- Collation: utf8mb4_unicode_ci

### 郵件服務

- 服務: AWS SES (SMTP)
- Host: email-smtp.ap-northeast-1.amazonaws.com
- Port: 587
- 加密: STARTTLS
- 寄件者: support@ccnda.org

### 專案路徑與結構（伺服器）

- 專案根目錄: /home/ubuntu/books
- Web 入口根目錄: /home/ubuntu/books
- 主要目錄:
  - /home/ubuntu/books/web
  - /home/ubuntu/books/api
  - /home/ubuntu/books/config
  - /home/ubuntu/books/database/migrations

### 設定檔

- 本機敏感設定: config/app.local.php
- 範本設定: config/app.example.php
- 注意: config/app.local.php 不進版控

### 已使用的核心機制

- 認證: Magic Link（無密碼登入）
- 書籍頁: 每本書可用獨立網址存取
- 後台建檔: 簡易 / 進階雙模式
- 外站匯入: 支援博客來、校園書房、基道

## 聯絡

- 組織：CCNDA
- 專案負責人：王獻宗 秘書長
