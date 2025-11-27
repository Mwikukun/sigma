<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
include '../config_api.php';
$result = mysqli_query($conn, "SELECT DISTINCT expertise FROM lecturers WHERE expertise IS NOT NULL AND expertise != ''");
$data = [];
while($row = mysqli_fetch_assoc($result)) {
  $data[] = $row;
}
echo json_encode(["success"=>true, "data"=>$data]);
?>
