<?php
include 'config_api.php';
include 'cors.php';

// Pastikan student_id dikirim
if (!isset($_GET['student_id'])) {
    echo json_encode([
        'status' => 'error',
        'message' => 'student_id parameter is required'
    ]);
    exit;
}

$student_id = $_GET['student_id'];

// Gunakan prepared statement untuk keamanan
$stmt = $conn->prepare("
    SELECT 
        s.id,
        s.title,
        s.session,
        s.datetime,
        s.description,
        s.location,
        s.status
    FROM schedules s
    JOIN lecturers l ON s.lecture_id = l.employee_number
    JOIN guidances g ON g.lecturer_id = l.employee_number
    WHERE g.student_id = ?
      AND g.is_approved = 1
      AND s.status = 'approved'
    ORDER BY s.datetime DESC
");

$stmt->bind_param("s", $student_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

// Format output JSON
if (empty($data)) {
    echo json_encode([
        'status' => 'success',
        'message' => 'No schedules found',
        'data' => []
    ]);
} else {
    echo json_encode([
        'status' => 'success',
        'count' => count($data),
        'data' => $data
    ]);
}

$stmt->close();
$conn->close();
?>
