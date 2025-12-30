<?php
header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$query = "
    SELECT
        f.created_at,
        u.name,
        'Final Thesis Uploaded' AS title,
        'uploaded' AS status
    FROM final_thesises f
    JOIN students s ON s.student_number = f.student_id
    JOIN users u ON u.id = s.user_id
    ORDER BY f.created_at DESC
    LIMIT 5
";

$result = mysqli_query($conn, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode($data);
