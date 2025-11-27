<?php
include "config_api.php";

$id = $_POST['id'];
$status = $_POST['status']; // approved / rejected

$q = $conn->query("UPDATE schedules SET status='$status' WHERE id='$id'");

echo json_encode(["status"=>$q ? "success" : "error"]);
?>
