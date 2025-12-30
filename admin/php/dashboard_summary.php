<?php
session_start();
header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

// TOTAL USERS
$totalUsers = mysqli_fetch_assoc(
    mysqli_query($conn, "SELECT COUNT(*) total FROM users")
)['total'];

// TOTAL FINAL THESIS
$totalDocs = mysqli_fetch_assoc(
    mysqli_query($conn, "SELECT COUNT(*) total FROM final_thesises")
)['total'];

// PENDING REVIEW
$pendingDocs = mysqli_fetch_assoc(
    mysqli_query($conn, "SELECT COUNT(*) total FROM documents WHERE status='pending'")
)['total'];

// ACTIVE ANNOUNCEMENT
$activeAnn = mysqli_fetch_assoc(
    mysqli_query($conn, "
        SELECT COUNT(*) total 
        FROM announcements 
        WHERE CURDATE() BETWEEN start_date AND end_date
    ")
)['total'];

echo json_encode([
    "total_users" => $totalUsers,
    "total_documents" => $totalDocs,
    "pending_documents" => $pendingDocs,
    "active_announcements" => $activeAnn
]);
