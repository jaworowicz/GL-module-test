
<?php
// Redirect to the actual module
$cache_bust = time();
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Moduł Liczników - Preview</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #1e293b;
            color: #e2e8f0;
        }
        .preview-box {
            background: rgba(30, 41, 59, 0.7);
            border: 1px solid rgb(51, 65, 85);
            border-radius: 1rem;
            padding: 2rem;
            margin-bottom: 2rem;
        }
        .file-link {
            display: inline-block;
            background: #2563eb;
            color: white;
            padding: 8px 16px;
            margin: 4px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            border: none;
            cursor: pointer;
            font-family: inherit;
        }
        .file-link:hover {
            background: #1d4ed8;
        }
        .section {
            margin-bottom: 2rem;
        }
        h1, h2 {
            color: #34d399;
        }
    </style>
</head>
<body>
    <div class="preview-box">
        <h1>🎯 Moduł Liczników KPI - Preview</h1>
        <p>Moduł został zaimplementowany z wykorzystaniem bazy danych i struktury plików.</p>
        
        <div class="section">
            <h2>📁 Pliki Modułu</h2>
            <p>Kliknij aby otworzyć aktualną wersję pliku:</p>
            
            <div style="margin: 1rem 0;">
                <strong>Główne pliki aplikacji:</strong><br>
                <button onclick="openFile('attached_assets/index_1754263632477.php')" class="file-link">index.php (Main Interface)</button>
                <button onclick="openFile('attached_assets/script_1754263632477.js')" class="file-link">script.js (JavaScript Logic)</button>
                <button onclick="openFile('attached_assets/style_1754256276123.css')" class="file-link">style.css (Styles)</button>
                <button onclick="openFile('attached_assets/ajax_handler_1754256276122.php')" class="file-link">ajax_handler.php (API)</button>
            </div>
            
            <div style="margin: 1rem 0;">
                <strong>Pliki konfiguracyjne:</strong><br>
                <button onclick="openFile('attached_assets/auth_1754256310437.php')" class="file-link">auth.php (Authentication)</button>
                <button onclick="openFile('attached_assets/db_1754256310439.php')" class="file-link">db.php (Database)</button>
                <button onclick="openFile('attached_assets/header-test_1754256310440.php')" class="file-link">header-test.php (Header)</button>
                <button onclick="openFile('attached_assets/footer-new_1754256310439.php')" class="file-link">footer-new.php (Footer)</button>
            </div>
            
            <div style="margin: 1rem 0;">
                <strong>Baza danych:</strong><br>
                <button onclick="openFile('database/horusjcz_liberty.sql')" class="file-link">horusjcz_liberty.sql (Database Schema)</button>
                <button onclick="openFile('database/README.md')" class="file-link">Database README</button>
            </div>
            
            <div style="margin: 1rem 0;">
                <strong>Moduł publiczny:</strong><br>
                <button onclick="openFile('modules/licznik2/public.php')" class="file-link">public.php (Public View)</button>
                <button onclick="openFile('attached_assets/public_1754262607965.php')" class="file-link">public.php (Updated Version)</button>
            </div>
            
            <div style="margin: 1rem 0;">
                <strong>Mockupy i design:</strong><br>
                <a href="attached_assets/MOCKUP liczniki i kpi_1754256543960.html" class="file-link" target="_blank">MOCKUP (HTML Preview)</a>
            </div>
        </div>
        
        <div class="section">
            <h2>🚀 Uruchomienie Modułu</h2>
            <p>Aby uruchomić pełny moduł liczników:</p>
            <ol>
                <li>Zaimportuj bazę danych z pliku <code>database/horusjcz_liberty.sql</code></li>
                <li>Skonfiguruj połączenie w <code>includes/db.php</code></li>
                <li>Otwórz plik główny: <code>attached_assets/index_1754263632477.php</code></li>
                <li>Dla widoku publicznego: <code>modules/licznik2/public.php</code></li>
            </ol>
        </div>
        
        <div class="section">
            <h2>📋 Funkcjonalności</h2>
            <ul>
                <li>✅ System liczników osobistych i zespołowych</li>
                <li>✅ Kategorie i zarządzanie nimi</li>
                <li>✅ Cele KPI z automatycznym przeliczaniem</li>
                <li>✅ Widok siatki i listy</li>
                <li>✅ Nawigacja klawiaturą</li>
                <li>✅ Responsywny design</li>
                <li>✅ System uprawnień (user/admin/superadmin)</li>
                <li>✅ Widok publiczny z auto-refresh</li>
                <li>✅ Cache-busting dla CSS/JS (timestamp: <?php echo $cache_bust; ?>)</li>
            </ul>
        </div>
    </div>

    <script>
        function openFile(filePath) {
            // Try multiple methods to open files in Replit editor
            console.log('Attempting to open file:', filePath);
            
            // Method 1: Try postMessage to parent
            if (window.parent && window.parent !== window) {
                window.parent.postMessage({
                    type: 'openFile', 
                    path: filePath
                }, '*');
                console.log('Sent postMessage to parent');
            }
            
            // Method 2: Try Replit API if available
            if (window.replit && window.replit.openFile) {
                window.replit.openFile(filePath);
                console.log('Used Replit API');
            }
            
            // Method 3: Log information for debugging
            console.log('File path requested:', filePath);
            alert('Próba otwarcia pliku: ' + filePath + '\nSprawdź konsolę deweloperską (F12)');
        }
        
        // Debug information
        console.log('Preview page loaded');
        console.log('Window location:', window.location);
        console.log('Parent window:', window.parent !== window);
    </script>
</body>
</html>
