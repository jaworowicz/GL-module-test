
<?php
require_once '../includes/auth.php';
require_once '../includes/db.php';

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
    if (empty($htmlContent)) {
        return ['success' => true, 'preview' => '<p style="color: #666;">Wpisz kod HTML aby zobaczyć podgląd...</p>'];
    }
    
    // Podstawowe dane do podglądu
    $sampleKpiData = [
        1 => ['value' => 25, 'daily_goal' => 30, 'monthly_goal' => 600, 'name' => 'Sprzedaż (przykład)'],
        2 => ['value' => 45, 'daily_goal' => 40, 'monthly_goal' => 800, 'name' => 'Kontakty (przykład)'],
        3 => ['value' => 12, 'daily_goal' => 15, 'monthly_goal' => 300, 'name' => 'Oferty (przykład)']
    ];
    
    // Przetwórz szablon
    $preview = processTemplatePreview($htmlContent, $sampleKpiData, $date);
    
    return ['success' => true, 'preview' => $preview];
}

function processTemplatePreview($template, $kpiData, $date) {
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
    $template = preg_replace('/\{KPI_[^}]+\}/', '<span style="color: #ff6b6b; font-weight: bold;">BRAK DANYCH</span>', $template);
    
    // Dodaj informację o podglądzie
    if (strpos($template, '<body') !== false) {
        $template = str_replace('<body', '<body style="border: 3px solid #3b82f6; margin: 10px; padding: 10px; position: relative;"', $template);
        $template = str_replace('<body', '<body><div style="position: absolute; top: 0; left: 0; right: 0; background: #3b82f6; color: white; padding: 10px; text-align: center; font-weight: bold;">PODGLĄD SZABLONU - DANE PRZYKŁADOWE</div><div style="margin-top: 50px;"', $template);
        $template = str_replace('</body>', '</div></body>', $template);
    }
    
    return $template;
}
?>
