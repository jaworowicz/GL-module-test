Adding report generation functionality based on templates stored in the /reports/ directory.
```

```php
<?php
require_once '../../includes/auth.php';
require_once '../../includes/db.php';

// Sprawdź czy użytkownik jest zalogowany
auth_require_login();

// Ustaw nagłówki JSON
header('Content-Type: application/json');

// Pobierz akcję
$action = $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'get_counter_data':
            echo json_encode(getCounterData());
            break;

        case 'save_counter_value':
            echo json_encode(saveCounterValue());
            break;

        case 'save_counter_settings':
            echo json_encode(saveCounterSettings());
            break;

        case 'delete_counter':
            echo json_encode(deleteCounter());
            break;

        case 'get_kpi_data':
            echo json_encode(getKpiData());
            break;

        case 'save_kpi_goal':
            echo json_encode(saveKpiGoal());
            break;

        case 'delete_kpi_goal':
            echo json_encode(deleteKpiGoal());
            break;

        case 'save_category':
            echo json_encode(saveCategory());
            break;

        case 'get_kpi_details':
            echo json_encode(getKpiDetails());
            break;

        case 'save_kpi_correction':
            echo json_encode(saveKpiCorrection());
            break;

        case 'save_mass_correction':
            echo json_encode(saveMassCorrection());
            break;

        case 'sort_counters':
            echo json_encode(sortCounters());
            break;

        case 'get_report_templates':
            echo json_encode(getReportTemplates());
            break;

        case 'get_report_preview':
            echo json_encode(getReportPreview($_POST['template'], $_POST['date'], $pdo));
            break;

        case 'generate_report':
            echo json_encode(generateReport($_POST['template'], $_POST['date'], $pdo));
            break;

        default:
            echo json_encode(['success' => false, 'message' => 'Nieznana akcja']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Błąd serwera: ' . $e->getMessage()]);
}

// === FUNKCJE LICZNIKÓW ===

function getCounterData() {
    global $pdo;

    $userId = $_POST['user_id'] ?? $_SESSION['user_id'];
    $date = $_POST['date'] ?? date('Y-m-d');

    // Pobierz liczniki dla tej lokalizacji - POPRAWNE NAZWY KOLUMN
    $query = "
        SELECT
            c.id,
            c.title,
            c.increment,
            c.color,
            c.category_id,
            c.type,
            c.symbol,
            cat.name as category,
            COALESCE(dv.value, 0) as value
        FROM licznik_counters c
        LEFT JOIN licznik_categories cat ON c.category_id = cat.id
        LEFT JOIN licznik_daily_values dv ON c.id = dv.counter_id
            AND dv.user_id = ? AND dv.date = ?
        WHERE c.sfid_id = ? AND c.is_active = 1
        ORDER BY c.sort_order, c.title
    ";

    $stmt = $pdo->prepare($query);
    $stmt->execute([$userId, $date, $_SESSION['sfid_id']]);
    $counters = $stmt->fetchAll(PDO::FETCH_ASSOC);

    return ['success' => true, 'data' => $counters];
}

function saveCounterValue() {
    global $pdo;

    $counterId = $_POST['counter_id'] ?? 0;
    $userId = $_POST['user_id'] ?? $_SESSION['user_id'];
    $date = $_POST['date'] ?? date('Y-m-d');
    $value = max(0, intval($_POST['value'] ?? 0));

    // Sprawdź czy licznik należy do tej lokalizacji
    $checkQuery = "SELECT id FROM licznik_counters WHERE id = ? AND sfid_id = ?";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute([$counterId, $_SESSION['sfid_id']]);

    if (!$checkStmt->fetch()) {
        return ['success' => false, 'message' => 'Nieprawidłowy licznik'];
    }

    // Zapisz lub zaktualizuj wartość
    $query = "
        INSERT INTO licznik_daily_values (date, user_id, counter_id, value)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE value = VALUES(value), updated_at = CURRENT_TIMESTAMP
    ";

    $stmt = $pdo->prepare($query);
    $stmt->execute([$date, $userId, $counterId, $value]);

    return ['success' => true, 'message' => 'Wartość zapisana'];
}

