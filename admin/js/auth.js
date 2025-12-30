// ===== GLOBAL BASE URL (WAJIB DI ATAS) =====
window.BASE_URL = "http://localhost/SIGMA/admin/php/";

document.addEventListener("DOMContentLoaded", async () => {
  await checkAuth();
});

async function checkAuth() {
  try {
    const res = await fetch(BASE_URL + "check_auth.php", {
      credentials: "include",
    });

    if (!res.ok) throw new Error();

    const data = await res.json();

    if (!data.authenticated) {
      window.location.replace("login_admin.html");
    }
  } catch {
    window.location.replace("login_admin.html");
  }
}
