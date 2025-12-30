<?php
include 'cors.php';
include 'config_api.php';

// 🔥 TERIMA GET & POST
$student_id = $_GET['student_id'] ?? $_POST['student_id'] ?? '';

if (empty($student_id)) {
    echo json_encode([
        "success" => true,
        "data" => []
    ]);
    exit;
}

$sql = "
SELECT 
    id,
    title,
    description,
    section,
    percentage,
    start_date,
    due_date
FROM activities
WHERE student_id = ?
ORDER BY id DESC
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $student_id);
$stmt->execute();

$res = $stmt->get_result();
$data = [];

while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $data
]);