function saveCounterSettings() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $id = $_POST['id'] ?? null;
    $title = trim($_POST['title'] ?? '');
    $increment = max(1, intval($_POST['increment'] ?? 1));
    $categoryId = $_POST['category_id'] ?? null;
    $color = $_POST['color'] ?? '#374151';
    $type = $_POST['type'] ?? 'number';
    $symbol = $_POST['symbol'] ?? null;

    if (empty($title)) {
        return ['success' => false, 'message' => 'Nazwa licznika jest wymagana'];
    }

    // Walidacja typu
    if (!in_array($type, ['number', 'currency'])) {
        $type = 'number';
    }

    // Jeśli nie jest walutowy, usuń symbol
    if ($type !== 'currency') {
        $symbol = null;
    }

    if ($id) {
        // Edycja istniejącego licznika
        $query = "
            UPDATE licznik_counters
            SET title = ?, increment = ?, category_id = ?, color = ?, type = ?, symbol = ?
            WHERE id = ? AND sfid_id = ?
        ";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$title, $increment, $categoryId, $color, $type, $symbol, $id, $_SESSION['sfid_id']]);
    } else {
        // Dodanie nowego licznika
        $query = "
            INSERT INTO licznik_counters (sfid_id, title, increment, category_id, color, type, symbol, sort_order)
            VALUES (?, ?, ?, ?, ?, ?, ?, (SELECT COALESCE(MAX(sort_order), 0) + 1 FROM licznik_counters lc WHERE lc.sfid_id = ?))
        ";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$_SESSION['sfid_id'], $title, $increment, $categoryId, $color, $type, $symbol, $_SESSION['sfid_id']]);
    }

    return ['success' => true, 'message' => 'Licznik zapisany'];
}

function deleteCounter() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $counterId = $_POST['counter_id'] ?? 0;

    // Sprawdź czy licznik należy do tej lokalizacji
    $checkQuery = "SELECT id FROM licznik_counters WHERE id = ? AND sfid_id = ?";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute([$counterId, $_SESSION['sfid_id']]);

    if (!$checkStmt->fetch()) {
        return ['success' => false, 'message' => 'Nieprawidłowy licznik'];
    }

    // Usuń licznik (soft delete) - POPRAWNA NAZWA KOLUMNY
    $query = "UPDATE licznik_counters SET is_active = 0 WHERE id = ? AND sfid_id = ?";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$counterId, $_SESSION['sfid_id']]);

    return ['success' => true, 'message' => 'Licznik usunięty'];
}

function sortCounters() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $counterIds = json_decode($_POST['counter_ids'] ?? '[]', true);

    if (empty($counterIds)) {
        return ['success' => false, 'message' => 'Brak danych do sortowania'];
    }

    $pdo->beginTransaction();

    try {
        foreach ($counterIds as $index => $counterId) {
            $query = "UPDATE licznik_counters SET sort_order = ? WHERE id = ? AND sfid_id = ?";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$index + 1, $counterId, $_SESSION['sfid_id']]);
        }

        $pdo->commit();
        return ['success' => true, 'message' => 'Kolejność zapisana'];

    } catch (Exception $e) {
        $pdo->rollBack();
        return ['success' => false, 'message' => 'Błąd zapisywania kolejności: ' . $e->getMessage()];
    }
}

// === FUNKCJE KPI ===

