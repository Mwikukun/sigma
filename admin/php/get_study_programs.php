<?php
include "config.php";
header("Content-Type: application/json");

$query = "SELECT id, title FROM study_programs ORDER BY id ASC";
$result = mysqli_query($conn, $query);

$programs = [];
while ($row = mysqli_fetch_assoc($result)) {
    $programs[] = $row;
}

echo json_encode($programs);
?>
