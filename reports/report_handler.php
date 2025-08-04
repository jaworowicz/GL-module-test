
<?php
session_start();
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

        $kpiData = getKpiDataForReport($date, $pdo);
        $preview = processReportTemplate($htmlContent, $kpiData, $date, true);

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

        $kpiData = getKpiDataForReport($date, $pdo);
        $reportHtml = processReportTemplate($htmlContent, $kpiData, $date, false);

        return ['success' => true, 'html' => $reportHtml];

    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Błąd generowania raportu: ' . $e->getMessage()];
    }
}

function getKpiDataForReport($date, $pdo) {
    try {
        $sfidId = $_SESSION['sfid_id'] ?? null;
        if (!$sfidId) {
            return [];
        }

        $year = date('Y', strtotime($date));
        $month = date('n', strtotime($date));

        // Pobierz WSZYSTKIE cele KPI dla lokalizacji
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

            $dailyValue = 0;
            $monthlyRealization = 0;
            
            if (!empty($linkedCounterIds)) {
                $placeholders = str_repeat('?,', count($linkedCounterIds) - 1) . '?';
                
                // Pobierz liczniki zespołowe dla tej lokalizacji
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
                    
                    // Wartość za dany dzień
                    $dailyQuery = "SELECT SUM(value) as total 
                                  FROM licznik_daily_values 
                                  WHERE counter_id IN ($teamPlaceholders) 
                                  AND date = ?";
                    $dailyParams = array_merge($teamCounterIds, [$date]);
                    $dailyStmt = $pdo->prepare($dailyQuery);
                    $dailyStmt->execute($dailyParams);
                    $dailyValue = $dailyStmt->fetchColumn() ?: 0;

                    // REALIZACJA MIESIĘCZNA (potrzebna do dynamicznego celu dziennego)
                    $monthlyQuery = "SELECT SUM(value) as total 
                                    FROM licznik_daily_values 
                                    WHERE counter_id IN ($teamPlaceholders) 
                                    AND YEAR(date) = ? AND MONTH(date) = ?";
                    $monthlyParams = array_merge($teamCounterIds, [$year, $month]);
                    $monthlyStmt = $pdo->prepare($monthlyQuery);
                    $monthlyStmt->execute($monthlyParams);
                    $monthlyRealization = $monthlyStmt->fetchColumn() ?: 0;
                }
            }

            // Oblicz DYNAMICZNY cel dzienny (uwzględniający realizację miesięczną)
            $dailyGoal = calculateDynamicDailyGoal($goal['total_goal'], $monthlyRealization, $year, $month, $sfidId);

            $kpiData[$goal['id']] = [
                'value' => $dailyValue,
                'daily_goal' => $dailyGoal,
                'monthly_goal' => $goal['total_goal'],
                'monthly_realization' => $monthlyRealization,
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

    // Najpierw pobierz WSZYSTKIE dostępne KPI z bazy danych dla tej lokalizacji
    global $pdo;
    $sfidId = $_SESSION['sfid_id'] ?? null;
    
    if ($sfidId) {
        $allKpiQuery = "SELECT id, name, total_goal FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC";
        $allKpiStmt = $pdo->prepare($allKpiQuery);
        $allKpiStmt->execute([$sfidId]);
        $allKpiGoals = $allKpiStmt->fetchAll(PDO::FETCH_ASSOC);

        // Zastąp placeholdery dla WSZYSTKICH KPI (również tych bez danych)
        foreach ($allKpiGoals as $kpi) {
            $kpiId = $kpi['id'];
            
            // Jeśli mamy dane dla tego KPI, użyj ich
            if (isset($kpiData[$kpiId])) {
                $data = $kpiData[$kpiId];
                $template = str_replace('{KPI_VALUE=' . $kpiId . '}', $data['value'], $template);
                $template = str_replace('{KPI_TARGET_DAILY=' . $kpiId . '}', $data['daily_goal'], $template);
                $template = str_replace('{KPI_TARGET_MONTHLY=' . $kpiId . '}', $data['monthly_goal'], $template);
            } else {
                // Jeśli nie ma danych, wstaw wartości domyślne (0 lub puste)
                $template = str_replace('{KPI_VALUE=' . $kpiId . '}', '0', $template);
                
                // Oblicz cel dzienny na podstawie celu miesięcznego
                $dailyGoal = 0;
                if ($kpi['total_goal'] > 0) {
                    $monthStart = date('Y-m-01', strtotime($date));
                    $monthEnd = date('Y-m-t', strtotime($date));
                    $workingDays = calculateWorkingDaysInRange($monthStart, $monthEnd);
                    $dailyGoal = ceil($kpi['total_goal'] / $workingDays);
                }
                
                $template = str_replace('{KPI_TARGET_DAILY=' . $kpiId . '}', $dailyGoal, $template);
                $template = str_replace('{KPI_TARGET_MONTHLY=' . $kpiId . '}', $kpi['total_goal'], $template);
            }
            
            // ZAWSZE zastąp nazwę KPI (etykieta powinna być zawsze widoczna)
            $template = str_replace('{KPI_NAME=' . $kpiId . '}', htmlspecialchars($kpi['name']), $template);
        }
    }

    // Usuń TYLKO pozostałe nieznane placeholdery (które nie mają odpowiedniego KPI w bazie)
    $template = preg_replace('/\{KPI_[^}]+\}/', '<span style="color: #ff6b6b;">Brak KPI</span>', $template);

    if ($isPreview) {
        $dataInfo = !empty($kpiData) ? 'RZECZYWISTE DANE' : 'BRAK DANYCH - POKAZANO WARTOŚCI ZEROWE';
        $headerColor = !empty($kpiData) ? '#16a34a' : '#f59e0b';
        
        $template = '<div style="background: ' . $headerColor . '; color: white; padding: 10px; margin-bottom: 20px; border-radius: 5px;">
            <strong>PODGLĄD RAPORTU ZESPOŁOWEGO</strong> - ' . $dataInfo . ' za dzień: ' . date('d.m.Y', strtotime($date)) . '
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

// Oblicz dynamiczny cel dzienny uwzględniający zespołową realizację i pozostałe dni
function calculateDynamicDailyGoal($totalGoal, $currentRealization, $year, $month, $sfidId) {
    global $pdo;
    
    // Pobierz dni robocze z tabeli lub oblicz automatycznie
    $workingDaysQuery = "SELECT working_days FROM global_working_hours WHERE sfid_id = ? AND year = ? AND month = ?";
    $stmt = $pdo->prepare($workingDaysQuery);
    $stmt->execute([$sfidId, $year, $month]);
    $workingDaysData = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $totalWorkingDays = $workingDaysData['working_days'] ?? getWorkingDaysInMonth($year, $month);
    
    $today = date('j');
    $currentMonth = date('n');
    $currentYear = date('Y');
    
    $remainingWorkingDays = $totalWorkingDays;
    
    // Jeśli to bieżący miesiąc, oblicz pozostałe dni robocze
    if ($year == $currentYear && $month == $currentMonth) {
        $remainingWorkingDays = 0;
        for ($day = $today; $day <= cal_days_in_month(CAL_GREGORIAN, $month, $year); $day++) {
            $dayOfWeek = date('N', mktime(0, 0, 0, $month, $day, $year));
            if ($dayOfWeek < 6) {
                $remainingWorkingDays++;
            }
        }
    }
    
    // Oblicz ile jeszcze trzeba zrealizować
    $remainingGoal = max(0, $totalGoal - $currentRealization);
    
    if ($remainingWorkingDays <= 0) {
        return 0;
    }
    
    // Cel dzienny = pozostały cel / pozostałe dni robocze
    return round($remainingGoal / $remainingWorkingDays);
}

function getWorkingDaysInMonth($year, $month) {
    $workingDays = 0;
    $daysInMonth = cal_days_in_month(CAL_GREGORIAN, $month, $year);
    
    for ($day = 1; $day <= $daysInMonth; $day++) {
        $dayOfWeek = date('N', mktime(0, 0, 0, $month, $day, $year));
        if ($dayOfWeek < 6) {
            $workingDays++;
        }
    }
    
    return $workingDays;
}
?>
