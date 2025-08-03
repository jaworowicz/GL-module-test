<?php
define('DB_HOST', 'localhost');
define('DB_NAME', 'horusjcz_liberty');
define('DB_USER', 'horusjcz_liberty');
define('DB_PASS', 'ewyK8HGeYBFgcFUUrPkn');

try {
    // Połączenie z bazą danych
    $pdo = new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    // Obsługa błędów połączenia
    if (DEBUG_MODE) {
        die("Błąd połączenia z bazą danych: " . $e->getMessage());
    } else {
        die("Błąd połączenia z bazą danych. Skontaktuj się z administratorem.");
    }
}

// Inicjalizacja globalnej tablicy na ustawienia
$appSettings = [
    'name' => 'GrafikLiberty', // Wartości domyślne
    'logo' => '/assets/images/logo.png',
    'domain' => 'https://workerty.eu' // Domyślna domena
];

try {
    // Pobierz wszystkie ustawienia jednym zapytaniem
    $settings_stmt = $pdo->query("SELECT setting_key, setting_value FROM app_settings");
    $all_settings = $settings_stmt->fetchAll(PDO::FETCH_KEY_PAIR);

    // Przetwórz pobrane ustawienia
    if (!empty($all_settings)) {
        // Ustawienia ogólne aplikacji (nazwa, logo)
        if (isset($all_settings['app_info'])) {
            $app_info_decoded = json_decode($all_settings['app_info'], true);
            $appSettings['name'] = $app_info_decoded['name'] ?? $appSettings['name'];
            $appSettings['logo'] = $app_info_decoded['logo'] ?? $appSettings['logo'];
        }
        
        // NOWE: Ustawienie domeny aplikacji
        if (isset($all_settings['app_domain'])) {
            // Usuwamy cudzysłowy, które json_encode dodaje do stringów
            $appSettings['domain'] = trim(json_decode($all_settings['app_domain']), '"');
        }
    }
} catch (PDOException $e) {
    // W przypadku błędu bazy, logujemy go, ale nie przerywamy działania aplikacji
    error_log("Błąd pobierania ustawień aplikacji: " . $e->getMessage());
}

?>
