<?php
include 'config_api.php';
include 'cors.php';

// support POST & GET
$lecturer_id = $_POST['lecturer_id'] 
    ?? $_GET['lecturer_id'] 
    ?? null;

if (!$lecturer_id) {
    echo json_encode([
        "success" => false,
        "message" => "lecturer_id is required"
    ]);
    exit;
}

/*
    JOIN TABLES:
    notifications.student_id → students.student_number
    students.user_id → users.id
*/

$query = $conn->prepare("
    SELECT 
        n.id,
        n.student_id,
        u.name AS student_name,
        n.title,
        n.description
    FROM notifications n
    LEFT JOIN students s ON n.student_id = s.student_number
    LEFT JOIN users u ON s.user_id = u.id
    WHERE n.lecturer_id = ?
    ORDER BY n.id DESC
");

$query->bind_param("i", $lecturer_id);
$query->execute();
$result = $query->get_result();

$notifications = [];
while ($row = $result->fetch_assoc()) {
    $notifications[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $notifications
]);
