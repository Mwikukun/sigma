<?php
include 'config_api.php';
include 'cors.php';

$lecturer_id = $_GET['lecturer_id'] ?? null;

if (!$lecturer_id) {
  echo json_encode(["success" => false]);
  exit;
}

$data = [];

/* 🔵 Total Mahasiswa Bimbingan (approved) */
$q1 = $conn->prepare("
  SELECT COUNT(*) AS total
  FROM guidances
  WHERE lecturer_id = ?
  AND is_approved = 1
");
$q1->bind_param("i", $lecturer_id);
$q1->execute();
$data['total_students'] = $q1->get_result()->fetch_assoc()['total'];

/* 🟠 Pengajuan Mahasiswa (pending) */
$q2 = $conn->prepare("
  SELECT COUNT(*) AS total
  FROM guidances
  WHERE lecturer_id = ?
  AND is_approved = 0
");
$q2->bind_param("i", $lecturer_id);
$q2->execute();
$data['pending_students'] = $q2->get_result()->fetch_assoc()['total'];

/* 🟣 Pengajuan Jadwal */
$q3 = $conn->prepare("
  SELECT COUNT(*) AS total
  FROM schedules
  WHERE lecture_id = ?
  AND status = 'pending'
");
$q3->bind_param("i", $lecturer_id);
$q3->execute();
$data['pending_schedules'] = $q3->get_result()->fetch_assoc()['total'];

/* 🔴 Dokumen Pending */
$q4 = $conn->prepare("
  SELECT COUNT(*) AS total
  FROM documents d
  JOIN guidances g ON d.student_id = g.student_id
  WHERE g.lecturer_id = ?
  AND d.status = 'pending'
");
$q4->bind_param("i", $lecturer_id);
$q4->execute();
$data['pending_documents'] = $q4->get_result()->fetch_assoc()['total'];

echo json_encode([
  "success" => true,
  "data" => $data
]);
