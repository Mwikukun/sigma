<?php
include "config.php";
header("Content-Type: application/json");

$data = json_decode(file_get_contents("php://input"), true);
$id = $data["id"] ?? 0;

if (!$id) {
    echo json_encode(["status" => "error", "message" => "ID tidak valid."]);
    exit;
}

// Gunakan prepared statement agar aman
$stmt = $conn->prepare("DELETE FROM users WHERE id = ?");
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "User berhasil dihapus!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal menghapus user: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
