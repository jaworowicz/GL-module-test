
<?php
require_once '../includes/auth.php';
require_once '../includes/db.php';

auth_require_login();
header('Content-Type: application/json');

$action = $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'get_templates':
            echo json_encode(getTemplatesList());
            break;
            
        case 'get_template':
            echo json_encode(getTemplate($_POST['template_id']));
            break;
            
        case 'save_template':
            echo json_encode(saveTemplate($_POST));
            break;
            
        case 'delete_template':
            echo json_encode(deleteTemplate($_POST['template_id']));
            break;
            
        case 'preview_template':
            echo json_encode(previewTemplate($_POST['html_content'], $_POST['date'], $pdo));
            break;
            
        default:
            echo json_encode(['success' => false, 'message' => 'Nieznana akcja']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Błąd: ' . $e->getMessage()]);
}

function getTemplatesList() {
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
                'id' => basename($file, '.json'),
                'name' => $data['name'],
                'description' => $data['description'] ?? '',
                'created' => $data['created'] ?? ''
            ];
        }
    }
    
    return ['success' => true, 'templates' => $templates];
}

function getTemplate($templateId) {
    $file = __DIR__ . '/templates/' . $templateId . '.json';
    if (!file_exists($file)) {
        return ['success' => false, 'message' => 'Szablon nie istnieje'];
    }
    
    $data = json_decode(file_get_contents($file), true);
    return ['success' => true, 'template' => $data];
}

function saveTemplate($data) {
    $templateId = $data['template_id'] ?? uniqid();
    $templateData = [
        'id' => $templateId,
        'name' => $data['name'],
        'description' => $data['description'] ?? '',
        'html_content' => $data['html_content'],
        'created' => $data['created'] ?? date('Y-m-d H:i:s'),
        'modified' => date('Y-m-d H:i:s')
    ];
    
    $templatesDir = __DIR__ . '/templates/';
    if (!is_dir($templatesDir)) {
        mkdir($templatesDir, 0755, true);
    }
    
    $file = $templatesDir . $templateId . '.json';
    if (file_put_contents($file, json_encode($templateData, JSON_PRETTY_PRINT))) {
        return ['success' => true, 'template_id' => $templateId];
    }
    
    return ['success' => false, 'message' => 'Błąd zapisu szablonu'];
}

function deleteTemplate($templateId) {
    $file = __DIR__ . '/templates/' . $templateId . '.json';
    if (file_exists($file) && unlink($file)) {
        return ['success' => true];
    }
    return ['success' => false, 'message' => 'Błąd usuwania szablonu'];
}

function previewTemplate($htmlContent, $date, $pdo) {
    // Pobierz dane KPI dla podglądu
    $kpiData = getKpiDataForPreview($date, $pdo);
    
    // Przetwórz szablon
    $processedHtml = processTemplateContent($htmlContent, $kpiData, $date);
    
    return ['success' => true, 'preview' => $processedHtml];
}

function getKpiDataForPreview($date, $pdo) {
    try {
        $sfidId = $_SESSION['sfid_id'] ?? 1;
        
        // Pobierz cele KPI
        $kpiQuery = "SELECT * FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC LIMIT 5";
        $kpiStmt = $pdo->prepare($kpiQuery);
        $kpiStmt->execute([$sfidId]);
        $kpiGoals = $kpiStmt->fetchAll(PDO::FETCH_ASSOC);
        
        $kpiData = [];
        foreach ($kpiGoals as $goal) {
            // Pobierz wartości dla tego dnia
            $totalValue = rand(0, 50); // Przykładowe dane
            $dailyGoal = ceil($goal['total_goal'] / 22); // Szacunkowy cel dzienny
            
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

function processTemplateContent($template, $kpiData, $date) {
    // Zastąp datę raportu
    $template = str_replace('{REPORT_DATE}', date('d.m.Y', strtotime($date)), $template);
    $template = str_replace('{TODAY}', date('d.m.Y'), $template);
    
    // Zastąp placeholdery KPI
    foreach ($kpiData as $kpiId => $data) {
        $template = str_replace('{KPI_VALUE=' . $kpiId . '}', $data['value'], $template);
        $template = str_replace('{KPI_TARGET_DAILY=' . $kpiId . '}', $data['daily_goal'], $template);
        $template = str_replace('{KPI_TARGET_MONTHLY=' . $kpiId . '}', $data['monthly_goal'], $template);
        $template = str_replace('{KPI_NAME=' . $kpiId . '}', $data['name'], $template);
    }
    
    // Usuń nieużywane placeholdery
    $template = preg_replace('/\{KPI_[^}]+\}/', '-', $template);
    
    return $template;
}
?>
