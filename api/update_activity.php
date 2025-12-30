<?php
include 'cors.php';
include 'config_api.php';

$id          = $_POST["id"] ?? '';
$description = $_POST["description"] ?? '';
$percentage  = $_POST["percentage"] ?? '';
$section     = $_POST["section"] ?? '';

if (!$id) {
    echo json_encode([
        "success" => false,
        "message" => "ID tidak valid"
    ]);
    exit;
}

$sql = "
UPDATE activities
SET description = ?, percentage = ?, section = ?
WHERE id = ?
";

$stmt = $conn->prepare($sql);
$stmt->bind_param(
    "sisi",
    $description,
    $percentage,
    $section,
    $id
);

echo json_encode([
    "success" => $stmt->execute()
]);
