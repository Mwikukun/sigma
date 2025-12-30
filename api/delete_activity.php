<?php
include 'cors.php';
include 'config_api.php';

$id = $_POST["id"] ?? '';

if (!$id) {
    echo json_encode(["success" => false]);
    exit;
}

$q = $conn->prepare("DELETE FROM activities WHERE id = ?");
$q->bind_param("i", $id);

echo json_encode(["success" => $q->execute()]);
?>
