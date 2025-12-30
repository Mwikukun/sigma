<?php
include 'cors.php';
include 'config_api.php';

$query = "SELECT id, title, start_date, end_date, description, link, created_at 
          FROM announcements 
          ORDER BY created_at DESC";

$result = mysqli_query($conn, $query);

$data = [];

while ($row = mysqli_fetch_assoc($result)) {
    $data[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $data
]);
