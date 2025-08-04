
<?php
require_once '../../../includes/auth.php';
require_once '../../../includes/db.php';

auth_require_login();
header('Content-Type: application/json');

global $pdo;

$action = $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'get_report_templates':
            echo json_encode(getCustomTemplates());
            break;

        case 'get_report_preview':
            echo json_encode(getReportPreview($_POST['template'], $_POST['date']));
            break;

        case 'generate_report':
            echo json_encode(generateReport($_POST['template'], $_POST['date']));
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

    if (empty($templates)) {
        $templates[] = [
            'filename' => 'default.php',
            'name' => 'Domyślny raport KPI'
        ];
    }

    return ['success' => true, 'templates' => $templates];
}

function getReportPreview($templateId, $date) {
    global $pdo;
    try {
        $customTemplateFile = __DIR__ . '/templates/' . $templateId . '.json';

        if (file_exists($customTemplateFile)) {
            $templateData = json_decode(file_get_contents($customTemplateFile), true);
            $htmlContent = $templateData['html_content'];
        } else {
            $templatePath = __DIR__ . '/default.php';
            if (!file_exists($templatePath)) {
                return ['success' => false, 'message' => 'Szablon nie istnieje'];
            }
            $htmlContent = file_get_contents($templatePath);
        }

        $kpiData = getKpiDataForReport($date);
        $preview = processReportTemplate($htmlContent, $kpiData, $date, true);

        if (file_exists($customTemplateFile)) {
            return ['success' => true, 'preview' => $preview];
        }

        $preview = preg_replace('/<html.*?<body[^>]*>/s', '', $preview);
        $preview = preg_replace('/<\/body>.*?<\/html>/s', '', $preview);
        $preview = preg_replace('/<head>.*?<\/head>/s', '', $preview);
        $preview = str_replace('<!DOCTYPE html>', '', $preview);

        return ['success' => true, 'preview' => $preview];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd przetwarzania szablonu: ' . $e->getMessage()];
    }
}

function generateReport($templateId, $date) {
    global $pdo;
    try {
        $customTemplateFile = __DIR__ . '/templates/' . $templateId . '.json';

        if (file_exists($customTemplateFile)) {
            $templateData = json_decode(file_get_contents($customTemplateFile), true);
            $htmlContent = $templateData['html_content'];
        } else {
            $templatePath = __DIR__ . '/default.php';
            if (!file_exists($templatePath)) {
                return ['success' => false, 'message' => 'Szablon nie istnieje'];
            }
            $htmlContent = file_get_contents($templatePath);
        }

        $kpiData = getKpiDataForReport($date);
        $reportHtml = processReportTemplate($htmlContent, $kpiData, $date, false);

        return ['success' => true, 'html' => $reportHtml];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd generowania raportu: ' . $e->getMessage()];
    }
}

function getKpiDataForReport($date) {
    global $pdo;
    try {
        $sfidId = $_SESSION['sfid_id'] ?? null;
        if (!$sfidId) {
            error_log("Brak sfid_id w sesji dla raportu KPI");
            return [];
        }

        // Pobierz WSZYSTKIE cele KPI dla lokalizacji - RZECZYWISTE ID
        $kpiQuery = "SELECT id, name, total_goal FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC";
        $kpiStmt = $pdo->prepare($kpiQuery);
        $kpiStmt->execute([$sfidId]);
        $kpiGoals = $kpiStmt->fetchAll(PDO::FETCH_ASSOC);

        $kpiData = [];

        foreach ($kpiGoals as $goal) {
            // Pobierz powiązane liczniki
            $linkedQuery = "SELECT counter_id FROM licznik_kpi_linked_counters WHERE kpi_goal_id = ?";
            $linkedStmt = $pdo->prepare($linkedQuery);
            $linkedStmt->execute([$goal['id']]);
            $linkedCounterIds = $linkedStmt->fetchAll(PDO::FETCH_COLUMN);

            $totalValue = 0;
            if (!empty($linkedCounterIds)) {
                $placeholders = str_repeat('?,', count($linkedCounterIds) - 1) . '?';
                
                // Pobierz wartości dla CAŁEGO ZESPOŁU z lokalizacji
                $teamQuery = "SELECT DISTINCT lc.id
                             FROM licznik_counters lc 
                             INNER JOIN users u ON lc.user_id = u.id 
                             WHERE u.sfid_id = ? 
                             AND lc.id IN ($placeholders)";

                $teamParams = array_merge([$sfidId], $linkedCounterIds);
                $teamStmt = $pdo->prepare($teamQuery);
                $teamStmt->execute($teamParams);
                $teamCounterIds = $teamStmt->fetchAll(PDO::FETCH_COLUMN);

                if (!empty($teamCounterIds)) {
                    $teamPlaceholders = str_repeat('?,', count($teamCounterIds) - 1) . '?';
                    $valueQuery = "SELECT SUM(value) as total 
                                  FROM licznik_daily_values 
                                  WHERE counter_id IN ($teamPlaceholders) 
                                  AND date = ?";

                    $params = array_merge($teamCounterIds, [$date]);
                    $valueStmt = $pdo->prepare($valueQuery);
                    $valueStmt->execute($params);
                    $totalValue = $valueStmt->fetchColumn() ?: 0;
                }
            }

            // Oblicz cel dzienny
            $dailyGoal = 0;
            if ($goal['total_goal'] > 0) {
                $monthStart = date('Y-m-01', strtotime($date));
                $monthEnd = date('Y-m-t', strtotime($date));
                $workingDays = calculateWorkingDaysInRange($monthStart, $monthEnd);
                $dailyGoal = ceil($goal['total_goal'] / $workingDays);
            }

            // UŻYJ RZECZYWISTEGO ID Z BAZY - nie pozycyjnego
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

function processReportTemplate($template, $kpiData, $date, $isPreview = false) {
    // Zastąp datę raportu
    $template = str_replace('{REPORT_DATE}', date('d.m.Y', strtotime($date)), $template);
    $template = str_replace('{TODAY}', date('d.m.Y'), $template);

    // UŻYJ RZECZYWISTYCH ID Z BAZY DANYCH - nie pozycyjnych
    foreach ($kpiData as $kpiId => $data) {
        $template = str_replace('{KPI_VALUE=' . $kpiId . '}', $data['value'], $template);
        $template = str_replace('{KPI_TARGET_DAILY=' . $kpiId . '}', $data['daily_goal'], $template);
        $template = str_replace('{KPI_TARGET_MONTHLY=' . $kpiId . '}', $data['monthly_goal'], $template);
        $template = str_replace('{KPI_NAME=' . $kpiId . '}', $data['name'], $template);
    }

    // Usuń nieużywane placeholdery
    $template = preg_replace('/\{KPI_[^}]+\}/', '-', $template);

    if ($isPreview) {
        $template = '<div style="background: #16a34a; color: white; padding: 10px; margin-bottom: 20px; border-radius: 5px;">
            <strong>PODGLĄD RAPORTU ZESPOŁOWEGO</strong> - dane całej lokalizacji za dzień: ' . date('d.m.Y', strtotime($date)) . '
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
        if ($dayOfWeek < 6) {
            $workingDays++;
        }
        $start->add(new DateInterval('P1D'));
    }

    return $workingDays;
}
?>
