<?php
// Plik: /modules/auth/login.php
// Wersja FINALNA 2.1 - Dodano link do rejestracji.

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

define('IS_PUBLIC_PAGE', true);
require_once __DIR__.'/../../includes/auth.php'; 
require_once __DIR__.'/../../includes/functions.php';

if (is_logged_in()) {
    header('Location: /after-login.php');
    exit;
}

$error = '';
$success = '';

if (isset($_SESSION['success'])) {
    $success = $_SESSION['success'];
    unset($_SESSION['success']);
}
if (isset($_SESSION['error'])) {
    $error = $_SESSION['error'];
    unset($_SESSION['error']);
}

if (isset($_GET['error'])) {
    if ($_GET['error'] === 'suspended') $error = 'Twoje konto zostało zawieszone. Skontaktuj się z administratorem.';
    if ($_GET['error'] === 'tampering' || $_GET['error'] === 'hijacked') $error = 'Wykryto manipulację uprawnieniami. Incydent został zgłoszony.';
    if ($_GET['error'] === 'incomplete_session') $error = 'Twoja sesja wygasła lub jest niekompletna. Zaloguj się ponownie.';
    if ($_GET['error'] === 'login_required') $error = 'Dostęp do tej strony wymaga zalogowania.';
    if ($_GET['error'] === 'registration_disabled') $error = 'Rejestracja jest tymczasowo wyłączona.';
}
if (isset($_GET['success'])) {
    if ($_GET['success'] === 'logged_out') $success = 'Zostałeś poprawnie wylogowany.';
}

generate_csrf_token();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        if (!verify_csrf_token($_POST['csrf_token'])) {
            auth_log_audit($pdo, null, 'login_failed', ['reason' => 'invalid_csrf', 'email' => $_POST['email'] ?? '']);
            throw new Exception("Nieprawidłowy token CSRF");
        }
        $email = validate_input($_POST['email']);
        $password = $_POST['password'];

        $stmt = $pdo->prepare("SELECT id, name, email, password_hash, role, sfid_id, is_active FROM users WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if ($user && password_verify($password, $user['password_hash'])) {
            if ($user['is_active'] == 1) {
                session_regenerate_id(true);
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['role'] = $user['role'];
                $_SESSION['sfid_id'] = $user['sfid_id'];
                $_SESSION['email'] = $user['email'];
                $_SESSION['username'] = strtok($user['name'], ' ');
                $_SESSION['user_agent'] = $_SERVER['HTTP_USER_AGENT'];

                $pdo->prepare("UPDATE users SET last_login = NOW() WHERE id = ?")->execute([$user['id']]);
                header('Location: /after-login.php');
                exit;
            } else {
                auth_log_audit($pdo, $user['id'], 'login_failed', ['reason' => 'account_suspended']);
                throw new Exception("Twoje konto zostało zawieszone. Skontaktuj się z administratorem.");
            }
        } else {
            auth_log_audit($pdo, null, 'login_failed', ['reason' => 'invalid_credentials', 'email' => $email]);
            throw new Exception("Nieprawidłowy email lub hasło");
        }
    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <title>Logowanie - <?= htmlspecialchars($appSettings['name']) ?></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font@7.4.47/css/materialdesignicons.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: linear-gradient(-45deg, #0f2027, #203a43, #2c5364, #1c3d52); background-size: 400% 400%; animation: gradientBG 15s ease infinite; }
        @keyframes gradientBG { 0% { background-position: 0% 50%; } 50% { background-position: 100% 50%; } 100% { background-position: 0% 50%; } }
    </style>
</head>
<body class="bg-slate-900 text-white antialiased">
<div class="flex min-h-screen flex-col items-center justify-center p-4">
    <div class="w-full max-w-md bg-slate-800/60 backdrop-blur-lg border border-slate-700 rounded-2xl p-8 shadow-xl">
        <div class="text-center mb-6">
            <a href="/" class="inline-block mb-4"><img src="<?= htmlspecialchars($appSettings['logo']) ?>" alt="Logo" class="h-16 w-16"></a>
            <h1 class="text-2xl font-bold text-white">Witaj ponownie!</h1>
            <p class="text-slate-400 mt-1">Zaloguj się, aby kontynuować.</p>
        </div>

        <?php if (!empty($error)): ?>
            <div class="mb-4 flex items-center p-4 rounded-lg bg-slate-800 text-red-300 border-l-4 border-red-500" role="alert">
                <i class="mdi mdi-alert-octagon text-2xl mr-3"></i>
                <span class="text-sm font-medium"><?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>

        <?php if (!empty($success)): ?>
            <div class="mb-4 flex items-center p-4 rounded-lg bg-slate-800 text-green-300 border-l-4 border-green-500" role="alert">
                <i class="mdi mdi-check-circle text-2xl mr-3"></i>
                <span class="text-sm font-medium"><?= htmlspecialchars($success) ?></span>
            </div>
        <?php endif; ?>

        <form method="POST" class="space-y-6">
            <input type="hidden" name="csrf_token" value="<?= $_SESSION['csrf_token'] ?? '' ?>">
            <div><label for="email" class="block mb-2 text-sm font-medium text-slate-300">Email</label><input type="email" id="email" name="email" class="w-full bg-slate-700/50 border border-slate-600 text-white rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500" required value="<?= htmlspecialchars($_POST['email'] ?? '') ?>" placeholder="ty@email.com"></div>
            <div><label for="password" class="block mb-2 text-sm font-medium text-slate-300">Hasło</label><input type="password" id="password" name="password" class="w-full bg-slate-700/50 border border-slate-600 text-white rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500" required placeholder="••••••••"></div>
            
            <div class="flex justify-between items-center text-sm">
                <a href="register.php" class="font-medium text-blue-400 hover:text-blue-300">Utwórz konto</a>
                <a href="forgot-password.php" class="font-medium text-slate-400 hover:text-blue-400">Zapomniałeś hasła?</a>
            </div>
            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-lg transition-transform duration-300 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-slate-900 focus:ring-blue-500">Zaloguj się</button>
        </form>
    </div>
    <footer class="absolute bottom-0 py-6 text-center text-slate-400 text-sm w-full">&copy; <?= date('Y') ?> <?= htmlspecialchars($appSettings['name']) ?> | Jakub Jaworowicz <a href="https://jaworowi.cz" target="_blank" class="text-blue-400 hover:text-blue-300">Marketing & WebDevelop</a></footer>
</div>
</body>
</html>