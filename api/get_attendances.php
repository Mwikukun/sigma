<?php
include 'config_api.php';
include 'cors.php';

if (!isset($_GET['student_id'])) {
    echo json_encode([
        "status" => false,
        "message" => "student_id parameter is required"
    ]);
    exit;
}

$student_id = $_GET['student_id'];

// 🔹 Ambil semua data kehadiran mahasiswa
$stmt = $conn->prepare("
    SELECT 
        sa.id,
        sa.schedule_id,
        sa.status,
        sa.reason,
        s.title,
        s.datetime
    FROM schedule_attendances sa
    JOIN schedules s ON sa.schedule_id = s.id
    WHERE sa.student_id = ?
");
$stmt->bind_param("s", $student_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

if (empty($data)) {
    echo json_encode([
        "status" => "success",
        "message" => "Belum ada data kehadiran",
        "data" => []
    ]);
} else {
    echo json_encode([
        "status" => "success",
        "count" => count($data),
        "data" => $data
    ]);
}

$stmt->close();
$conn->close();
?>
