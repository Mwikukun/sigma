<?php
ini_set('display_errors', 0);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once '../config_api.php';

// Ambil data JSON
$input = file_get_contents("php://input");
$data = json_decode($input, true);

if (!$data) {
    echo json_encode(['status' => false, 'message' => 'Format JSON tidak valid']);
    exit;
}

// Ambil field
$title       = trim($data['title'] ?? '');
$session     = trim($data['session'] ?? '');
$datetime    = $data['datetime'] ?? '';
$location    = trim($data['location'] ?? '');
$description = trim($data['description'] ?? '');
$employee_number = $data['lecturer_id'] ?? null; // langsung employee_number

if (!$title || !$session || !$datetime || !$location || !$employee_number) {
    echo json_encode(['status' => false, 'message' => 'Data tidak lengkap (lecturer_id = employee_number wajib)']);
    exit;
}

// INSERT ke schedules
$status = 'approved';
$student_id = null;

$stmt = $conn->prepare("
    INSERT INTO schedules (student_id, lecture_id, title, session, datetime, description, location, status)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
");

if (!$stmt) {
    echo json_encode(['status' => false, 'message' => 'Gagal prepare: ' . $conn->error]);
    exit;
}

$stmt->bind_param(
    "ssssssss",
    $student_id,
    $employee_number,
    $title,
    $session,
    $datetime,
    $description,
    $location,
    $status
);

$ok = $stmt->execute();

if ($ok) {
    echo json_encode([
        'status' => true,
        'message' => 'Jadwal berhasil dibuat'
    ]);
} else {
    echo json_encode([
        'status' => false,
        'message' => 'Gagal menyimpan jadwal: ' . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
