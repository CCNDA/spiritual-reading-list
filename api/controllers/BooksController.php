<?php
class BooksController {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function index() {
        $category = $_GET['category'] ?? null;
        $sql = "SELECT b.*, c.name as category_name FROM books b
                LEFT JOIN categories c ON b.category = c.slug
                WHERE b.status = 'active'";
        $params = [];
        if ($category) {
            $sql .= " AND b.category = ?";
            $params[] = $category;
        }
        $sql .= " ORDER BY b.created_at DESC";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        echo json_encode($stmt->fetchAll());
    }

    public function show($id) {
        $stmt = $this->db->prepare("SELECT * FROM books WHERE id = ? AND status = 'active'");
        $stmt->execute([$id]);
        $book = $stmt->fetch();
        if (!$book) { http_response_code(404); echo json_encode(['error' => '找不到此書目']); return; }
        echo json_encode($book);
    }

    public function search($q) {
        $like = "%$q%";
        $stmt = $this->db->prepare(
            "SELECT * FROM books WHERE status = 'active'
             AND (title LIKE ? OR author LIKE ? OR description LIKE ?)
             ORDER BY title ASC"
        );
        $stmt->execute([$like, $like, $like]);
        echo json_encode($stmt->fetchAll());
    }

    public function create() {
        $data = json_decode(file_get_contents('php://input'), true);
        $stmt = $this->db->prepare(
            "INSERT INTO books (title, author, translator, publisher, published_year,
             isbn, category, tags, description, cover_image, recommended_by)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        );
        $stmt->execute([
            $data['title'], $data['author'], $data['translator'] ?? null,
            $data['publisher'] ?? null, $data['published_year'] ?? null,
            $data['isbn'] ?? null, $data['category'] ?? null,
            isset($data['tags']) ? json_encode($data['tags']) : null,
            $data['description'] ?? null, $data['cover_image'] ?? null,
            $data['recommended_by'] ?? null
        ]);
        http_response_code(201);
        echo json_encode(['id' => $this->db->lastInsertId(), 'message' => '書目新增成功']);
    }

    public function update($id) {
        $data = json_decode(file_get_contents('php://input'), true);
        $stmt = $this->db->prepare(
            "UPDATE books SET title=?, author=?, translator=?, publisher=?,
             published_year=?, category=?, description=?, cover_image=?, recommended_by=?
             WHERE id=?"
        );
        $stmt->execute([
            $data['title'], $data['author'], $data['translator'] ?? null,
            $data['publisher'] ?? null, $data['published_year'] ?? null,
            $data['category'] ?? null, $data['description'] ?? null,
            $data['cover_image'] ?? null, $data['recommended_by'] ?? null, $id
        ]);
        echo json_encode(['message' => '書目更新成功']);
    }

    public function delete($id) {
        $stmt = $this->db->prepare("UPDATE books SET status='hidden' WHERE id=?");
        $stmt->execute([$id]);
        echo json_encode(['message' => '書目已下架']);
    }
}
