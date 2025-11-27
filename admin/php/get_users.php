<?php
include "config.php";
header("Content-Type: application/json");

$query = "
SELECT 
    u.id,
    u.name,
    u.user_type,
    u.phone_number,
    u.email,
    u.username,
    CASE 
        WHEN u.user_type = 'student' THEN s.student_number
        WHEN u.user_type = 'lecturer' THEN l.employee_number
        ELSE NULL
    END AS nim_nik,
    l.study_program_id,
    sp.title AS study_program_title,
    l.expertise
FROM users u
LEFT JOIN students s ON u.id = s.user_id
LEFT JOIN lecturers l ON u.id = l.user_id
LEFT JOIN study_programs sp ON l.study_program_id = sp.id
ORDER BY u.id DESC
";

$result = mysqli_query($conn, $query);
$users = [];

while ($row = mysqli_fetch_assoc($result)) {
    $users[] = $row;
}

echo json_encode($users);
?>
