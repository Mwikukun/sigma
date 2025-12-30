<?php
session_start();
header("Content-Type: application/json");

require_once "config.php";
require_once "guard.php";

$data = json_decode(file_get_contents("php://input"), true);

$targetId  = $data['id'] ?? null;
$newStatus = $data['status'] ?? null;

// 🔹 ambil dari session user
$adminId   = $_SESSION['user']['id'] ?? null;
$adminRole = $_SESSION['user']['user_type'] ?? null;

if ($adminRole !== 'admin') {
  echo json_encode([
    "status" => "error",
    "message" => "Unauthorized"
  ]);
  exit;
}

if ($targetId == $adminId) {
  echo json_encode([
    "status" => "error",
    "message" => "Admin tidak bisa menonaktifkan akun sendiri"
  ]);
  exit;
}

$stmt = $conn->prepare("UPDATE users SET status=? WHERE id=?");
$stmt->bind_param("si", $newStatus, $targetId);
$stmt->execute();

echo json_encode([
  "status" => "success",
  "message" => "Status user berhasil diubah"
]);
?>
