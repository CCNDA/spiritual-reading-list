<?php
class ReviewsController {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function getByBook($bookId) {
        $stmt = $this->db->prepare(
            "SELECT * FROM reviews WHERE book_id = ? ORDER BY created_at DESC"
        );
        $stmt->execute([$bookId]);
        echo json_encode($stmt->fetchAll());
    }

    public function create($bookId) {
        $data = json_decode(file_get_contents('php://input'), true);
        $stmt = $this->db->prepare(
            "INSERT INTO reviews (book_id, reviewer_name, rating, content) VALUES (?, ?, ?, ?)"
        );
        $stmt->execute([
            $bookId,
            $data['reviewer_name'],
            $data['rating'] ?? null,
            $data['content']
        ]);
        http_response_code(201);
        echo json_encode(['message' => '評論新增成功']);
    }
}
