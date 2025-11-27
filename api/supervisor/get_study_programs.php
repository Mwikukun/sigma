<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
include '../config_api.php';
$result = mysqli_query($conn, "SELECT title FROM study_programs");
$data = [];
while($row = mysqli_fetch_assoc($result)) {
  $data[] = $row;
}
echo json_encode(["success"=>true, "data"=>$data]);
?>
