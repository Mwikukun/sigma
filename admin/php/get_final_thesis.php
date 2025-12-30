<?php
header("Content-Type: application/json");

require_once "guard.php";
require_once "config.php";

$query = "
SELECT 
  ft.id,
  s.student_number AS nim,
  us.name AS pemilik,
  ul.name AS dosen,
  s.thesis AS judul_ta,
  ft.file AS nama_dokumen,
  ft.created_at AS waktu_upload
FROM final_thesises ft
JOIN students s 
  ON ft.student_id = s.student_number
JOIN users us 
  ON s.user_id = us.id
LEFT JOIN (
  SELECT g1.*
  FROM guidances g1
  JOIN (
    SELECT student_id, MAX(created_at) AS last_guidance
    FROM guidances
    WHERE is_approved != 0
    GROUP BY student_id
  ) g2
    ON g1.student_id = g2.student_id
   AND g1.created_at = g2.last_guidance
) g
  ON g.student_id = s.student_number
LEFT JOIN lecturers l 
  ON g.lecturer_id = l.employee_number
LEFT JOIN users ul 
  ON l.user_id = ul.id
ORDER BY ft.created_at DESC
";

$result = mysqli_query($conn, $query);

$data = [];
while ($row = mysqli_fetch_assoc($result)) {
  $data[] = $row;
}

echo json_encode($data);