function getKpiData() {
    global $pdo;

    $month = $_POST['month'] ?? date('Y-m');
    $year = substr($month, 0, 4);
    $monthNum = substr($month, 5, 2);

    // Pobierz cele KPI sortowane po ID (najmniejsze do największych)
    $query = "
        SELECT
            kg.id,
            kg.name,
            kg.total_goal,
            GROUP_CONCAT(klc.counter_id) as linked_counter_ids
        FROM licznik_kpi_goals kg
        LEFT JOIN licznik_kpi_linked_counters klc ON kg.id = klc.kpi_goal_id
        WHERE kg.sfid_id = ? AND kg.is_active = 1
        GROUP BY kg.id
        ORDER BY kg.id ASC
    ";

    $stmt = $pdo->prepare($query);
    $stmt->execute([$_SESSION['sfid_id']]);
    $goals = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Oblicz realizację dla każdego celu
    foreach ($goals as &$goal) {
        $linkedIds = $goal['linked_counter_ids'] ? explode(',', $goal['linked_counter_ids']) : [];

        if (!empty($linkedIds)) {
            // Pobierz sumę wartości z powiązanych liczników za dany miesiąc
            $placeholders = str_repeat('?,', count($linkedIds) - 1) . '?';
            $realizationQuery = "
                SELECT COALESCE(SUM(dv.value), 0) as total
                FROM licznik_daily_values dv
                WHERE dv.counter_id IN ($placeholders)
                AND YEAR(dv.date) = ? AND MONTH(dv.date) = ?
            ";

            $params = array_merge($linkedIds, [$year, $monthNum]);
            $realizationStmt = $pdo->prepare($realizationQuery);
            $realizationStmt->execute($params);
            $realization = $realizationStmt->fetchColumn();
        } else {
            $realization = 0;
        }

        $goal['realization'] = $realization;
        $goal['progress_percent'] = $goal['total_goal'] > 0 ? min(100, ($realization / $goal['total_goal']) * 100) : 0;
        $goal['linked_counter_ids'] = $linkedIds;

        // NOWA LOGIKA: Oblicz dynamiczny cel dzienny uwzględniający zespołową realizację
        $goal['daily_goal'] = calculateDynamicDailyGoal($goal['total_goal'], $realization, $year, $monthNum, $_SESSION['sfid_id']);
    }

    return ['success' => true, 'data' => $goals];
}

function saveKpiGoal() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $id = $_POST['id'] ?? null;
    $name = trim($_POST['name'] ?? '');
    $totalGoal = max(0, intval($_POST['total_goal'] ?? 0));
    $linkedCounterIds = json_decode($_POST['linked_counter_ids'] ?? '[]', true);

    if (empty($name)) {
        return ['success' => false, 'message' => 'Nazwa celu jest wymagana'];
    }

    $pdo->beginTransaction();

    try {
        if ($id) {
            // Edycja istniejącego celu - POPRAWNE NAZWY KOLUMN
            $query = "UPDATE licznik_kpi_goals SET name = ?, total_goal = ? WHERE id = ? AND sfid_id = ?";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$name, $totalGoal, $id, $_SESSION['sfid_id']]);
            $goalId = $id;
        } else {
            // Dodanie nowego celu - POPRAWNE NAZWY KOLUMN
            $query = "INSERT INTO licznik_kpi_goals (sfid_id, name, total_goal) VALUES (?, ?, ?)";
            $stmt = $pdo->prepare($query);
            $stmt->execute([$_SESSION['sfid_id'], $name, $totalGoal]);
            $goalId = $pdo->lastInsertId();
        }

        // Usuń stare powiązania
        $deleteQuery = "DELETE FROM licznik_kpi_linked_counters WHERE kpi_goal_id = ?";
        $deleteStmt = $pdo->prepare($deleteQuery);
        $deleteStmt->execute([$goalId]);

        // Dodaj nowe powiązania
        if (!empty($linkedCounterIds)) {
            $insertQuery = "INSERT INTO licznik_kpi_linked_counters (kpi_goal_id, counter_id) VALUES (?, ?)";
            $insertStmt = $pdo->prepare($insertQuery);

            foreach ($linkedCounterIds as $counterId) {
                $insertStmt->execute([$goalId, $counterId]);
            }
        }

        $pdo->commit();
        return ['success' => true, 'message' => 'Cel KPI zapisany'];

    } catch (Exception $e) {
        $pdo->rollBack();
        return ['success' => false, 'message' => 'Błąd zapisywania: ' . $e->getMessage()];
    }
}

