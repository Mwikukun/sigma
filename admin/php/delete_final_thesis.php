<?php
header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$id = $_GET['id'] ?? 0;
mysqli_query($conn, "DELETE FROM final_thesises WHERE id = $id");

echo json_encode(["status" => "success"]);
