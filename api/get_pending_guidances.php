<?php
include 'cors.php';
require_once("config_api.php");

$lecturer_id = $_POST['lecturer_id'] ?? null;

if (!$lecturer_id) {
    echo json_encode(["success" => false, "message" => "lecturer_id tidak ditemukan"]);
    exit;
}

$query = "
SELECT 
    g.id AS guidance_id,
    g.student_id,
    g.is_approved,
    s.student_number,
    s.thesis AS thesis_title,
    u.name AS student_name
FROM guidances g
JOIN students s ON g.student_id = s.student_number
JOIN users u ON s.user_id = u.id
WHERE g.lecturer_id = ? AND g.is_approved = 0
ORDER BY g.id DESC
";

$stmt = $conn->prepare($query);
$stmt->bind_param("i", $lecturer_id);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode(["success" => true, "data" => $data]);
