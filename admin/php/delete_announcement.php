<?php
ob_start(); // mulai buffer

header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$id = $_POST['id'] ?? 0;

$sql = "DELETE FROM announcements WHERE id = $id";

$response = [
    "success" => $conn->query($sql),
    "message" => $conn->error
];

ob_end_clean(); // buang semua output sampah
echo json_encode($response);
exit;
