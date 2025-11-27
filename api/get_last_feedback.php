<?php
include 'cors.php';
include 'config_api.php';

$document_id = $_GET['document_id'] ?? 0;

$query = $conn->prepare("
    SELECT 
        id, 
        document_id, 
        comment, 
        attachment,
        
        -- ❗ URL PERBAIKAN – pakai 'feedbacks' (pakai S)
        CONCAT('http://127.0.0.1/SIGMA/uploads/feedbacks/', attachment) AS attachment_url

    FROM document_feedbacks
    WHERE document_id = ?
    ORDER BY id DESC
    LIMIT 1
");

$query->bind_param("i", $document_id);
$query->execute();

$data = $query->get_result()->fetch_assoc();

echo json_encode([
    "success" => true,
    "data" => $data
]);
