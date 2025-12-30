<?php
session_start();
header("Content-Type: application/json");

if (!empty($_SESSION['admin_logged_in'])) {
    echo json_encode([
        "authenticated" => true,
        "name" => $_SESSION['admin_name'] ?? ''
    ]);
} else {
    http_response_code(401);
    echo json_encode([
        "authenticated" => false
    ]);
}
