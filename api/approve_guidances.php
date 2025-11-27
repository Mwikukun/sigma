<?php
include 'cors.php';
require_once("config_api.php");

$guidance_id = $_POST['guidance_id'] ?? null;
$is_approved = $_POST['is_approved'] ?? null;

if (!$guidance_id || $is_approved === null) {
    echo json_encode(["success" => false, "message" => "Parameter tidak lengkap"]);
    exit;
}

$query = "UPDATE guidances SET is_approved = ? WHERE id = ?";
$stmt = $conn->prepare($query);
$stmt->bind_param("ii", $is_approved, $guidance_id);
$stmt->execute();

echo json_encode([
    "success" => true,
    "message" => $is_approved == 1 ? "Mahasiswa disetujui ✅" : "Mahasiswa ditolak ❌"
]);