function deleteKpiGoal() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $goalId = $_POST['goal_id'] ?? 0;

    // Sprawdź czy cel należy do tej lokalizacji
    $checkQuery = "SELECT id FROM licznik_kpi_goals WHERE id = ? AND sfid_id = ?";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute([$goalId, $_SESSION['sfid_id']]);

    if (!$checkStmt->fetch()) {
        return ['success' => false, 'message' => 'Nieprawidłowy cel KPI'];
    }

    // Usuń cel (soft delete) - POPRAWNA NAZWA KOLUMNY
    $query = "UPDATE licznik_kpi_goals SET is_active = 0 WHERE id = ? AND sfid_id = ?";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$goalId, $_SESSION['sfid_id']]);

    return ['success' => true, 'message' => 'Cel KPI usunięty'];
}

function getKpiDetails() {
    global $pdo;

    $goalId = $_POST['goal_id'] ?? 0;
    $month = $_POST['month'] ?? date('Y-m');
    $year = substr($month, 0, 4);
    $monthNum = substr($month, 5, 2);

    // Pobierz informacje o celu KPI
    $goalQuery = "SELECT name, total_goal FROM licznik_kpi_goals WHERE id = ? AND sfid_id = ?";
    $goalStmt = $pdo->prepare($goalQuery);
    $goalStmt->execute([$goalId, $_SESSION['sfid_id']]);
    $goal = $goalStmt->fetch(PDO::FETCH_ASSOC);

    if (!$goal) {
        return ['success' => false, 'message' => 'Nieprawidłowy cel KPI'];
    }

    // Pobierz powiązane liczniki
    $linkedQuery = "SELECT counter_id FROM licznik_kpi_linked_counters WHERE kpi_goal_id = ?";
    $linkedStmt = $pdo->prepare($linkedQuery);
    $linkedStmt->execute([$goalId]);
    $linkedCounters = $linkedStmt->fetchAll(PDO::FETCH_COLUMN);

    // Pobierz tygodniowy rozkład realizacji
    $weeklyData = [];
    if (!empty($linkedCounters)) {
        $placeholders = str_repeat('?,', count($linkedCounters) - 1) . '?';
        $weeklyQuery = "
            SELECT 
                WEEK(dv.date, 1) as week_number,
                DATE(DATE_SUB(dv.date, INTERVAL WEEKDAY(dv.date) DAY)) as week_start,
                SUM(dv.value) as weekly_total
            FROM licznik_daily_values dv
            WHERE dv.counter_id IN ($placeholders)
            AND YEAR(dv.date) = ? AND MONTH(dv.date) = ?
            GROUP BY week_number, week_start
            ORDER BY week_start
        ";

        $params = array_merge($linkedCounters, [$year, $monthNum]);
        $weeklyStmt = $pdo->prepare($weeklyQuery);
        $weeklyStmt->execute($params);
        $weeklyData = $weeklyStmt->fetchAll(PDO::FETCH_ASSOC);
    }

    return [
        'success' => true,
        'goal' => $goal,
        'weekly_data' => $weeklyData
    ];
}

