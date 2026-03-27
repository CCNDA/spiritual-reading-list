<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../config/database.php';

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', trim($uri, '/'));
$method = $_SERVER['REQUEST_METHOD'];

$resource = $uri[1] ?? '';
$id = $uri[2] ?? null;
$sub = $uri[3] ?? null;

switch ($resource) {
    case 'books':
        require_once '../controllers/BooksController.php';
        $controller = new BooksController(getDB());
        if ($id && $sub === 'reviews') {
            require_once '../controllers/ReviewsController.php';
            $rev = new ReviewsController(getDB());
            $method === 'GET' ? $rev->getByBook($id) : $rev->create($id);
        } elseif (isset($_GET['q'])) {
            $controller->search($_GET['q']);
        } elseif ($id) {
            match($method) {
                'GET' => $controller->show($id),
                'PUT' => $controller->update($id),
                'DELETE' => $controller->delete($id),
                default => http_response_code(405)
            };
        } else {
            match($method) {
                'GET' => $controller->index(),
                'POST' => $controller->create(),
                default => http_response_code(405)
            };
        }
        break;
    case 'categories':
        require_once '../controllers/CategoriesController.php';
        $controller = new CategoriesController(getDB());
        $controller->index();
        break;
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Not Found']);
}
