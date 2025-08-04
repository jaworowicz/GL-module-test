<?php
// Sesja i podstawowa autoryzacja
session_start();

require_once __DIR__ . '/../../../includes/db.php';
require_once __DIR__ . '/../../../includes/auth.php';

auth_require_login();
header('Content-Type: application/json');

$action = $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'get_templates':
            echo json_encode(getTemplates());
            break;

        case 'get_template':
            echo json_encode(getTemplate($_POST['template_id']));
            break;

        case 'save_template':
            echo json_encode(saveTemplate());
            break;

        case 'delete_template':
            echo json_encode(deleteTemplate($_POST['template_id']));
            break;

        case 'preview_template':
            echo json_encode(previewTemplate($_POST['html_content'], $_POST['date']));
            break;

        case 'get_kpi_placeholders':
            echo json_encode(getKpiPlaceholders());
            break;

        default:
            echo json_encode(['success' => false, 'message' => 'Nieznana akcja']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Błąd serwera: ' . $e->getMessage()]);
}

function getTemplates() {
    $templatesDir = __DIR__ . '/templates/';
    if (!is_dir($templatesDir)) {
        mkdir($templatesDir, 0755, true);
    }

    $templates = [];
    $files = glob($templatesDir . '*.json');

    foreach ($files as $file) {
        $data = json_decode(file_get_contents($file), true);
        if ($data) {
            $templates[] = [
                'id' => $data['id'],
                'name' => $data['name'],
                'description' => $data['description'] ?? '',
                'created' => $data['created'] ?? date('Y-m-d H:i:s')
            ];
        }
    }

    return ['success' => true, 'templates' => $templates];
}

function getTemplate($templateId) {
    $templateFile = __DIR__ . '/templates/' . $templateId . '.json';

    if (!file_exists($templateFile)) {
        return ['success' => false, 'message' => 'Szablon nie istnieje'];
    }

    $data = json_decode(file_get_contents($templateFile), true);
    if (!$data) {
        return ['success' => false, 'message' => 'Błąd odczytu szablonu'];
    }

    return ['success' => true, 'template' => $data];
}

function saveTemplate() {
    $templateId = $_POST['template_id'] ?? '';
    $name = trim($_POST['name'] ?? '');
    $description = trim($_POST['description'] ?? '');
    $htmlContent = $_POST['html_content'] ?? '';

    if (empty($name)) {
        return ['success' => false, 'message' => 'Nazwa szablonu jest wymagana'];
    }

    // Jeśli to nowy szablon, wygeneruj ID
    if (empty($templateId)) {
        $templateId = 'template_' . time() . '_' . rand(1000, 9999);
    }

    $templateData = [
        'id' => $templateId,
        'name' => $name,
        'description' => $description,
        'html_content' => $htmlContent,
        'created' => date('Y-m-d H:i:s'),
        'updated' => date('Y-m-d H:i:s')
    ];

    $templatesDir = __DIR__ . '/templates/';
    if (!is_dir($templatesDir)) {
        mkdir($templatesDir, 0755, true);
    }

    $templateFile = $templatesDir . $templateId . '.json';

    if (file_put_contents($templateFile, json_encode($templateData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE))) {
        return ['success' => true, 'message' => 'Szablon zapisany', 'template_id' => $templateId];
    } else {
        return ['success' => false, 'message' => 'Błąd zapisu pliku'];
    }
}

function deleteTemplate($templateId) {
    if (empty($templateId)) {
        return ['success' => false, 'message' => 'ID szablonu jest wymagane'];
    }

    $templateFile = __DIR__ . '/templates/' . $templateId . '.json';

    if (!file_exists($templateFile)) {
        return ['success' => false, 'message' => 'Szablon nie istnieje'];
    }

    if (unlink($templateFile)) {
        return ['success' => true, 'message' => 'Szablon usunięty'];
    } else {
        return ['success' => false, 'message' => 'Błąd usuwania pliku'];
    }
}

function previewTemplate($htmlContent, $date) {
    global $pdo;

    if (empty($htmlContent)) {
        return ['success' => true, 'preview' => '<p style="color: #666;">Wpisz kod HTML aby zobaczyć podgląd...</p>'];
    }

    // Pobierz prawdziwe dane KPI z modułu dla aktualnego użytkownika
    $realKpiData = getRealKpiDataForPreview($date, $pdo);

    // Przetwórz szablon
    $preview = processTemplatePreview($htmlContent, $realKpiData, $date);

    return ['success' => true, 'preview' => $preview];
}