function saveKpiCorrection() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $goalId = $_POST['goal_id'] ?? 0;
    $date = $_POST['date'] ?? date('Y-m-d');
    $value = intval($_POST['value'] ?? 0);
    $description = trim($_POST['description'] ?? '');

    // Sprawdź czy cel należy do tej lokalizacji
    $checkQuery = "SELECT id FROM licznik_kpi_goals WHERE id = ? AND sfid_id = ?";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute([$goalId, $_SESSION['sfid_id']]);

    if (!$checkStmt->fetch()) {
        return ['success' => false, 'message' => 'Nieprawidłowy cel KPI'];
    }

    // Zapisz korektę
    $query = "
        INSERT INTO licznik_kpi_corrections (kpi_goal_id, date, value, description, created_by)
        VALUES (?, ?, ?, ?, ?)
    ";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$goalId, $date, $value, $description, $_SESSION['user_id']]);

    return ['success' => true, 'message' => 'Korekta zapisana'];
}

function saveMassCorrection() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $corrections = json_decode($_POST['corrections'] ?? '[]', true);
    $date = $_POST['date'] ?? date('Y-m-d');

    if (empty($corrections)) {
        return ['success' => false, 'message' => 'Brak danych do zapisania'];
    }

    $pdo->beginTransaction();

    try {
        foreach ($corrections as $correction) {
            $userId = $correction['user_id'];
            $counterId = $correction['counter_id'];
            $value = intval($correction['value']);

            if ($value == 0) continue;

            // Pobierz aktualną wartość
            $currentQuery = "
                SELECT COALESCE(value, 0) as current_value
                FROM licznik_daily_values
                WHERE date = ? AND user_id = ? AND counter_id = ?
            ";
            $currentStmt = $pdo->prepare($currentQuery);
            $currentStmt->execute([$date, $userId, $counterId]);
            $currentValue = $currentStmt->fetchColumn() ?: 0;

            $newValue = max(0, $currentValue + $value);

            // Zapisz nową wartość
            $updateQuery = "
                INSERT INTO licznik_daily_values (date, user_id, counter_id, value)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE value = VALUES(value), updated_at = CURRENT_TIMESTAMP
            ";
            $updateStmt = $pdo->prepare($updateQuery);
            $updateStmt->execute([$date, $userId, $counterId, $newValue]);
        }

        $pdo->commit();
        return ['success' => true, 'message' => 'Korekty masowe zapisane'];

    } catch (Exception $e) {
        $pdo->rollBack();
        return ['success' => false, 'message' => 'Błąd zapisywania korekt: ' . $e->getMessage()];
    }
}

// === FUNKCJE KATEGORII ===

function saveCategory() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $name = trim($_POST['name'] ?? '');

    if (empty($name)) {
        return ['success' => false, 'message' => 'Nazwa kategorii jest wymagana'];
    }

    // Sprawdź czy kategoria już istnieje
    $checkQuery = "SELECT id FROM licznik_categories WHERE name = ? AND sfid_id = ?";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute([$name, $_SESSION['sfid_id']]);

    if ($checkStmt->fetch()) {
        return ['success' => false, 'message' => 'Kategoria o tej nazwie już istnieje'];
    }

    // Dodaj nową kategorię
    $query = "INSERT INTO licznik_categories (sfid_id, name) VALUES (?, ?)";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$_SESSION['sfid_id'], $name]);

    return ['success' => true, 'message' => 'Kategoria dodana'];
}

// === FUNKCJE POMOCNICZE ===

function getWorkingDaysInMonth($year, $month) {
    $workingDays = 0;
    $daysInMonth = cal_days_in_month(CAL_GREGORIAN, $month, $year);

    for ($day = 1; $day <= $daysInMonth; $day++) {
        $dayOfWeek = date('N', mktime(0, 0, 0, $month, $day, $year));
        if ($dayOfWeek < 6) { // Poniedziałek-Piątek
            $workingDays++;
        }
    }

    return $workingDays;
}

