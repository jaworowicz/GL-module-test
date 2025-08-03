<?php
// CZĘŚĆ 1: LOGIKA - Wklej na samej górze pliku, PRZED jakimkolwiek kodem HTML

if (isset($_POST['test_header_status'])) {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    
    $status = $_POST['test_header_status'];
    
    if ($status === 'success') {
        $_SESSION['success'] = 'Komunikat sukcesu po przekierowaniu nagłówkiem.';
    } elseif ($status === 'error') {
        $_SESSION['error'] = 'Komunikat błędu po przekierowaniu nagłówkiem.';
    } elseif ($status === 'warning') {
        $_SESSION['warning'] = 'Komunikat ostrzeżenia po przekierowaniu nagłówkiem.';
    }

    // Usuwamy parametr z adresu URL i odświeżamy stronę
    $redirect_url = strtok($_SERVER["REQUEST_URI"], '?');
    header("Location: " . $redirect_url);
    exit; // Zawsze kończymy skrypt po przekierowaniu
}

// Tutaj zaczyna się reszta Twojego pliku (np. error_reporting, require_once 'auth.php' itd.)

// Plik: /includes/header-test.php
// Wersja: 2.2 - Zmieniono nazwę funkcji menu na unikalną (get_app_menu_v2), aby uniknąć konfliktów.

require_once __DIR__.'/../includes/auth.php';

if (session_status() === PHP_SESSION_NONE) { session_start(); }

require_once __DIR__.'/../modules/content/superadmin_functions.php';

// ZMIANA: Nowa, unikalna nazwa funkcji, aby uniknąć konfliktu
function get_app_menu_v2() {
    global $pdo;
    $user_role = $_SESSION['role'] ?? '';

    if (empty($user_role) || !$pdo) {
        return [];
    }
    try {
        $sql = "SELECT * FROM app_menu WHERE FIND_IN_SET(?, roles) ORDER BY order_position ASC";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$user_role]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $e) {
        error_log("Błąd pobierania menu (v2): " . $e->getMessage());
        return [];
    }
}

if (!function_exists('has_pending_pomidor_requests')) {
    function has_pending_pomidor_requests(PDO $pdo, int $sfid_id) {
        $sql = "SELECT 1 FROM pomidor_corrections pc JOIN users u ON pc.employee_id = u.id WHERE pc.status = 'oczekujący' AND pc.deleted_at IS NULL AND u.sfid_id = ? LIMIT 1";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$sfid_id]);
        return $stmt->fetchColumn() !== false;
    }
}

if (!function_exists('has_pending_vacation_requests')) {
    function has_pending_vacation_requests(PDO $pdo, int $sfid_id): bool {
        $sql = "SELECT 1 
                FROM vacations v
                JOIN users u ON v.user_id = u.id
                WHERE v.status = 'pending'
                AND u.sfid_id = ?
                LIMIT 1";
                
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$sfid_id]);
        return $stmt->fetchColumn() !== false;
    }
}