function getRealKpiDataForPreview($date, $pdo) {
    try {
        // Pobierz pierwszą aktywną lokalizację (sfid_id) dla aktualnego użytkownika
        $userId = $_SESSION['user_id']; // Pobierz ID użytkownika z sesji

        $sfidQuery = "SELECT DISTINCT sfid_id FROM licznik_kpi_goals WHERE is_active = 1 AND user_id = ? LIMIT 1";
        $sfidStmt = $pdo->prepare($sfidQuery);
        $sfidStmt->execute([$userId]);
        $sfidId = $sfidStmt->fetchColumn();

        if (!$sfidId) {
            return []; // Brak danych KPI dla tego użytkownika
        }

        // Pobierz cele KPI (maksymalnie 5 do podglądu) dla tego SFID
        $kpiQuery = "SELECT * FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 AND user_id = ? ORDER BY id ASC LIMIT 5";
        $kpiStmt = $pdo->prepare($kpiQuery);
        $kpiStmt->execute([$sfidId, $userId]);
        $kpiGoals = $kpiStmt->fetchAll(PDO::FETCH_ASSOC);

        $kpiData = [];

        foreach ($kpiGoals as $goal) {
            // Pobierz powiązane liczniki
            $linkedQuery = "SELECT counter_id FROM licznik_kpi_linked_counters WHERE kpi_goal_id = ?";
            $linkedStmt = $pdo->prepare($linkedQuery);
            $linkedStmt->execute([$goal['id']]);
            $linkedCounterIds = $linkedStmt->fetchAll(PDO::FETCH_COLUMN);

            // Pobierz wartości dla tego dnia
            $totalValue = 0;
            if (!empty($linkedCounterIds)) {
                $placeholders = str_repeat('?,', count($linkedCounterIds) - 1) . '?';
                $valueQuery = "SELECT SUM(value) as total 
                              FROM licznik_daily_values 
                              WHERE counter_id IN ($placeholders) 
                              AND date = ?";

                $params = array_merge($linkedCounterIds, [$date]);
                $valueStmt = $pdo->prepare($valueQuery);
                $valueStmt->execute($params);
                $totalValue = $valueStmt->fetchColumn() ?: 0;
            }

            // Oblicz cel dzienny
            $dailyGoal = 0;
            if ($goal['total_goal'] > 0) {
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
        error_log("Błąd pobierania danych KPI: " . $e->getMessage());
        return [];
    }
}

function calculateWorkingDaysInRange($startDate, $endDate) {
    $workingDays = 0;
    $start = new DateTime($startDate);
    $end = new DateTime($endDate);

    while ($start <= $end) {
        $dayOfWeek = $start->format('N');
        if ($dayOfWeek < 6) { // Poniedziałek-Piątek
            $workingDays++;
        }
        $start->add(new DateInterval('P1D'));
    }

    return $workingDays;
}

function processTemplatePreview($template, $kpiData, $date) {
    // Zastąp datę raportu
    $template = str_replace('{REPORT_DATE}', date('d.m.Y', strtotime($date)), $template);
    $template = str_replace('{TODAY}', date('d.m.Y'), $template);

    // Jeśli brak danych KPI, wyświetl błąd dla wszystkich placeholderów
    if (empty($kpiData)) {
        $template = preg_replace('/\{KPI_[^}]+\}/', '<span style="color: #ff6b6b; font-weight: bold;">Błąd danych</span>', $template);
        return $template;
    }

    // UŻYJ RZECZYWISTYCH ID Z SZABLONU - bez mapowania pozycyjnego
    foreach ($kpiData as $kpiId => $data) {
        $template = str_replace('{KPI_VALUE=' . $kpiId . '}', $data['value'], $template);
        $template = str_replace('{KPI_TARGET_DAILY=' . $kpiId . '}', $data['daily_goal'], $template);
        $template = str_replace('{KPI_TARGET_MONTHLY=' . $kpiId . '}', $data['monthly_goal'], $template);
        $template = str_replace('{KPI_NAME=' . $kpiId . '}', $data['name'], $template);
    }

    // Usuń nieużywane placeholdery - pokaż "Błąd danych" 
    $template = preg_replace('/\{KPI_[^}]+\}/', '<span style="color: #ff6b6b; font-weight: bold;">Błąd danych</span>', $template);

    // Sprawdź czy to są prawdziwe dane czy przykładowe
    $isRealData = !empty($kpiData) && (!isset($kpiData[1]['name']) || (isset($kpiData[1]['name']) && strpos($kpiData[1]['name'], '(przykład)') === false));

    // Dodaj informację o podglądzie
    $headerText = $isRealData ? 'PODGLĄD SZABLONU - DANE Z MODUŁU' : 'PODGLĄD SZABLONU - DANE PRZYKŁADOWE';
    $headerColor = $isRealData ? '#16a34a' : '#3b82f6';

    if (strpos($template, '<body') !== false) {
        $template = str_replace('<body', '<body style="border: 3px solid ' . $headerColor . '; margin: 10px; padding: 10px; position: relative;"', $template);
        $template = str_replace('<body', '<body><div style="position: absolute; top: 0; left: 0; right: 0; background: ' . $headerColor . '; color: white; padding: 10px; text-align: center; font-weight: bold;">' . $headerText . '</div><div style="margin-top: 50px;"', $template);
        $template = str_replace('</body>', '</div></body>', $template);
    } else {
        // Jeśli brak znacznika body, dodaj header na początku
        $template = '<div style="background: ' . $headerColor . '; color: white; padding: 10px; text-align: center; font-weight: bold; margin-bottom: 20px; border-radius: 5px;">' . $headerText . '</div>' . $template;
    }

    return $template;
}

function getKpiPlaceholders() {
    global $pdo;

    try {
        // Pobierz wszystkie aktywne cele KPI z bazy danych dla aktualnego użytkownika
        $userId = $_SESSION['user_id'];
        $query = "SELECT id, name FROM licznik_kpi_goals WHERE is_active = 1 AND user_id = ? ORDER BY id ASC";
        $stmt = $pdo->prepare($query);
        $stmt->execute([$userId]);
        $kpiGoals = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $placeholders = [];

        foreach ($kpiGoals as $kpi) {
            $placeholders[] = [
                'id' => $kpi['id'],
                'name' => $kpi['name'],
                'placeholders' => [
                    '{KPI_NAME=' . $kpi['id'] . '}',
                    '{KPI_VALUE=' . $kpi['id'] . '}', 
                    '{KPI_TARGET_DAILY=' . $kpi['id'] . '}',
                    '{KPI_TARGET_MONTHLY=' . $kpi['id'] . '}'
                ]
            ];
        }

        return ['success' => true, 'placeholders' => $placeholders];

    } catch (Exception $e) {
        error_log("Błąd pobierania placeholderów KPI: " . $e->getMessage());
        return ['success' => false, 'message' => 'Błąd pobierania danych KPI'];
    }
}
?>