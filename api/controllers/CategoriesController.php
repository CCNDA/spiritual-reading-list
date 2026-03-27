<?php
class CategoriesController {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    public function index() {
        $stmt = $this->db->query(
            "SELECT c.*, COUNT(b.id) as book_count
             FROM categories c
             LEFT JOIN books b ON b.category = c.slug AND b.status = 'active'
             GROUP BY c.id ORDER BY c.sort_order ASC"
        );
        echo json_encode($stmt->fetchAll());
    }
}
