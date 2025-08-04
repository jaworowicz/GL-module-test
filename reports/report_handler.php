
<?php
require_once '../../../includes/auth.php';
require_once '../../../includes/db.php';

auth_require_login();
header('Content-Type: application/json');

// Połączenie z bazą danych - używaj tego samego co główny moduł
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

    // Dodaj domyślny szablon jeśli brak niestandardowych
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

        // Pobierz WSZYSTKIE dane KPI - nie limituj w podglądzie
        $kpiData = getKpiDataForReport($date);
        
        // Debug - sprawdź czy dane zostały pobrane
        error_log("Debug KPI preview data for date $date: " . print_r($kpiData, true));

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

function generateReport($templateId, $date) {
    global $pdo;
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
        $kpiData = getKpiDataForReport($date);
        
        // Debug - sprawdź czy dane zostały pobrane
        error_log("Debug KPI data for date $date: " . print_r($kpiData, true));

        // Przetwórz szablon
        $reportHtml = processReportTemplate($htmlContent, $kpiData, $date, false);

        return ['success' => true, 'html' => $reportHtml];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd generowania raportu: ' . $e->getMessage()];
    }
}

function getKpiDataForReport($date, $limit = null) {
    global $pdo;
    try {
        // Pobierz sfid_id z sesji - użytkownik ma już przypisany SFID po zalogowaniu
        $sfidId = $_SESSION['sfid_id'] ?? null;
        if (!$sfidId) {
            error_log("Brak sfid_id w sesji dla raportu KPI");
            return [];
        }

        // Pobierz WSZYSTKIE cele KPI dla konkretnego SFID - UŻYWAJ RZECZYWISTYCH ID Z BAZY
        $kpiQuery = "SELECT id, name, total_goal, sfid_id FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC";
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

            // POBIERZ WARTOŚCI DLA CAŁEGO ZESPOŁU Z LOKALIZACJI - nie tylko dla jednego użytkownika
            $totalValue = 0;
            if (!empty($linkedCounterIds)) {
                $placeholders = str_repeat('?,', count($linkedCounterIds) - 1) . '?';

                // Pobierz wszystkich użytkowników z tej samej lokalizacji (sfid_id)
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

    // UŻYJ RZECZYWISTYCH ID Z SZABLONU - bez mapowania pozycyjnego  
    foreach ($kpiData as $kpiId => $data) {
        $template = str_replace('{KPI_VALUE=' . $kpiId . '}', $data['value'], $template);
        $template = str_replace('{KPI_TARGET_DAILY=' . $kpiId . '}', $data['daily_goal'], $template);
        $template = str_replace('{KPI_TARGET_MONTHLY=' . $kpiId . '}', $data['monthly_goal'], $template);
        $template = str_replace('{KPI_NAME=' . $kpiId . '}', $data['name'], $template);
    }

    // Usuń nieużywane placeholdery
    $template = preg_replace('/\{KPI_[^}]+\}/', '-', $template);

    // W podglądzie dodaj informację
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
        if ($dayOfWeek < 6) { // Poniedziałek-Piątek
            $workingDays++;
        }
        $start->add(new DateInterval('P1D'));
    }

    return $workingDays;
}
?>
