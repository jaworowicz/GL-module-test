<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
// Plik: /includes/auth.php
// Wersja 4.3 FINALNA - Dodano natychmiastową weryfikację parametru SFID z adresu URL.

if (session_status() === PHP_SESSION_NONE) {
    ini_set('session.cookie_lifetime', 86400);
    ini_set('session.cookie_path', '/');
    ini_set('session.cookie_domain', '');
    ini_set('session.cookie_secure', isset($_SERVER['HTTPS']));
    ini_set('session.cookie_httponly', true);
    ini_set('session.cookie_samesite', 'Lax');
    session_start();
}

require_once __DIR__.'/db.php';

if (!function_exists('auth_log_audit')) {
    function auth_log_audit(PDO $pdo, ?int $user_id, string $action, array $details) {
        $details['ip_address'] = $_SERVER['REMOTE_ADDR'] ?? 'UNKNOWN';
        try {
            $stmt = $pdo->prepare("INSERT INTO audit_logs (user_id, action, details) VALUES (?, ?, ?)");
            $stmt->execute([$user_id, $action, json_encode($details, JSON_UNESCAPED_UNICODE)]);
        } catch (PDOException $e) { error_log("Błąd zapisu do audit_logs: " . $e->getMessage()); }
    }
}

if (!function_exists('verify_session_integrity')) {
    function verify_session_integrity(PDO $pdo) {
        if (isset($_SESSION['user_id'])) {
            if (!isset($_SESSION['role'], $_SESSION['sfid_id'], $_SESSION['email'], $_SESSION['user_agent'])) {
                session_unset(); session_destroy(); header("Location: /modules/auth/login.php?error=incomplete_session"); exit();
            }
            try {
                $stmt = $pdo->prepare("SELECT role, sfid_id, email FROM users WHERE id = ?");
                $stmt->execute([$_SESSION['user_id']]);
                $authoritative_data = $stmt->fetch(PDO::FETCH_ASSOC);

                $is_tampered = false;
                $log_action = 'session_tampering_detected';

                if (!$authoritative_data ||
                    $authoritative_data['role'] !== $_SESSION['role'] ||
                    $authoritative_data['email'] !== $_SESSION['email']) {
                    $is_tampered = true;
                }

                if ($authoritative_data && $authoritative_data['role'] !== 'superadmin') {
                    // Sprawdzanie SFID w sesji
                    if ($authoritative_data['sfid_id'] != $_SESSION['sfid_id']) {
                        $is_tampered = true;
                    }

                    // ### NOWY BLOK: Natychmiastowa weryfikacja SFID z adresu URL ###
                    // Sprawdza, czy w adresie URL podano SFID i czy jest on inny niż ten przypisany do admina w bazie.
                    if (isset($_GET['sfid']) && $_GET['sfid'] != $authoritative_data['sfid_id']) {
                        $is_tampered = true;
                        $log_action = 'sfid_url_tampering_detected';
                    }
                    // ### KONIEC NOWEGO BLOKU ###
                }

                $is_hijacked = $_SESSION['user_agent'] !== $_SERVER['HTTP_USER_AGENT'];
                if ($is_hijacked) {
                    $log_action = 'session_hijacking_detected';
                }
                
                if ($is_tampered || $is_hijacked) {
                    $log_details = ['session_data' => ['role' => $_SESSION['role'], 'sfid_id' => $_SESSION['sfid_id'], 'email' => $_SESSION['email']], 'database_data' => $authoritative_data];
                    if ($log_action === 'sfid_url_tampering_detected') {
                        $log_details['requested_sfid'] = $_GET['sfid'];
                    }
                    if ($is_hijacked) { $log_details['session_user_agent'] = $_SESSION['user_agent']; $log_details['current_user_agent'] = $_SERVER['HTTP_USER_AGENT']; }
                    auth_log_audit($pdo, $_SESSION['user_id'], $log_action, $log_details);
                    session_unset(); session_destroy();
                    header("Location: /modules/auth/login.php?error=" . ($is_tampered ? 'tampering' : 'hijacked'));
                    exit();
                }
            } catch (PDOException $e) {
                session_unset(); session_destroy(); header("Location: /modules/auth/login.php?error=db_error"); exit();
            }
        }
    }
}

