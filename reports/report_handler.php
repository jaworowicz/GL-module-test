
<?php
require_once '../../../includes/auth.php';
require_once '../../../includes/db.php';

auth_require_login();
header('Content-Type: application/json');

$action = $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'get_report_templates':
            echo json_encode(getCustomTemplates());
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

function getCustomTemplates() {
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
                'filename' => $data['id'],
                'name' => $data['name']
            ];
        }
    }

    // Dodaj domyślny szablon jeśli brak niestandardowych
    if (empty($templates)) {
        $templates[] = [
            'filename' => 'default.php',
            'name' => 'Domyślny raport KPI'
        ];
    }

    return ['success' => true, 'templates' => $templates];
}

function getReportPreview($templateId, $date, $pdo) {
    try {
        // Sprawdź czy to niestandardowy szablon
        $customTemplateFile = __DIR__ . '/templates/' . $templateId . '.json';

        if (file_exists($customTemplateFile)) {
            // Niestandardowy szablon
            $templateData = json_decode(file_get_contents($customTemplateFile), true);
            $htmlContent = $templateData['html_content'];
        } else {
            // Domyślny szablon
            $templatePath = __DIR__ . '/default.php';
            if (!file_exists($templatePath)) {
                return ['success' => false, 'message' => 'Szablon nie istnieje'];
            }
            $htmlContent = file_get_contents($templatePath);
        }

        // Pobierz dane KPI dla podglądu (tylko pierwsze 3 cele)
        $kpiData = getKpiDataForReport($date, $pdo, 3);

        // Przetwórz szablon
        $preview = processReportTemplate($htmlContent, $kpiData, $date, true);

        // Dla niestandardowych szablonów nie usuwaj HTML
        if (file_exists($customTemplateFile)) {
            return ['success' => true, 'preview' => $preview];
        }

        // Dla domyślnego szablonu usuń HTML i zwróć tylko tabelę
        $preview = preg_replace('/<html.*?<body[^>]*>/s', '', $preview);
        $preview = preg_replace('/<\/body>.*?<\/html>/s', '', $preview);
        $preview = preg_replace('/<head>.*?<\/head>/s', '', $preview);
        $preview = str_replace('<!DOCTYPE html>', '', $preview);

        return ['success' => true, 'preview' => $preview];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd przetwarzania szablonu: ' . $e->getMessage()];
    }
}

function generateReport($templateId, $date, $pdo) {
    try {
        // Sprawdź czy to niestandardowy szablon
        $customTemplateFile = __DIR__ . '/templates/' . $templateId . '.json';

        if (file_exists($customTemplateFile)) {
            // Niestandardowy szablon
            $templateData = json_decode(file_get_contents($customTemplateFile), true);
            $htmlContent = $templateData['html_content'];
        } else {
            // Domyślny szablon
            $templatePath = __DIR__ . '/default.php';
            if (!file_exists($templatePath)) {
                return ['success' => false, 'message' => 'Szablon nie istnieje'];
            }
            $htmlContent = file_get_contents($templatePath);
        }

        // Pobierz wszystkie dane KPI
        $kpiData = getKpiDataForReport($date, $pdo);

        // Przetwórz szablon
        $reportHtml = processReportTemplate($htmlContent, $kpiData, $date, false);

        return ['success' => true, 'html' => $reportHtml];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd generowania raportu: ' . $e->getMessage()];
    }
}

function getKpiDataForReport($date, $pdo, $limit = null) {
    try {
        $sfidId = $_SESSION['sfid_id'] ?? 1;

        // Pobierz cele KPI
        $kpiQuery = "SELECT * FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC";
        if ($limit) {
            $kpiQuery .= " LIMIT " . (int)$limit;
        }

        $kpiStmt = $pdo->prepare($kpiQuery);
        $kpiStmt->execute([$sfidId]);
        $kpiGoals = $kpiStmt->fetchAll(PDO::FETCH_ASSOC);

        $kpiData = [];

        foreach ($kpiGoals as $goal) {
            // Pobierz powiązane liczniki z osobnej tabeli
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
    $template = str_replace('{TODAY}', date('d.m.Y'), $template);

    // Zastąp placeholdery KPI - używaj rzeczywistych ID z bazy danych
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
        $template = '<div style="background: #f59e0b; color: white; padding: 10px; margin-bottom: 20px; border-radius: 5px;">
            <strong>PODGLĄD:</strong> Pokazane są tylko pierwsze 3 cele KPI
        </div>' . $template;
    }

    return $template;
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
?>
