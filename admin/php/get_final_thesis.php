<?php
header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$query = "
SELECT 
  ft.id,
  ft.file AS nama_dokumen,
  u.name AS pemilik,
  s.thesis AS judul_ta,
  ft.created_at AS waktu_upload
FROM final_thesises ft
JOIN students s ON ft.student_id = s.student_number
JOIN users u ON s.user_id = u.id
ORDER BY ft.created_at DESC
";

$result = mysqli_query($conn, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
  $data[] = $row;
}

echo json_encode($data);