// Oblicz dynamiczny cel dzienny uwzględniający zespołową realizację i pozostałe dni
function calculateDynamicDailyGoal($totalGoal, $currentRealization, $year, $month, $sfidId) {
    global $pdo;

    // Pobierz dni robocze z tabeli global_working_hours lub oblicz automatycznie
    $workingDaysQuery = "SELECT working_days FROM global_working_hours WHERE sfid_id = ? AND year = ? AND month = ?";
    $stmt = $pdo->prepare($workingDaysQuery);
    $stmt->execute([$sfidId, $year, $month]);
    $workingDaysData = $stmt->fetch(PDO::FETCH_ASSOC);

    $totalWorkingDays = $workingDaysData['working_days'] ?? getWorkingDaysInMonth($year, $month);

    // Oblicz ile dni roboczych już minęło w tym miesiącu (bez niedziel)
    $today = date('j'); // dzień miesiąca
    $currentMonth = date('n'); // miesiąc bieżący
    $currentYear = date('Y'); // rok bieżący

    $elapsedWorkingDays = 0;
    $remainingWorkingDays = $totalWorkingDays;

    // Jeśli to bieżący miesiąc, oblicz ile dni roboczych już minęło
    if ($year == $currentYear && $month == $currentMonth) {
        for ($day = 1; $day < $today; $day++) {
            $dayOfWeek = date('N', mktime(0, 0, 0, $month, $day, $year));
            if ($dayOfWeek < 6) { // Poniedziałek-Piątek
                $elapsedWorkingDays++;
            }
        }

        // Oblicz pozostałe dni robocze (włącznie z dzisiaj)
        $remainingWorkingDays = 0;
        for ($day = $today; $day <= cal_days_in_month(CAL_GREGORIAN, $month, $year); $day++) {
            $dayOfWeek = date('N', mktime(0, 0, 0, $month, $day, $year));
            if ($dayOfWeek < 6) { // Poniedziałek-Piątek
                $remainingWorkingDays++;
            }
        }
    }

    // Oblicz ile jeszcze trzeba zrealizować
    $remainingGoal = max(0, $totalGoal - $currentRealization);

    // Jeśli nie ma pozostałych dni roboczych, zwróć 0
    if ($remainingWorkingDays <= 0) {
        return 0;
    }

    // Cel dzienny = pozostały cel / pozostałe dni robocze
    $dynamicDailyGoal = round($remainingGoal / $remainingWorkingDays, 1);

    // Minimum 0 (nie może być ujemny)
    return max(0, $dynamicDailyGoal);
}

// === FUNKCJE RAPORTÓW ===

function getReportTemplates() {
    try {
        $templatesDir = __DIR__ . '/../reports/';
        $templates = [];

        if (is_dir($templatesDir)) {
            $files = scandir($templatesDir);
            foreach ($files as $file) {
                if (pathinfo($file, PATHINFO_EXTENSION) === 'php') {
                    $templates[] = [
                        'filename' => $file,
                        'name' => ucfirst(pathinfo($file, PATHINFO_FILENAME)) . ' Report'
                    ];
                }
            }
        }

        return ['success' => true, 'templates' => $templates];
    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd ładowania szablonów: ' . $e->getMessage()];
    }
}

function getReportPreview($templateName, $date, $pdo) {
    try {
        $templatePath = __DIR__ . '/../reports/' . $templateName;

        if (!file_exists($templatePath)) {
            return ['success' => false, 'message' => 'Szablon nie istnieje'];
        }

        $templateContent = file_get_contents($templatePath);

        // Pobierz dane KPI dla podglądu (tylko pierwsze 3 cele)
        $kpiData = getKpiDataForReport($date, $pdo, 3);

        // Zastąp placeholdery podglądem
        $preview = processReportTemplate($templateContent, $kpiData, $date, true);

        // Usuń HTML i zwróć tylko tabelę
        $preview = preg_replace('/<html.*?<body[^>]*>/s', '', $preview);
        $preview = preg_replace('/<\/body>.*?<\/html>/s', '', $preview);
        $preview = preg_replace('/<head>.*?<\/head>/s', '', $preview);
        $preview = str_replace('<!DOCTYPE html>', '', $preview);

        return ['success' => true, 'preview' => $preview];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd przetwarzania szablonu: ' . $e->getMessage()];
    }
}

