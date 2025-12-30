<?php
include 'cors.php';
require_once("config_api.php");

$student_number = $_POST['student_number'];
$name = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone_number'];

// ambil user_id
$q = mysqli_query($conn, "
  SELECT user_id FROM students WHERE student_number='$student_number'
");

$row = mysqli_fetch_assoc($q);
$user_id = $row['user_id'];

mysqli_query($conn, "
  UPDATE users SET
    name='$name',
    email='$email',
    phone_number='$phone'
  WHERE id='$user_id'
");

echo json_encode([
  "success" => true
]);
