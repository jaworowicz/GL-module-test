
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
                $debugInfo = getDebugInfo($date, $pdo);
                return [
                    'success' => false, 
                    'message' => 'Szablon nie istnieje',
                    'debug' => $debugInfo
                ];
            }
            $htmlContent = file_get_contents($templatePath);
        }

        $kpiData = getKpiDataForReport($date, $pdo);
        $debugInfo = getDebugInfo($date, $pdo);
        $preview = processReportTemplate($htmlContent, $kpiData, $date, true);

        // Dodaj debug info bezpośrednio do preview HTML
        $debugHtml = '<div style="background: #1e293b; color: #e2e8f0; padding: 15px; margin: 10px 0; border-radius: 8px; border: 2px solid #3b82f6;">
            <h3 style="color: #60a5fa; margin: 0 0 10px 0;">🔍 DEBUG INFO RAPORTU</h3>
            <pre style="background: #0f172a; padding: 10px; border-radius: 5px; overflow-x: auto; font-size: 12px; color: #94a3b8;">' . 
            htmlspecialchars(json_encode($debugInfo, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)) . '</pre>
        </div>';

        return [
            'success' => true, 
            'preview' => $debugHtml . $preview,
            'debug' => $debugInfo
        ];

    } catch (Exception $e) {
        $debugInfo = getDebugInfo($date, $pdo);
        return [
            'success' => false, 
            'message' => 'Błąd przetwarzania szablonu: ' . $e->getMessage(),
            'debug' => $debugInfo
        ];
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
            // DEBUG: Brak sfid_id w sesji
            return [];
        }

        // DEBUG: sfid_id = $sfidId, date = $date
        $year = date('Y', strtotime($date));
        $month = date('n', strtotime($date));

        // Pobierz WSZYSTKIE cele KPI dla lokalizacji
        $kpiQuery = "SELECT id, name, total_goal FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC";
        $kpiStmt = $pdo->prepare($kpiQuery);
        $kpiStmt->execute([$sfidId]);
        $kpiGoals = $kpiStmt->fetchAll(PDO::FETCH_ASSOC);

        // DEBUG: Znalezione KPI: count = " . count($kpiGoals)
        $kpiData = [];

        foreach ($kpiGoals as $goal) {
            // DEBUG: Przetwarzam KPI ID=" . $goal['id'] . " (" . $goal['name'] . ")
            
            // Pobierz powiązane liczniki
            $linkedQuery = "SELECT counter_id FROM licznik_kpi_linked_counters WHERE kpi_goal_id = ?";
            $linkedStmt = $pdo->prepare($linkedQuery);
            $linkedStmt->execute([$goal['id']]);
            $linkedCounterIds = $linkedStmt->fetchAll(PDO::FETCH_COLUMN);

            // DEBUG: KPI " . $goal['id'] . " - powiązane liczniki: count = " . count($linkedCounterIds)

            $dailyValue = 0;
            $monthlyRealization = 0;
            
            if (!empty($linkedCounterIds)) {
                $placeholders = str_repeat('?,', count($linkedCounterIds) - 1) . '?';
                
                // Pobierz liczniki zespołowe dla tej lokalizacji
                $teamQuery = "SELECT DISTINCT lc.id, lc.name, u.name as user_name
                             FROM licznik_counters lc 
                             INNER JOIN users u ON lc.user_id = u.id 
                             WHERE u.sfid_id = ? 
                             AND lc.id IN ($placeholders)
                             AND lc.is_active = 1";

                $teamParams = array_merge([$sfidId], $linkedCounterIds);
                $teamStmt = $pdo->prepare($teamQuery);
                $teamStmt->execute($teamParams);
                $teamCounters = $teamStmt->fetchAll(PDO::FETCH_ASSOC);
                $teamCounterIds = array_column($teamCounters, 'id');
                
                // DEBUG: Zespołowe liczniki dla KPI " . $goal['id'] . ": count = " . count($teamCounters)

                if (!empty($teamCounterIds)) {
                    $teamPlaceholders = str_repeat('?,', count($teamCounterIds) - 1) . '?';
                    
                    // Wartość za dany dzień
                    $dailyQuery = "SELECT counter_id, value, date FROM licznik_daily_values 
                                  WHERE counter_id IN ($teamPlaceholders) 
                                  AND date = ?";
                    $dailyParams = array_merge($teamCounterIds, [$date]);
                    $dailyStmt = $pdo->prepare($dailyQuery);
                    $dailyStmt->execute($dailyParams);
                    $dailyValues = $dailyStmt->fetchAll(PDO::FETCH_ASSOC);
                    $dailyValue = array_sum(array_column($dailyValues, 'value'));
                    
                    // DEBUG: Wartości dzienne dla daty $date: count = " . count($dailyValues) . ", suma = $dailyValue

                    // REALIZACJA MIESIĘCZNA (potrzebna do dynamicznego celu dziennego)
                    $monthlyQuery = "SELECT counter_id, SUM(value) as total, COUNT(*) as days
                                    FROM licznik_daily_values 
                                    WHERE counter_id IN ($teamPlaceholders) 
                                    AND YEAR(date) = ? AND MONTH(date) = ?
                                    GROUP BY counter_id";
                    $monthlyParams = array_merge($teamCounterIds, [$year, $month]);
                    $monthlyStmt = $pdo->prepare($monthlyQuery);
                    $monthlyStmt->execute($monthlyParams);
                    $monthlyValues = $monthlyStmt->fetchAll(PDO::FETCH_ASSOC);
                    $monthlyRealization = array_sum(array_column($monthlyValues, 'total'));
                    
                    // DEBUG: Realizacja miesięczna ($year-$month): suma = $monthlyRealization
                }
            }

            // Oblicz DYNAMICZNY cel dzienny (uwzględniający realizację miesięczną)
            $dailyGoal = calculateDynamicDailyGoal($goal['total_goal'], $monthlyRealization, $year, $month, $sfidId);

            // DEBUG: KPI " . $goal['id'] . " - cel dzienny: $dailyGoal

            $kpiData[$goal['id']] = [
                'value' => $dailyValue,
                'daily_goal' => $dailyGoal,
                'monthly_goal' => $goal['total_goal'],
                'monthly_realization' => $monthlyRealization,
                'name' => $goal['name']
            ];

            // DEBUG: Finalne dane dla KPI " . $goal['id'] . " - value: $dailyValue, daily_goal: $dailyGoal
        }

        // DEBUG: WSZYSTKIE DANE KPI (finalne): count = " . count($kpiData)
        return $kpiData;

    } catch (Exception $e) {
        // DEBUG ERROR: " . $e->getMessage()
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

function getDebugInfo($date, $pdo) {
    $debug = [];
    $sfidId = $_SESSION['sfid_id'] ?? null;
    
    $debug['session_sfid'] = $sfidId;
    $debug['report_date'] = $date;
    $debug['current_time'] = date('Y-m-d H:i:s');
    
    if (!$sfidId) {
        $debug['error'] = 'Brak sfid_id w sesji - użytkownik nie jest przypisany do lokalizacji';
        return $debug;
    }
    
    try {
        // Sprawdź cele KPI dla lokalizacji
        $kpiQuery = "SELECT id, name, total_goal FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC";
        $kpiStmt = $pdo->prepare($kpiQuery);
        $kpiStmt->execute([$sfidId]);
        $kpiGoals = $kpiStmt->fetchAll(PDO::FETCH_ASSOC);
        
        $debug['kpi_goals_count'] = count($kpiGoals);
        $debug['kpi_goals'] = [];
        
        foreach ($kpiGoals as $goal) {
            $kpiInfo = [
                'id' => $goal['id'],
                'name' => $goal['name'],
                'monthly_goal' => $goal['total_goal']
            ];
            
            // Sprawdź powiązane liczniki
            $linkedQuery = "SELECT counter_id FROM licznik_kpi_linked_counters WHERE kpi_goal_id = ?";
            $linkedStmt = $pdo->prepare($linkedQuery);
            $linkedStmt->execute([$goal['id']]);
            $linkedCounterIds = $linkedStmt->fetchAll(PDO::FETCH_COLUMN);
            
            $kpiInfo['linked_counters_count'] = count($linkedCounterIds);
            $kpiInfo['linked_counter_ids'] = $linkedCounterIds;
            
            if (!empty($linkedCounterIds)) {
                $placeholders = str_repeat('?,', count($linkedCounterIds) - 1) . '?';
                
                // Sprawdź liczniki zespołowe
                $teamQuery = "SELECT lc.id, lc.name, u.name as user_name, u.sfid_id
                             FROM licznik_counters lc 
                             INNER JOIN users u ON lc.user_id = u.id 
                             WHERE u.sfid_id = ? 
                             AND lc.id IN ($placeholders)
                             AND lc.is_active = 1";
                
                $teamParams = array_merge([$sfidId], $linkedCounterIds);
                $teamStmt = $pdo->prepare($teamQuery);
                $teamStmt->execute($teamParams);
                $teamCounters = $teamStmt->fetchAll(PDO::FETCH_ASSOC);
                
                $kpiInfo['team_counters_count'] = count($teamCounters);
                $kpiInfo['team_counters'] = $teamCounters;
                
                $teamCounterIds = array_column($teamCounters, 'id');
                
                if (!empty($teamCounterIds)) {
                    $teamPlaceholders = str_repeat('?,', count($teamCounterIds) - 1) . '?';
                    
                    // Sprawdź wartości za dzień
                    $dailyQuery = "SELECT counter_id, value, date FROM licznik_daily_values 
                                  WHERE counter_id IN ($teamPlaceholders) 
                                  AND date = ?";
                    $dailyParams = array_merge($teamCounterIds, [$date]);
                    $dailyStmt = $pdo->prepare($dailyQuery);
                    $dailyStmt->execute($dailyParams);
                    $dailyValues = $dailyStmt->fetchAll(PDO::FETCH_ASSOC);
                    
                    $kpiInfo['daily_values_count'] = count($dailyValues);
                    $kpiInfo['daily_values'] = $dailyValues;
                    $kpiInfo['daily_total'] = array_sum(array_column($dailyValues, 'value'));
                    
                    // Sprawdź realizację miesięczną
                    $year = date('Y', strtotime($date));
                    $month = date('n', strtotime($date));
                    
                    $monthlyQuery = "SELECT counter_id, SUM(value) as total, COUNT(*) as days
                                    FROM licznik_daily_values 
                                    WHERE counter_id IN ($teamPlaceholders) 
                                    AND YEAR(date) = ? AND MONTH(date) = ?
                                    GROUP BY counter_id";
                    $monthlyParams = array_merge($teamCounterIds, [$year, $month]);
                    $monthlyStmt = $pdo->prepare($monthlyQuery);
                    $monthlyStmt->execute($monthlyParams);
                    $monthlyValues = $monthlyStmt->fetchAll(PDO::FETCH_ASSOC);
                    
                    $kpiInfo['monthly_realization'] = array_sum(array_column($monthlyValues, 'total'));
                    $kpiInfo['monthly_values'] = $monthlyValues;
                }
            }
            
            $debug['kpi_goals'][] = $kpiInfo;
        }
        
    } catch (Exception $e) {
        $debug['error'] = 'Błąd pobierania danych: ' . $e->getMessage();
    }
    
    return $debug;
}
?>
