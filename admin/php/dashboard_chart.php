<?php
header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$pending = mysqli_fetch_assoc(
    mysqli_query($conn, "SELECT COUNT(*) total FROM documents WHERE status = 'pending'")
)['total'];

$approved = mysqli_fetch_assoc(
    mysqli_query($conn, "SELECT COUNT(*) total FROM documents WHERE status = 'approved'")
)['total'];

$revision = mysqli_fetch_assoc(
    mysqli_query($conn, "SELECT COUNT(*) total FROM documents WHERE status = 'revision'")
)['total'];

echo json_encode([
    "pending" => $pending,
    "approved" => $approved,
    "revised" => $revision
]);
