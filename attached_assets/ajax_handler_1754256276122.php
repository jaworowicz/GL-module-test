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
        case 'get_counters':
        case 'get_counter_data':
            echo json_encode(getCounterData());
            break;

        case 'save_counter_value':
            echo json_encode(saveCounterValue());
            break;

        case 'create_counter':
        case 'save_counter_settings':
            echo json_encode(saveCounterSettings());
            break;

        case 'update_counter':
            echo json_encode(updateCounterSettings());
            break;

        case 'delete_counter':
            echo json_encode(deleteCounter());
            break;

        case 'get_kpi_data':
            echo json_encode(getKpiData());
            break;

        case 'create_kpi_goal':
        case 'save_kpi_goal':
            echo json_encode(saveKpiGoal());
            break;

        case 'update_kpi_goal':
            echo json_encode(updateKpiGoal());
            break;

        case 'delete_kpi_goal':
            echo json_encode(deleteKpiGoal());
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
            c.is_personal,
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

    return ['success' => true, 'counters' => $counters];
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
    $isPersonal = $_POST['is_personal'] ?? 0;

    if (empty($title)) {
        return ['success' => false, 'message' => 'Nazwa licznika jest wymagana'];
    }

    if ($id) {
        // Edycja istniejącego licznika - POPRAWNE NAZWY KOLUMN
        $query = "
            UPDATE licznik_counters
            SET title = ?, increment = ?, category_id = ?, color = ?, is_personal = ?
            WHERE id = ? AND sfid_id = ?
        ";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$title, $increment, $categoryId, $color, $isPersonal, $id, $_SESSION['sfid_id']]);
    } else {
        // Dodanie nowego licznika - POPRAWNE NAZWY KOLUMN
        $query = "
            INSERT INTO licznik_counters (sfid_id, title, increment, category_id, color, is_personal, sort_order)
            VALUES (?, ?, ?, ?, ?, ?, (SELECT COALESCE(MAX(sort_order), 0) + 1 FROM licznik_counters lc WHERE lc.sfid_id = ?))
        ";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$_SESSION['sfid_id'], $title, $increment, $categoryId, $color, $isPersonal, $_SESSION['sfid_id']]);
    }

    return ['success' => true, 'message' => 'Licznik zapisany'];
}

function updateCounterSettings() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $counterId = $_POST['counter_id'] ?? 0;
    $title = trim($_POST['title'] ?? '');
    $increment = max(1, intval($_POST['increment'] ?? 1));
    $categoryId = $_POST['category_id'] ?? null;
    $isPersonal = $_POST['is_personal'] ?? 0;

    if (empty($title)) {
        return ['success' => false, 'message' => 'Nazwa licznika jest wymagana'];
    }

    // Sprawdź czy licznik należy do tej lokalizacji
    $checkQuery = "SELECT id FROM licznik_counters WHERE id = ? AND sfid_id = ?";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute([$counterId, $_SESSION['sfid_id']]);

    if (!$checkStmt->fetch()) {
        return ['success' => false, 'message' => 'Nieprawidłowy licznik'];
    }

    // Aktualizuj licznik
    $query = "
        UPDATE licznik_counters
        SET title = ?, increment = ?, category_id = ?, is_personal = ?
        WHERE id = ? AND sfid_id = ?
    ";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$title, $increment, $categoryId, $isPersonal, $counterId, $_SESSION['sfid_id']]);

    return ['success' => true, 'message' => 'Licznik zaktualizowany'];
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

// === FUNKCJE KPI ===

function getKpiData() {
    global $pdo;

    $month = $_POST['month'] ?? date('Y-m');
    $year = substr($month, 0, 4);
    $monthNum = substr($month, 5, 2);

    // Pobierz cele KPI - POPRAWNE NAZWY KOLUMN
    $query = "
        SELECT
            kg.id,
            kg.name,
            kg.total_goal,
            kg.daily_goal,
            GROUP_CONCAT(klc.counter_id) as linked_counter_ids
        FROM licznik_kpi_goals kg
        LEFT JOIN licznik_kpi_linked_counters klc ON kg.id = klc.kpi_goal_id
        WHERE kg.sfid_id = ? AND kg.is_active = 1
        GROUP BY kg.id
        ORDER BY kg.name
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
            $monthlyTotal = $realizationStmt->fetchColumn();
        } else {
            $monthlyTotal = 0;
        }

        $goal['monthly_total'] = $monthlyTotal;
        $goal['progress_percent'] = $goal['total_goal'] > 0 ? min(100, ($monthlyTotal / $goal['total_goal']) * 100) : 0;
        $goal['linked_counter_ids'] = $linkedIds;

        // Oblicz cel dzienny (cel miesięczny / dni robocze w miesiącu)
        if (!$goal['daily_goal']) {
            $workingDays = getWorkingDaysInMonth($year, $monthNum);
            $goal['daily_goal'] = $workingDays > 0 ? round($goal['total_goal'] / $workingDays, 1) : 0;
        }
    }

    return ['success' => true, 'kpi_goals' => $goals];
}

function updateKpiGoal() {
    global $pdo;

    // Sprawdź uprawnienia
    if (!in_array($_SESSION['role'], ['admin', 'superadmin'])) {
        return ['success' => false, 'message' => 'Brak uprawnień'];
    }

    $goalId = $_POST['goal_id'] ?? 0;
    $name = trim($_POST['name'] ?? '');
    $totalGoal = max(0, intval($_POST['total_goal'] ?? 0));
    $dailyGoal = $_POST['daily_goal'] ? max(0, intval($_POST['daily_goal'])) : null;
    $linkedCounterIds = json_decode($_POST['linked_counters'] ?? '[]', true);

    if (empty($name)) {
        return ['success' => false, 'message' => 'Nazwa celu jest wymagana'];
    }

    // Sprawdź czy cel należy do tej lokalizacji
    $checkQuery = "SELECT id FROM licznik_kpi_goals WHERE id = ? AND sfid_id = ?";
    $checkStmt = $pdo->prepare($checkQuery);
    $checkStmt->execute([$goalId, $_SESSION['sfid_id']]);

    if (!$checkStmt->fetch()) {
        return ['success' => false, 'message' => 'Nieprawidłowy cel KPI'];
    }

    $pdo->beginTransaction();

    try {
        // Aktualizuj cel KPI
        $query = "UPDATE licznik_kpi_goals SET name = ?, total_goal = ?, daily_goal = ? WHERE id = ? AND sfid_id = ?";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$name, $totalGoal, $dailyGoal, $goalId, $_SESSION['sfid_id']]);

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
        return ['success' => true, 'message' => 'Cel KPI zaktualizowany'];

    } catch (Exception $e) {
        $pdo->rollBack();
        return ['success' => false, 'message' => 'Błąd aktualizacji: ' . $e->getMessage()];
    }
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
?>