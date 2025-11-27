<?php
include '../config_api.php';
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json; charset=utf-8');


$lecturer_id = $_GET['lecturer_id'] ?? '';

if (!$lecturer_id) {
    echo json_encode(["success" => false, "message" => "No lecturer_id"]);
    exit;
}

$query = "
    SELECT 
        s.id,
        s.student_id,
        u.name AS student_name,
        s.title,
        s.session,
        s.datetime,
        s.description,
        s.location,
        s.status
    FROM schedules s
    INNER JOIN students st ON st.student_number = s.student_id
    INNER JOIN users u ON u.id = st.user_id
    WHERE s.lecture_id = ?
      AND s.status = 'pending'
    ORDER BY s.datetime ASC
";

$stmt = $conn->prepare($query);
$stmt->bind_param("s", $lecturer_id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $data
]);
