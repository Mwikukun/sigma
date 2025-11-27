<?php
include 'cors.php';


$file_a = $_POST['file_a'] ?? null;
$file_b = $_POST['file_b'] ?? null;

$dir = "uploads/documents/";

$pathA = $dir.$file_a;
$pathB = $dir.$file_b;

if (!file_exists($pathA) || !file_exists($pathB)) {
    echo json_encode(["success"=>false,"message"=>"file not found"]);
    exit;
}

$sha1_a = sha1_file($pathA);
$sha1_b = sha1_file($pathB);

echo json_encode([
    "success" => true,
    "same" => ($sha1_a === $sha1_b),
    "hash_a" => $sha1_a,
    "hash_b" => $sha1_b
]);
?>
