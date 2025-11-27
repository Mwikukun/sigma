<?php
include 'cors.php';
include 'config_api.php';

$docId = $_POST["document_id"];
$status = $_POST["status"];

$query = $conn->prepare("UPDATE documents SET status = ? WHERE id = ?");
$query->bind_param("si", $status, $docId);
$query->execute();

echo json_encode(["success" => true]);
