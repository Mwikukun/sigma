<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include '../config_api.php';

// Ambil lecturer_id
$input = json_decode(file_get_contents("php://input"), true);
$lecturer_id = $_POST['lecturer_id'] 
    ?? ($_GET['lecturer_id'] ?? ($input['lecturer_id'] ?? null));

if (!$lecturer_id) {
    echo json_encode(['status' => false, 'message' => 'lecturer_id tidak dikirim']);
    exit;
}

// AMBIL JADWAL YANG SUDAH DISETUJUI
$stmt = $conn->prepare("
    SELECT 
        id, 
        title, 
        session, 
        datetime, 
        description, 
        location, 
        status 
    FROM schedules 
    WHERE lecture_id = ? 
      AND status = 'approved'
    ORDER BY datetime ASC
");

$stmt->bind_param("s", $lecturer_id);
$stmt->execute();
$result = $stmt->get_result();

$schedules = [];
while ($row = $result->fetch_assoc()) {
    $row['description'] = $row['description'] ?? '';
    $row['location'] = $row['location'] ?? '';
    $schedules[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode([
    'status' => true,
    'count' => count($schedules),
    'lecturer_id' => $lecturer_id,
    'data' => $schedules,
    'message' => count($schedules) > 0 
        ? 'Data jadwal ditemukan' 
        : 'Belum ada jadwal untuk dosen ini'
]);
?>
