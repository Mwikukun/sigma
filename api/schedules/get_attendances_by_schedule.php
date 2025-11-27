<?php
include '../config_api.php';
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json; charset=utf-8');

// Preflight (biar Flutter ga error)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$schedule_id = $_GET['schedule_id'] ?? null;
$lecturer_id = $_GET['lecturer_id'] ?? null;

if (!$schedule_id || !is_numeric($schedule_id)) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Parameter schedule_id wajib dikirim dan harus angka.'
    ]);
    exit;
}

if (!$lecturer_id || !is_numeric($lecturer_id)) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Parameter lecturer_id wajib dikirim dan harus angka.'
    ]);
    exit;
}

$query = "
    SELECT 
        g.student_id,
        u.name AS student_name,
        u.username AS nim,
        sp.title AS major,
        s.thesis AS project,
        COALESCE(a.status, 'unconfirmed') AS status,
        COALESCE(a.reason, '') AS reason
    FROM guidances g
    JOIN students s ON g.student_id = s.student_number
    JOIN users u ON s.user_id = u.id
    LEFT JOIN study_programs sp 
        ON sp.id = (SELECT study_program_id 
                    FROM lecturers 
                    WHERE employee_number = g.lecturer_id LIMIT 1)
    LEFT JOIN schedule_attendances a 
        ON a.student_id = g.student_id AND a.schedule_id = ?
    WHERE g.is_approved = 1
      AND g.lecturer_id = ?
    ORDER BY u.name ASC
";

$stmt = $conn->prepare($query);
$stmt->bind_param("ii", $schedule_id, $lecturer_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {

    // Normalisasi status supaya match Flutter
    $status = strtolower(trim($row['status']));

    if ($status === "attend") $status = "hadir";
    if ($status === "absent") $status = "tidak_hadir";
    if ($status === "unconfirmed") $status = "belum_konfirmasi";

    $data[] = [
        'student_id' => $row['student_id'],
        'name' => $row['student_name'],
        'nim' => $row['nim'],
        'major' => $row['major'] ?? '-',
        'project' => $row['project'] ?? '-',
        'status' => $status,
        'reason' => $row['reason'] ?? '',
    ];
}

$stmt->close();
$conn->close();

echo json_encode([
    'status' => 'success',
    'schedule_id' => (int)$schedule_id,
    'lecturer_id' => (int)$lecturer_id,
    'count' => count($data),
    'data' => $data
]);
?>