$announcements = [];
$has_pending_requests = false;
$has_pending_vacation_requests = false;
if (isset($_SESSION['user_id'])) {
    try {
        $current_date = date('Y-m-d'); $user_role = $_SESSION['role'] ?? 'user'; $user_sfid = $_SESSION['sfid_id'] ?? null;
        $stmt = $pdo->prepare("SELECT * FROM dashboard_announcements WHERE active = 1 AND (start_date IS NULL OR start_date <= :d_start) AND (end_date IS NULL OR end_date >= :d_end) AND (roles = '*' OR FIND_IN_SET(:r, roles)) AND (sfid_id = :s OR sfid_id = 0 OR sfid_id IS NULL) ORDER BY CASE type WHEN 'danger' THEN 1 WHEN 'warning' THEN 2 ELSE 3 END");
        $stmt->execute([':d_start' => $current_date, ':d_end' => $current_date, ':r' => $user_role, ':s' => $user_sfid]);
        $announcements = $stmt->fetchAll(PDO::FETCH_ASSOC);
        // NOWY FRAGMENT: Przechwytywanie i konwersja wiadomości z sesji
if (isset($_SESSION['error'])) {
    $error_message = [
        'id'      => 'session_error',
        'title'   => 'Błąd!',
        'content' => $_SESSION['error'],
        'type'    => 'danger',
    ];
    array_unshift($announcements, $error_message); // Dodaj na początek tablicy
    unset($_SESSION['error']);
}

if (isset($_SESSION['success'])) {
    $success_message = [
        'id'      => 'session_success',
        'title'   => 'Sukces!',
        'content' => $_SESSION['success'],
        'type'    => 'success',
    ];
    array_unshift($announcements, $success_message); // Dodaj na początek tablicy
    unset($_SESSION['success']);
}

// Wklej ten fragment w /includes/header-test.php

if (isset($_SESSION['warning'])) {
    $warning_message = [
        'id'      => 'session_warning',
        'title'   => 'Uwaga!',
        'content' => $_SESSION['warning'],
        'type'    => 'warning',
    ];
    array_unshift($announcements, $warning_message);
    unset($_SESSION['warning']);
}

        if (in_array($_SESSION['role'], ['admin', 'superadmin'])) {
            $has_pending_requests = has_pending_pomidor_requests($pdo, $_SESSION['sfid_id']);
            $has_pending_vacation_requests = has_pending_vacation_requests($pdo, $_SESSION['sfid_id']);
        } 
    } catch (PDOException $e) { error_log("Błąd ogłoszeń: " . $e->getMessage()); }
}
$userName = $_SESSION['name'] ?? 'Użytkownik';
$announcement_styles = [
    'danger'  => ['icon' => 'mdi-alert-octagon', 'colors' => 'bg-red-500/10 text-red-300 border-red-500/30'],
    'warning' => ['icon' => 'mdi-alert', 'colors' => 'bg-yellow-500/10 text-yellow-300 border-yellow-500/30'],
    'success' => ['icon' => 'mdi-check-circle', 'colors' => 'bg-green-500/10 text-green-300 border-green-500/30'],
    'info'    => ['icon' => 'mdi-information', 'colors' => 'bg-sky-500/10 text-sky-300 border-sky-500/30'],
];
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= $page_title ?? 'GrafikLiberty' ?></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/@mdi/font@7.2.96/css/materialdesignicons.min.css" rel="stylesheet">
    <style>
        html { scroll-behavior: smooth; }
        body { font-family: 'Inter', sans-serif; background: linear-gradient(-45deg, #0f2027, #203a43, #2c5364, #1c3d52); background-size: 400% 400%; animation: gradientBG 15s ease infinite; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }
        .fade-out { transition: opacity 0.5s ease-out, transform 0.5s ease-out; opacity: 0; transform: translateY(-20px); }
        @keyframes shake-aggressive { 0%, 100% { transform: translateX(0); } 10%, 30%, 50%, 70%, 90% { transform: translateX(-8px); } 20%, 40%, 60%, 80% { transform: translateX(8px); } }
        .animate-shake-aggressive { animation: shake-aggressive 0.7s cubic-bezier(.36,.07,.19,.97) both; }
        @keyframes pulse-aggressive { 0%, 100% { transform: scale(1); opacity: 1; } 50% { transform: scale(1.05); opacity: 0.8; } }
        .animate-pulse-aggressive { animation: pulse-aggressive 1.5s ease-in-out infinite; }
    </style>
    
    <script>
    document.addEventListener('DOMContentLoaded', () => {
        const announcementContainer = document.getElementById('announcement-container');
        if (announcementContainer) {
            const ANNOUNCEMENT_STORAGE_KEY = 'dismissedAnnouncements';
            const showDismissedBtn = document.getElementById('show-dismissed-btn');
            const showDismissedContainer = document.getElementById('show-dismissed-container');
            function getDismissedAnnouncements() { const stored = sessionStorage.getItem(ANNOUNCEMENT_STORAGE_KEY); return stored ? JSON.parse(stored) : []; }
            function updateShowButtonVisibility() { if (showDismissedContainer) { if (getDismissedAnnouncements().length > 0) { showDismissedContainer.classList.remove('hidden'); } else { showDismissedContainer.classList.add('hidden'); } } }
            function dismissAnnouncement(announcementId) { const dismissed = getDismissedAnnouncements(); if (!dismissed.includes(announcementId)) { dismissed.push(announcementId); sessionStorage.setItem(ANNOUNCEMENT_STORAGE_KEY, JSON.stringify(dismissed)); updateShowButtonVisibility(); } }
            const dismissedIdsOnLoad = getDismissedAnnouncements();
            dismissedIdsOnLoad.forEach(id => { const banner = document.getElementById(`announcement-${id}`); if (banner) { banner.style.display = 'none'; } });
            document.querySelectorAll('.dismiss-announcement-btn').forEach(button => {
                button.addEventListener('click', () => {
                    const announcementId = button.dataset.id;
                    dismissAnnouncement(announcementId);
                    const banner = document.getElementById(`announcement-${announcementId}`);
                    if (banner) { banner.classList.add('fade-out'); setTimeout(() => banner.remove(), 500); }
                });
            });
            if (showDismissedContainer) { updateShowButtonVisibility(); }
            if (showDismissedBtn) { showDismissedBtn.addEventListener('click', () => { sessionStorage.removeItem(ANNOUNCEMENT_STORAGE_KEY); location.reload(); }); }
        }

        const mobileMenuButton = document.getElementById('mobile-menu-button');
        const mobileMenu = document.getElementById('mobile-menu');
        window.toggleDropdown = function(dropdownId) {
            const dropdown = document.getElementById(dropdownId); if (!dropdown) return;
            const content = dropdown.querySelector('.dropdown-menu-content');
            if (content) { content.classList.toggle('hidden'); }
        }
        if (mobileMenuButton && mobileMenu) { mobileMenuButton.addEventListener('click', () => { mobileMenu.classList.toggle('hidden'); }); }
        document.addEventListener('click', function(event) {
            document.querySelectorAll('.relative[id$="-dropdown-desktop"]').forEach(function(dropdown) { if (!dropdown.contains(event.target)) { dropdown.querySelector('.dropdown-menu-content')?.classList.add('hidden'); } });
            if (mobileMenu && mobileMenuButton && !mobileMenu.contains(event.target) && !mobileMenuButton.contains(event.target)) { mobileMenu.classList.add('hidden'); }
        });
    });
    </script>
</head>
<body class="bg-slate-900 text-white antialiased">
<nav class="sticky top-0 z-50 bg-slate-900/70 backdrop-blur-lg border-b border-slate-700/50">
    <div class="container mx-auto px-4"><div class="flex items-center justify-between h-16"><div class="flex items-center"><a href="/" class="flex items-center space-x-2 text-white font-semibold"><!--<i class="mdi mdi-calendar-multiple text-2xl text-blue-400"></i>--><img src="<?= htmlspecialchars($appSettings['logo']) ?>" alt="Logo" style="max-height:32px!important;"><span>GrafikLiberty</span></a></div><div class="hidden md:flex items-center space-x-1">
        
        <?php foreach (get_app_menu_v2() as $item): ?>
            <a href="<?= htmlspecialchars($item['url']) ?>" class="flex items-center px-3 py-2 text-slate-300 hover:text-white rounded-md text-sm font-medium transition-colors"><?= htmlspecialchars($item['name']) ?></a>
        <?php endforeach; ?>

    </div><div class="hidden md:flex items-center"><div class="relative" id="user-dropdown-desktop"><button onclick="toggleDropdown('user-dropdown-desktop')" class="flex items-center space-x-2 text-slate-300 hover:text-white focus:outline-none"><span><?= htmlspecialchars($userName) ?></span><i class="mdi mdi-chevron-down"></i></button><div class="dropdown-menu-content absolute right-0 mt-2 w-48 bg-slate-800 border border-slate-700 rounded-md shadow-lg py-1 hidden"><a href="/profile.php" class="block px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Profil</a><div class="border-t border-slate-700 my-1"></div><a href="/modules/auth/logout.php" class="block px-4 py-2 text-sm text-red-400 hover:bg-slate-700">Wyloguj</a></div></div></div><div class="md:hidden flex items-center"><button id="mobile-menu-button" class="inline-flex items-center justify-center p-2 rounded-md text-slate-400 hover:text-white hover:bg-slate-700 focus:outline-none"><i class="mdi mdi-menu text-2xl"></i></button></div></div></div><div id="mobile-menu" class="md:hidden hidden"><div class="px-2 pt-2 pb-3 space-y-1 sm:px-3">

        <?php foreach (get_app_menu_v2() as $item): ?>
            <a href="<?= htmlspecialchars($item['url']) ?>" class="block px-3 py-2 text-base font-medium text-slate-300 rounded-md hover:bg-slate-700 hover:text-white"><?= htmlspecialchars($item['name']) ?></a>
        <?php endforeach; ?>

    <div class="border-t border-slate-700 mt-4 pt-4"><div class="flex items-center px-3"><div class="text-base font-medium text-white"><?= htmlspecialchars($userName) ?></div></div><div class="mt-3 px-2 space-y-1"><a href="/profile.php" class="block px-3 py-2 text-base font-medium text-slate-300 rounded-md hover:bg-slate-700 hover:text-white">Profil</a><a href="/modules/auth/logout.php" class="block px-3 py-2 text-base font-medium text-red-400 rounded-md hover:bg-slate-700 hover:text-white">Wyloguj</a></div></div></div></div>
</nav>

<div id="announcement-container" class="container mx-auto px-4 pt-4 space-y-3">
    <?php if ($has_pending_requests && (!isset($is_impersonating) || !$is_impersonating)): ?>
        <div class="announcement-banner flex items-center justify-between p-3 rounded-lg border bg-yellow-500/10 text-yellow-300 border-yellow-500/30 backdrop-blur-sm"><div class="flex items-center"><i class="mdi mdi-alert text-2xl mr-4"></i><div><strong class="font-semibold text-white">Nowe Wnioski!</strong><span class="block text-sm text-slate-300">Oczekujące wnioski "Pomidor" wymagają Twojej akcji.</span></div></div><a href="/modules/pomidor/pomidor_report.php" class="ml-4 text-sm font-bold bg-yellow-400/80 text-slate-900 px-3 py-1 rounded-full hover:bg-yellow-400">Przejdź do panelu</a></div>
    <?php endif; ?>
    <?php if ($has_pending_vacation_requests && (!isset($is_impersonating) || !$is_impersonating)): ?>
        <div class="announcement-banner flex items-center justify-between p-3 rounded-lg border bg-yellow-500/10 text-yellow-300 border-yellow-500/30 backdrop-blur-sm"><div class="flex items-center"><i class="mdi mdi-clock-alert text-2xl mr-4"></i><div><strong class="font-semibold text-white">Wniosek o Urlop!</strong><span class="block text-sm text-slate-300">Oczekujące wnioski "Urlopowe" wymagają Twojej akcji.</span></div></div><a href="/modules/vacations/history-new.php" class="ml-4 text-sm font-bold bg-yellow-400/80 text-slate-900 px-3 py-1 rounded-full hover:bg-yellow-400">Przejdź do panelu</a></div>
    <?php endif; ?>
    <?php foreach ($announcements as $announcement): $style = $announcement_styles[$announcement['type']] ?? $announcement_styles['info']; ?>
    <div id="announcement-<?= $announcement['id'] ?>" class="announcement-banner flex items-center justify-between p-3 rounded-lg border <?= $style['colors'] ?> backdrop-blur-sm"><div class="flex items-center"><i class="mdi <?= $style['icon'] ?> text-2xl mr-4"></i><div><strong class="font-semibold text-white"><?= htmlspecialchars($announcement['title']) ?></strong><span class="block text-sm text-slate-300"><?= htmlspecialchars($announcement['content']) ?></span></div></div><button class="dismiss-announcement-btn ml-4 text-white/50 hover:text-white/100" data-id="<?= $announcement['id'] ?>"><i class="mdi mdi-close"></i></button></div>
    <?php endforeach; ?>
    <div id="show-dismissed-container" class="hidden text-center pt-2"><button id="show-dismissed-btn" class="inline-flex items-center px-4 py-2 bg-slate-700/50 border border-slate-600 rounded-full text-sm font-medium text-slate-300 hover:bg-slate-700 hover:text-white transition-colors duration-300"><i class="mdi mdi-eye-outline mr-2"></i>Pokaż ukryte ogłoszenia</button></div>
</div>