if (isset($_SESSION['user_id'])) {
    verify_session_integrity($pdo);
}

function auth_require_login() {
    if (!is_logged_in()) {
        header('Location: /modules/auth/login.php?error=login_required');
        exit;
    }
}

if (!defined('IS_PUBLIC_PAGE')) {
    auth_require_login();
}

function is_logged_in() {
    return isset($_SESSION['user_id']);
}

function is_superadmin() {
    return isset($_SESSION['role']) && $_SESSION['role'] === 'superadmin';
}

function is_admin() {
    return isset($_SESSION['role']) && ($_SESSION['role'] === 'admin' || $_SESSION['role'] === 'superadmin');
}

function require_admin() {
    if (!is_admin()) {
        $_SESSION['error'] = 'Nie jesteś administratorem!';
        header('Location: /after-login.php');
        die();
    }
}

function check_login() {
    if (!is_logged_in()) {
        $_SESSION['error'] = 'Tylko dla zalogowanych :)';
        header('Location: /modules/auth/login.php');
        exit;
    }
}

function require_superadmin() {
    if (!isset($_SESSION['role']) || $_SESSION['role'] !== 'superadmin') {
        $_SESSION['error'] = 'Tylko SuperAdmin!';
        header('Location: /after-login.php');
        die();
    }
}

function require_sfid_owner($sfid_id) {
    if ($_SESSION['role'] !== 'superadmin' && $_SESSION['sfid_id'] != $sfid_id) {
        header('HTTP/1.1 403 Forbidden');
        die("Brak uprawnień do tej lokalizacji");
    }
}

function check_admin_access() {
    if (!isset($_SESSION['role']) || 
        ($_SESSION['role'] !== 'admin' && $_SESSION['role'] !== 'superadmin')) {
        header('HTTP/1.1 403 Forbidden');
        die("Brak uprawnień administratora");
    }
}

if (!function_exists('is_admin_or_superadmin')) {
    function is_admin_or_superadmin() {
        if (!isset($_SESSION['role'])) {
            return false;
        }
        return in_array($_SESSION['role'], ['admin', 'superadmin']);
    }
}

function create_email_body($template_path, $data = []) {
    if (!file_exists($template_path)) {
        return "Błąd: Nie znaleziono pliku szablonu e-maila.";
    }
    global $appSettings;
    $data['appSettings'] = $appSettings;
    extract($data, EXTR_SKIP);
    ob_start();
    include $template_path;
    $email_content = ob_get_clean();
    return $email_content;
}

/**
 * NOWA FUNKCJA
 * Wymusza uprawnienia admina dla endpointów API.
 * W przypadku braku uprawnień, kończy działanie skryptu z błędem 403 i odpowiedzią JSON.
 */
if (!function_exists('require_admin_api')) {
    function require_admin_api() {
        if (!is_admin()) {
            http_response_code(403); // Forbidden
            if (!headers_sent()) {
                header('Content-Type: application/json');
            }
            die(json_encode([
                'status' => 'error',
                'message' => 'Brak uprawnień administratora.'
            ]));
        }
    }
}

/**
 * Zabezpiecza endpoint API, wymuszając zapytanie AJAX.
 * Wersja poprawiona: Obsługuje parametr włączający/wyłączający ORAZ stałą INTERNAL_API_TEST.
 *
 * @param bool $enabled Flaga włączająca (true) lub wyłączająca (false) zabezpieczenie. Domyślnie włączone.
 */
if (!function_exists('ajaxSecurity')) {
    function ajaxSecurity(bool $enabled = true) {
        // Zabezpieczenie jest wyłączone, jeśli:
        // 1. Wywołano funkcję z parametrem false: ajaxSecurity(false)
        // 2. Lub zdefiniowano stałą dla wewnętrznego testera.
        if ($enabled === false || (defined('INTERNAL_API_TEST') && INTERNAL_API_TEST === true)) {
            return;
        }

        if (empty($_SERVER['HTTP_X_REQUESTED_WITH']) || strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) != 'xmlhttprequest') {
            http_response_code(403);
            if (!headers_sent()) {
                header('Content-Type: application/json');
            }
            die(json_encode(['status' => 'error', 'message' => 'Brak bezpośredniego dostępu.']));
        }
    }
}
?>