function generateReport($templateName, $date, $pdo) {
    try {
        $templatePath = __DIR__ . '/../reports/' . $templateName;

        if (!file_exists($templatePath)) {
            return ['success' => false, 'message' => 'Szablon nie istnieje'];
        }

        $templateContent = file_get_contents($templatePath);

        // Pobierz wszystkie dane KPI
        $kpiData = getKpiDataForReport($date, $pdo);

        // Przetwórz szablon
        $reportHtml = processReportTemplate($templateContent, $kpiData, $date, false);

        return ['success' => true, 'html' => $reportHtml];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd generowania raportu: ' . $e->getMessage()];
    }
}

function getKpiDataForReport($date, $pdo, $limit = null) {
    try {
        $sfid = $_SESSION['sfid_id'];

        // Pobierz cele KPI
        $kpiQuery = "SELECT * FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC";
        if ($limit) {
            $kpiQuery .= " LIMIT " . (int)$limit;
        }

        $kpiStmt = $pdo->prepare($kpiQuery);
        $kpiStmt->execute([$sfid]);
        $kpiGoals = $kpiStmt->fetchAll(PDO::FETCH_ASSOC);

        $kpiData = [];

        foreach ($kpiGoals as $goal) {
            $linkedCounterIds = json_decode($goal['linked_counter_ids'], true) ?: [];

            // Pobierz wartości dla tego dnia
            $totalValue = 0;
            if (!empty($linkedCounterIds)) {
                $placeholders = str_repeat('?,', count($linkedCounterIds) - 1) . '?';
                $valueQuery = "SELECT SUM(value) as total 
                              FROM licznik_values 
                              WHERE counter_id IN ($placeholders) 
                              AND date = ? 
                              AND sfid_id = ?";

                $params = array_merge($linkedCounterIds, [$date, $sfid]);
                $valueStmt = $pdo->prepare($valueQuery);
                $valueStmt->execute($params);
                $totalValue = $valueStmt->fetchColumn() ?: 0;
            }

            // Oblicz cel dzienny (zaokrąglony w górę)
            $dailyGoal = 0;
            if ($goal['total_goal'] > 0) {
                // Pobierz liczbę dni roboczych w miesiącu
                $monthStart = date('Y-m-01', strtotime($date));
                $monthEnd = date('Y-m-t', strtotime($date));
                $workingDays = calculateWorkingDaysInRange($monthStart, $monthEnd);
                $dailyGoal = ceil($goal['total_goal'] / $workingDays);
            }

            $kpiData[$goal['id']] = [
                'value' => $totalValue,
                'daily_goal' => $dailyGoal,
                'monthly_goal' => $goal['total_goal'],
                'name' => $goal['name']
            ];
        }

        return $kpiData;

    } catch (Exception $e) {
        return [];
    }
}

function processReportTemplate($template, $kpiData, $date, $isPreview = false) {
    // Zastąp datę raportu
    $template = str_replace('{REPORT_DATE}', date('d.m.Y', strtotime($date)), $template);

    // Zastąp placeholdery KPI
    foreach ($kpiData as $kpiId => $data) {
        $template = str_replace('{KPI_VALUE=' . $kpiId . '}', $data['value'], $template);
        $template = str_replace('{KPI_TARGET_DAILY=' . $kpiId . '}', $data['daily_goal'], $template);
        $template = str_replace('{KPI_TARGET_MONTHLY=' . $kpiId . '}', $data['monthly_goal'], $template);
        $template = str_replace('{KPI_NAME=' . $kpiId . '}', $data['name'], $template);
    }

    // Usuń nieużywane placeholdery
    $template = preg_replace('/\{KPI_[^}]+\}/', '-', $template);

    // W podglądzie dodaj informację o ograniczeniu
    if ($isPreview) {