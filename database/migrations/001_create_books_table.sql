-- =============================================
-- 屬靈共同書目資料庫
-- 版本：2.0（依完整書籍資料庫模板重建）
-- =============================================

CREATE DATABASE IF NOT EXISTS books CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE books;

-- =============================================
-- 1. 核心作品表 Books
--    同一作品可有多版本、多格式、多語言翻譯
-- =============================================
CREATE TABLE IF NOT EXISTS books (
    book_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title_zh      TEXT         NOT NULL COMMENT '書名（中文）',
    title_en      TEXT                  COMMENT '書名（英文）',
    subtitle      TEXT                  COMMENT '副標題',
    original_title TEXT                 COMMENT '原文書名（若翻譯書）',
    work_type     ENUM('書','期刊','叢書','教材','報告','其他') DEFAULT '書' COMMENT '作品類型',
    language_primary CHAR(2)            COMMENT '主要語言 ISO 639-1，如 zh/en',
    summary_short TEXT                  COMMENT '短書介（社群/卡片用）',
    summary_long  TEXT                  COMMENT '長書介',
    toc           TEXT                  COMMENT '目錄',
    notes         TEXT                  COMMENT '備註',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='核心作品表';


-- =============================================
-- 2. 出版者表 Publishers
-- =============================================
CREATE TABLE IF NOT EXISTS publishers (
    publisher_id  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name_zh       VARCHAR(255) NOT NULL COMMENT '出版者名稱（中文）',
    name_en       VARCHAR(255)          COMMENT '出版者名稱（英文）',
    org_ref_id    VARCHAR(100)          COMMENT '連結教會機構名錄的機構ID',
    website       VARCHAR(500)          COMMENT '官方網站',
    contact       TEXT                  COMMENT '聯絡資訊',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='出版者表';


-- =============================================
-- 3. 人物表 Persons（作者/譯者/編者等）
-- =============================================
CREATE TABLE IF NOT EXISTS persons (
    person_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(255) NOT NULL COMMENT '姓名',
    name_en       VARCHAR(255)          COMMENT '英文名/羅馬拼音',
    aka           TEXT                  COMMENT '別名/常用譯名（多筆以 ; 分隔）',
    bio           TEXT                  COMMENT '簡介',
    website       VARCHAR(500)          COMMENT '個人網站/社群',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='人物表';


-- =============================================
-- 4. 系列表 Series
-- =============================================
CREATE TABLE IF NOT EXISTS series (
    series_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    series_name   VARCHAR(255) NOT NULL COMMENT '系列名稱',
    series_note   TEXT                  COMMENT '系列描述',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='系列表';


-- =============================================
-- 5. 主題/分類表 Subjects
-- =============================================
CREATE TABLE IF NOT EXISTS subjects (
    subject_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    scheme        ENUM('BISAC','LCC','DDC','中圖','自訂','keyword') NOT NULL COMMENT '分類系統',
    code          VARCHAR(100)          COMMENT '分類碼',
    label         VARCHAR(255) NOT NULL COMMENT '主題標籤/名稱',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='主題分類表';


-- =============================================
-- 6. 版本表 Editions
--    一本書可有多個版本（初版/修訂版/不同語言版）
-- =============================================
CREATE TABLE IF NOT EXISTS editions (
    edition_id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id             INT UNSIGNED NOT NULL,
    edition_statement   VARCHAR(255)          COMMENT '版本資訊：初版/修訂版/再版等',
    publish_date        DATE                  COMMENT '出版日期',
    place_of_publication VARCHAR(255)         COMMENT '出版地',
    publisher_id        INT UNSIGNED          COMMENT '主出版者（多出版者用 edition_publishers）',
    print_run           VARCHAR(50)           COMMENT '印次/刷次',
    page_count          SMALLINT UNSIGNED     COMMENT '頁數',
    binding             VARCHAR(100)          COMMENT '裝幀/釘裝',
    dimensions          VARCHAR(100)          COMMENT '尺寸（長x寬x厚）',
    weight_g            SMALLINT UNSIGNED     COMMENT '重量（克）',
    copyright           TEXT                  COMMENT '版權資訊',
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='版本表';


-- =============================================
-- 7. 識別碼表 Identifiers（ISBN/EAN等一對多）
-- =============================================
CREATE TABLE IF NOT EXISTS identifiers (
    identifier_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    edition_id    INT UNSIGNED NOT NULL,
    id_type       ENUM('ISBN13','ISBN10','EAN','UPC','ISSN','DOI','其他') NOT NULL COMMENT '識別碼類型',
    id_value      VARCHAR(100) NOT NULL COMMENT '識別碼值',
    note          VARCHAR(255)          COMMENT '備註',
    FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='識別碼表';


-- =============================================
-- 8. 作品人物關聯表 BookPersons（多作者/多譯者）
-- =============================================
CREATE TABLE IF NOT EXISTS book_persons (
    book_person_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id        INT UNSIGNED NOT NULL,
    person_id      INT UNSIGNED NOT NULL,
    role           ENUM('作者','編者','譯者','插畫','序','顧問','校對','其他') NOT NULL,
    role_order     TINYINT UNSIGNED DEFAULT 1 COMMENT '同角色多人時的排序',
    credit_text    VARCHAR(500) COMMENT '封面署名原文',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES persons(person_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='作品人物關聯表';


-- =============================================
-- 9. 作品系列關聯表 BookSeries
-- =============================================
CREATE TABLE IF NOT EXISTS book_series (
    book_series_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id        INT UNSIGNED NOT NULL,
    series_id      INT UNSIGNED NOT NULL,
    series_number  VARCHAR(50)  COMMENT '系列冊次/編號',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (series_id) REFERENCES series(series_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='作品系列關聯表';


-- =============================================
-- 10. 作品主題關聯表 BookSubjects
-- =============================================
CREATE TABLE IF NOT EXISTS book_subjects (
    book_subject_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id         INT UNSIGNED NOT NULL,
    subject_id      INT UNSIGNED NOT NULL,
    weight          TINYINT UNSIGNED DEFAULT 0 COMMENT '權重/排序',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='作品主題關聯表';


-- =============================================
-- 11. 格式與定價表 Formats
--     同一版本可有平裝/精裝/電子書/有聲書
-- =============================================
CREATE TABLE IF NOT EXISTS formats (
    format_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    edition_id    INT UNSIGNEH NOT NULL,
    media_type    ENUM('紙本','電子','有聲','其他') NOT NULL COMMENT '媒介類型',
    file_format   VARCHAR(50)           COMMENT 'EPUB/PDF/MOBI/MP3等',
    sku           VARCHAR(100)          COMMENT '內部SKU',
    price         DECIMAL(10,2)         COMMENT '定價',
    currency      CHAR(3) DEFAULT 'TWD' COMMENT '幣別',
    availability  VARCHAR(100)          COMMENT '庫存/上架狀態',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='格式與定價表';


-- =============================================
-- 12. 外部連結表 Links
-- =============================================
CREATE TABLE IF NOT EXISTS links (
    link_id       INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id       INT UNSIGNED          COMMENT '關聯作品（擇一填）',
    edition_id    INT UNSIGNED          COMMENT '關聯版本（擇一填）',
    link_type     ENUM('官方頁','購買','電子平台','有聲','介紹','影片','社群貼文','其他') NOT NULL,
    platform      VARCHAR(100)          COMMENT '平台：博客來/誠品/Amazon/YouTube等',
    url           VARCHAR(1000) NOT NULL COMMENT '連結',
    note          VARCHAR(255)          COMMENT '備註',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='外部連結表';


-- =============================================
-- 13. 媒體素材表 Media（封面/圖片等）
-- =============================================
CREATE TABLE IF NOT EXISTS media (
    media_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id       INT UNSIGNED          COMMENT '關聯作品',
    edition_id    INT UNSIGNED          COMMENT '關聯版本',
    media_type    ENUM('封面','內頁','宣傳圖','附件','其他') NOT NULL,
    url_or_path   VARCHAR(1000) NOT NULL COMMENT '檔案路徑或URL',
    caption       VARCHAR(500)          COMMENT '圖說',
    is_primary    TINYINT(1) DEFAULT 0  COMMENT '是否主圖',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (edition_id) REFERENCES editions(edition_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='媒體素材表';


-- =============================================
-- 14. 書評/推薦表 Reviews
-- =============================================
CREATE TABLE IF NOT EXISTS reviews (
    review_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id       INT UNSIGNED NOT NULL,
    source        VARCHAR(255)          COMMENT '來源：媒體/平台/個人',
    rating        DECIMAL(3,1)          COMMENT '評分（如 4.5）',
    quote         TEXT                  COMMENT '短引文',
    content       TEXT                  COMMENT '評論摘要',
    url           VARCHAR(1000)         COMMENT '原文連結',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='書評推薦表';


-- =============================================
-- 15. 快速匯入暫存表 import_staging
--     人工或爬蟲資料先填此表，程式再拆分正規化
-- =============================================
CREATE TABLE IF NOT EXISTS import_staging (
    staging_id        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title_zh          TEXT         NOT NULL COMMENT '書名（中文）',
    subtitle          TEXT                  COMMENT '副標題',
    authors           TEXT                  COMMENT '作者（多位用 ; 分隔）',
    translators       TEXT                  COMMENT '譯者（多位用 ; 分隔）',
    editors           TEXT                  COMMENT '編者/主編（多位用 ; 分隔）',
    contributors      TEXT                  COMMENT '其他貢獻者（角色:姓名；角色:姓名）',
    publisher         TEXT                  COMMENT '出版社（多家用 ; 分隔）',
    publish_date      DATE                  COMMENT '出版日期',
    edition_statement VARCHAR(255)          COMMENT '版次資訊',
    isbn13            TEXT                  COMMENT 'ISBN13（多筆用 ; 分隔）',
    ean_upc           TEXT                  COMMENT '條碼（多筆用 ; 分隔）',
    series            TEXT                  COMMENT '系列（名稱#冊次；名稱#冊次）',
    page_count        SMALLINT UNSIGNED     COMMENT '頁數',
    binding           VARCHAR(100)          COMMENT '釘裝/裝幀',
    language          VARCHAR(100)          COMMENT '語言（多語用 ; 分隔）',
    subjects          TEXT                  COMMENT '分類/主題（多筆用 ; 分隔）',
    keywords          TEXT                  COMMENT '關鍵字（多筆用 ; 分隔）',
    summary_short     TEXT                  COMMENT '短書介',
    summary_long      TEXT                  COMMENT '長書介',
    buy_links         TEXT                  COMMENT '購買連結（平台|URL；平台|URL）',
    cover_url         TEXT                  COMMENT '封面圖URL（多版本用 ; 分隔）',
    imported          TINYINT(1) DEFAULT 0  COMMENT '是否已匯入正規化表',
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='快速匯入暫存表';


-- =============================================
-- 預設主題分類（自訂系統）
-- =============================================
INSERT INTO subjects (scheme, label) VALUES
('自訂', '靈修與祈禱'),
('自訂', '神學與教義'),
('自訂', '聖經研讀'),
('自訂', '基督教歷史'),
('自訂', '靈性成長'),
('自訂', '宣教與事工'),
('自訂', '基督教教育'),
('自訂', '婚姻與家庭');


-- =============================================
-- 16. 會員主表 Members
--     只以 email 識別身份，不蒐集個資
-- =============================================
CREATE TABLE IF NOT EXISTS members (
    member_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email       VARCHAR(320) NOT NULL UNIQUE          COMMENT 'Email（唯一識別碼）',
    status      ENUM('active','inactive','banned') NOT NULL DEFAULT 'active',
    email_verified TINYINT(1) NOT NULL DEFAULT 0      COMMENT '是否已驗證 email',
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_seen_at DATETIME                              COMMENT '最後活動時間'
) ENGINE=InnoDB COMMENT='會員主表（僅 email，無其他個資）';


-- =============================================
-- 17. 登入 Token 表 MemberTokens
--     Magic Link / OTP 無密碼登入
-- =============================================
CREATE TABLE IF NOT EXISTS member_tokens (
    token_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    member_id   INT UNSIGNED NOT NULL,
    token       VARCHAR(128) NOT NULL UNIQUE           COMMENT '隨機 token',
    token_type  ENUM('login','verify_email') NOT NULL DEFAULT 'login',
    expires_at  DATETIME NOT NULL                      COMMENT '過期時間（建議 15 分鐘）',
    used_at     DATETIME                               COMMENT '使用時間（一次性）',
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    INDEX idx_token (token),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB COMMENT='Magic Link 登入 Token 表';


-- =============================================
-- 18. 書架/書單表 MemberShelves
--     會員的讀書狀態（想讀/讀中/已讀）與收藏
-- =============================================
CREATE TABLE IF NOT EXISTS member_shelves (
    shelf_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    member_id   INT UNSIGNED NOT NULL,
    book_id     INT UNSIGNED NOT NULL,
    shelf_type  ENUM('want','reading','read','favorite') NOT NULL COMMENT '想讀/讀中/已讀/收藏',
    added_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    note        TEXT                                    COMMENT '私人備注',
    UNIQUE KEY uq_member_book (member_id, book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='會員書架（讀書狀態）';
