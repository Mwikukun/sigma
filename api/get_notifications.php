<?php
include 'config_api.php';
include 'cors.php';

$student_id = $_POST['student_id'] ?? null;
$lecturer_id = $_POST['lecturer_id'] ?? null;

if (!$student_id && !$lecturer_id) {
    echo json_encode([
        "success" => false,
        "message" => "ID tidak lengkap"
    ]);
    exit;
}

// Jika mahasiswa -> ambil berdasarkan student_id
if ($student_id) {
    $stmt = $conn->prepare("SELECT * FROM notifications WHERE student_id = ? ORDER BY id DESC");
    $stmt->bind_param("s", $student_id);
}
// Jika dosen -> ambil berdasarkan lecturer_id
else if ($lecturer_id) {
    $stmt = $conn->prepare("SELECT * FROM notifications WHERE lecturer_id = ? ORDER BY id DESC");
    $stmt->bind_param("s", $lecturer_id);
}

$stmt->execute();
$result = $stmt->get_result();

$rows = [];
while ($row = $result->fetch_assoc()) {
    $rows[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $rows
]);
