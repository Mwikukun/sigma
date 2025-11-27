<?php
include 'cors.php';
include "config_api.php";

$student_id = $_POST['student_id'] ?? null;
$chapter = $_POST['chapter'] ?? null;

if (!$student_id || !$chapter) {
    echo json_encode(["success"=>false]);
    exit;
}

$q = "
SELECT *
FROM documents
WHERE student_id = ? AND chapter = ?
ORDER BY id ASC
";

$stmt = $conn->prepare($q);
$stmt->bind_param("is", $student_id, $chapter);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
$version = 1;

while ($row = $res->fetch_assoc()) {
    $row['version'] = $version++;
    $data[] = $row;
}

echo json_encode(["success"=>true, "data"=>$data]);
?>
