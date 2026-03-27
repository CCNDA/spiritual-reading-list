<?php
require_once '../api/config/database.php';

// 取得分類清單
$stmt = getDB()->query("SELECT * FROM categories ORDER BY sort_order ASC");
$categories = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="zh-Hant">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>屬靈共同書目</title>
  <link rel="stylesheet" href="/css/style.css">
</head>
<body>
  <nav class="navbar">
    <div class="container nav-inner">
      <a href="/" class="brand">✝ 屬靈共同書目</a>
      <div class="nav-links">
        <a href="/">書單</a>
        <a href="/admin/">管理</a>
      </div>
    </div>
  </nav>

  <main class="container py-8">
    <!-- 搜尋列 -->
    <div class="search-wrap">
      <input type="text" id="searchInput" placeholder="搜尋書名、作者..." class="search-input">
    </div>

    <!-- 分類篩選 -->
    <div class="category-tabs" id="categoryTabs">
      <button class="tab active" data-slug="">全部</button>
      <?php foreach ($categories as $cat): ?>
        <button class="tab" data-slug="<?= htmlspecialchars($cat['slug']) ?>">
          <?= htmlspecialchars($cat['name']) ?>
          <span class="count">(<?= $cat['book_count'] ?? 0 ?>)</span>
        </button>
      <?php endforeach; ?>
    </div>

    <!-- 書單列表 -->
    <div id="bookGrid" class="book-grid">
      <p class="loading">載入中...</p>
    </div>
  </main>

  <!-- 書目詳情 Modal -->
  <div id="modal" class="modal hidden">
    <div class="modal-overlay" id="modalOverlay"></div>
    <div class="modal-content" id="modalContent"></div>
  </div>

  <footer class="footer">© CCNDA · 屬靈共同書目</footer>

  <script src="/js/app.js"></script>
</body>
</html>
