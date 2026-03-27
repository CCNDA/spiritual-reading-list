-- 屬靈共同書目資料庫初始化
CREATE DATABASE IF NOT EXISTS books CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE books;

-- 書目主表
CREATE TABLE IF NOT EXISTS books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL COMMENT '書名',
    author VARCHAR(255) NOT NULL COMMENT '作者',
    translator VARCHAR(255) COMMENT '譯者',
    publisher VARCHAR(255) COMMENT '出版社',
    published_year YEAR COMMENT '出版年份',
    isbn VARCHAR(20) COMMENT 'ISBN',
    category VARCHAR(100) COMMENT '分類',
    tags JSON COMMENT '標籤',
    description TEXT COMMENT '簡介',
    cover_image VARCHAR(500) COMMENT '封面圖片URL',
    recommended_by VARCHAR(255) COMMENT '推薦人',
    status ENUM('active', 'hidden') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT='屬靈書目清單';

-- ⪥論表
CREATE TABLE IF NOT EXISTS reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    reviewer_name VARCHAR(100) NOT NULL COMMENT '評論者',
    rating TINYINT UNSIGNED COMMENT '評分 1-5',
    content TEXT COMMENT '評論內容',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) COMMENT='書目評論';

-- 分類表
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT '分類名稱',
    slug VARCHAR(100) NOT NULL UNIQUE COMMENT '網址用識別碼',
    description TEXT COMMENT '分類描述',
    sort_order INT DEFAULT 0
) COMMENT='書目分類';

-- 插入預設分類
INSERT INTO categories (name, slug, sort_order) VALUES
('靈修與祈禱', 'spiritual-practice', 1),
('神學與教義', 'theology', 2),
('聖經研讀', 'bible-study', 3),
('基督教歷史', 'church-history', 4),
('靈性成長', 'spiritual-growth', 5),
('宣教與事工', 'mission', 6);
