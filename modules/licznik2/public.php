
<?php
define('IS_PUBLIC_PAGE', true);
require_once '../../includes/db.php';

// Pobierz SFID z URL
$sfid = $_GET['sfid'] ?? null;
if (!$sfid || !is_numeric($sfid)) {
    die('Nieprawidłowy kod lokalizacji');
}

// Sprawdź czy lokalizacja istnieje
$location_query = "SELECT name, address FROM sfid_locations WHERE id = ? AND is_active = 1";
$location_stmt = $pdo->prepare($location_query);
$location_stmt->execute([$sfid]);
$location = $location_stmt->fetch(PDO::FETCH_ASSOC);

if (!$location) {
    die('Lokalizacja nie istnieje lub została dezaktywowana');
}

// Obsługa parametru date z URL lub domyślnie dzisiaj
$selected_date = $_GET['date'] ?? date('Y-m-d');
$today = date('Y-m-d');
$current_month = date('Y-m');

// Ustal miesiąc dla KPI na podstawie wybranej daty
$selected_date_obj = new DateTime($selected_date);
$kpi_year = $selected_date_obj->format('Y');
$kpi_month = $selected_date_obj->format('n');

// Debug - sprawdź czy miesiąc jest poprawny
error_log("Selected date: $selected_date, KPI Year: $kpi_year, KPI Month: $kpi_month");

// Pobierz liczniki dla tej lokalizacji
$counters_query = "
    SELECT
        c.id,
        c.title,
        c.type,
        c.symbol,
        cat.name as category,
        cat.color as category_color,
        SUM(COALESCE(dv.value, 0)) as total_value
    FROM licznik_counters c
    LEFT JOIN licznik_categories cat ON c.category_id = cat.id
    LEFT JOIN licznik_daily_values dv ON c.id = dv.counter_id AND dv.date = ?
    WHERE c.sfid_id = ? AND c.is_active = 1
    GROUP BY c.id
    ORDER BY c.sort_order, c.title
";

$counters_stmt = $pdo->prepare($counters_query);
$counters_stmt->execute([$selected_date, $sfid]);
$counters = $counters_stmt->fetchAll(PDO::FETCH_ASSOC);

// Pobierz cele KPI tylko jeśli są liczniki
$kpi_goals = [];
if (!empty($counters)) {
    $kpi_query = "
        SELECT
            kg.id,
            kg.name,
            kg.total_goal,
            GROUP_CONCAT(klc.counter_id) as linked_counter_ids
        FROM licznik_kpi_goals kg
        LEFT JOIN licznik_kpi_linked_counters klc ON kg.id = klc.kpi_goal_id
        WHERE kg.sfid_id = ? AND kg.is_active = 1
        GROUP BY kg.id
        ORDER BY kg.name
    ";

    $kpi_stmt = $pdo->prepare($kpi_query);
    $kpi_stmt->execute([$sfid]);
    $kpi_goals = $kpi_stmt->fetchAll(PDO::FETCH_ASSOC);

    // Oblicz realizację KPI dla miesiąca wybranej daty
    foreach ($kpi_goals as &$goal) {
        $linkedIds = $goal['linked_counter_ids'] ? explode(',', $goal['linked_counter_ids']) : [];
        $monthly_total = 0;
        
        if (!empty($linkedIds)) {
            $placeholders = str_repeat('?,', count($linkedIds) - 1) . '?';
            $realization_query = "
                SELECT COALESCE(SUM(dv.value), 0) as total
                FROM licznik_daily_values dv
                WHERE dv.counter_id IN ($placeholders)
                AND YEAR(dv.date) = ? AND MONTH(dv.date) = ?
            ";
            
            $params = array_merge($linkedIds, [$kpi_year, $kpi_month]);
            
            // Debug - sprawdź parametry zapytania
            error_log("KPI Query params: " . json_encode($params) . " for goal: " . $goal['name']);
            
            $realization_stmt = $pdo->prepare($realization_query);
            $realization_stmt->execute($params);
            $monthly_total = $realization_stmt->fetchColumn();
            
            // Debug - sprawdź wynik
            error_log("Monthly total for goal " . $goal['name'] . ": " . $monthly_total);
        }
        
        $goal['monthly_total'] = $monthly_total;
        $goal['progress_percent'] = $goal['total_goal'] > 0 ? min(100, ($monthly_total / $goal['total_goal']) * 100) : 0;
    }
}
?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($location['name']) ?> - <?= date('d.m.Y', strtotime($selected_date)) ?></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body { 
            font-family: 'Inter', sans-serif; 
            background: linear-gradient(-45deg, #0f2027, #203a43, #2c5364, #1c3d52); 
            background-size: 400% 400%; 
            animation: gradientBG 15s ease infinite;
            min-height: 100vh;
        }
        @keyframes gradientBG { 
            0% { background-position: 0% 50%; } 
            50% { background-position: 100% 50%; } 
            100% { background-position: 0% 50%; } 
        }
        .counter-card {
            background: rgba(30, 41, 59, 0.7);
            border: 1px solid rgb(51, 65, 85);
            border-radius: 1rem;
            transition: all 0.3s ease;
        }
        .counter-card:hover {
            background: rgba(30, 41, 59, 0.9);
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
        }
        .progress-bar {
            background: rgba(55, 65, 81, 0.5);
            border-radius: 0.25rem;
            overflow: hidden;
            border: 1px solid rgb(75, 85, 99);
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, rgb(34, 197, 94), rgb(16, 185, 129));
            transition: width 0.3s ease;
            border-radius: 0.25rem;
        }
        .date-button {
            background: rgba(71, 85, 105, 0.6);
            border: 1px solid rgb(100, 116, 139);
            transition: all 0.2s ease;
        }
        .date-button:hover {
            background: rgba(100, 116, 139, 0.6);
            transform: scale(1.05);
        }
        .date-button.active {
            background: rgba(34, 197, 94, 0.8) !important;
            border-color: rgb(34, 197, 94) !important;
            transform: scale(1.05);
            box-shadow: 0 0 0 2px rgba(34, 197, 94, 0.3);
        }
        .date-button.today {
            background: rgba(34, 197, 94, 0.5);
            border-color: rgb(22, 163, 74);
        }
        .date-button.today:hover {
            background: rgba(34, 197, 94, 0.6);
        }
    </style>
</head>
<body class="bg-slate-900 text-white antialiased">
    <div class="container mx-auto px-4 py-8">
        <header class="text-center mb-8">
            <h1 class="text-4xl font-bold text-white mb-2"><?= htmlspecialchars($location['name']) ?></h1>
            <h2 class="text-2xl text-slate-300 mb-4">Kod lokalizacji: <?= htmlspecialchars($sfid) ?></h2>
            
            <!-- Przyciski zmiany daty -->
            <div class="flex justify-center items-center gap-2 mb-4 flex-wrap">
                <button onclick="changeDate('yesterday')" class="date-button text-white px-4 py-2 rounded-lg" data-period="yesterday">
                    <i class="fas fa-chevron-left mr-1"></i> Wczoraj
                </button>
                
                <button onclick="changeDate('current_month')" class="date-button text-white px-4 py-2 rounded-lg" data-period="current_month">
                    <i class="fas fa-calendar-alt mr-1"></i> Ten miesiąc
                </button>
                
                <button onclick="changeDate('previous_month')" class="date-button text-white px-4 py-2 rounded-lg" data-period="previous_month">
                    <i class="fas fa-calendar-alt mr-1"></i> Poprzedni miesiąc
                </button>
                
                <button onclick="changeDate('today')" class="date-button today text-white px-4 py-2 rounded-lg" data-period="today">
                    <i class="fas fa-calendar-day mr-1"></i> Dziś
                </button>
            </div>
            
            <p class="text-slate-500 mt-2">Stan na dzień: <?= date('d.m.Y', strtotime($selected_date)) ?></p>
        </header>

        <!-- Liczniki -->
        <section class="mb-12">
            <h3 class="text-2xl font-bold text-white mb-6">Liczniki</h3>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                <?php foreach ($counters as $counter): ?>
                <div class="counter-card p-6">
                    <div class="flex justify-between items-start mb-4">
                        <div>
                            <h4 class="text-lg font-semibold text-slate-200"><?= htmlspecialchars($counter['title']) ?></h4>
                            <p class="text-slate-400 text-sm"><?= htmlspecialchars($counter['category'] ?? 'Bez kategorii') ?></p>
                        </div>
                    </div>
                    <div class="text-center">
                        <div class="text-4xl font-bold text-green-400">
                            <?= $counter['total_value'] ?>
                            <?php if ($counter['type'] === 'currency' && $counter['symbol']): ?>
                                <span class="text-2xl text-slate-400 ml-1"><?= htmlspecialchars($counter['symbol']) ?></span>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
        </section>

        <!-- KPI -->
        <?php if (!empty($kpi_goals)): ?>
        <section>
            <h3 class="text-2xl font-bold text-white mb-6">Cele KPI (<?= $selected_date_obj->format('m.Y') ?>)</h3>
            <div class="overflow-x-auto bg-slate-800/70 border border-slate-700 rounded-lg">
                <table class="min-w-full text-sm text-left text-gray-300">
                    <thead class="text-xs text-gray-400 uppercase bg-gray-800">
                        <tr>
                            <th class="px-6 py-3">Cel</th>
                            <th class="px-6 py-3">Realizacja</th>
                            <th class="px-6 py-3">Cel miesięczny</th>
                            <th class="px-6 py-3 w-1/3">Postęp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($kpi_goals as $goal): ?>
                        <tr class="border-b border-slate-700 hover:bg-slate-800">
                            <td class="px-6 py-4 font-medium text-white"><?= htmlspecialchars($goal['name']) ?></td>
                            <td class="px-6 py-4 text-right font-mono"><?= $goal['monthly_total'] ?></td>
                            <td class="px-6 py-4 text-right font-mono"><?= $goal['total_goal'] ?></td>
                            <td class="px-6 py-4">
                                <div class="progress-bar h-4">
                                    <div class="progress-fill" style="width: <?= $goal['progress_percent'] ?>%"></div>
                                </div>
                                <div class="text-xs text-gray-400 mt-1"><?= round($goal['progress_percent']) ?>%</div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </section>
        <?php else: ?>
        <section>
            <h3 class="text-2xl font-bold text-white mb-6">Cele KPI</h3>
            <div class="bg-slate-800/70 border border-slate-700 rounded-lg p-8 text-center">
                <p class="text-slate-400">Brak zdefiniowanych celów KPI dla tej lokalizacji.</p>
            </div>
        </section>
        <?php endif; ?>

        <footer class="text-center text-slate-500 mt-12">
            <p>Dane odświeżane w czasie rzeczywistym</p>
        </footer>
    </div>

    <script>
        // Funkcja do wyświetlania powiadomień
        function showNotification(message, type = 'info') {
            const notification = document.createElement('div');
            notification.className = `fixed top-4 right-4 z-50 p-4 rounded-lg border max-w-md ${
                type === 'info' ? 'bg-blue-600/90 border-blue-500 text-white' : 
                type === 'warning' ? 'bg-yellow-600/90 border-yellow-500 text-white' : 
                'bg-gray-600/90 border-gray-500 text-white'
            }`;
            notification.innerHTML = `
                <div class="flex items-center">
                    <i class="fas fa-info-circle mr-2"></i>
                    <span>${message}</span>
                </div>
            `;
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.remove();
            }, 5000);
        }

        function updateActiveButton(period) {
            // Usuń aktywną klasę ze wszystkich przycisków
            document.querySelectorAll('.date-button').forEach(btn => {
                btn.classList.remove('active');
                if (btn.getAttribute('data-period') !== 'today') {
                    btn.classList.remove('today');
                }
            });
            
            // Dodaj aktywną klasę do wybranego przycisku
            const activeButton = document.querySelector(`[data-period="${period}"]`);
            if (activeButton) {
                activeButton.classList.add('active');
                if (period !== 'today') {
                    const todayButton = document.querySelector(`[data-period="today"]`);
                    if (todayButton) {
                        todayButton.classList.remove('today');
                    }
                }
            }
        }

        function generateUrl(dateParam, period) {
            // Pobierz SFID z URL
            let sfid;
            const urlParams = new URLSearchParams(window.location.search);
            
            if (urlParams.get('sfid')) {
                sfid = urlParams.get('sfid');
            } else {
                const pathParts = window.location.pathname.split('/');
                const wynikiIndex = pathParts.indexOf('wyniki');
                if (wynikiIndex !== -1 && pathParts[wynikiIndex + 1]) {
                    sfid = pathParts[wynikiIndex + 1];
                } else {
                    sfid = '<?= htmlspecialchars($sfid) ?>';
                }
            }
            
            // Generuj URL w zależności od formatu
            if (window.location.pathname.includes('/wyniki/')) {
                const baseUrl = window.location.pathname.split('?')[0];
                return `${baseUrl}?date=${dateParam}&period=${period}`;
            } else {
                return `?sfid=${sfid}&date=${dateParam}&period=${period}`;
            }
        }

        function changeDate(period) {
            const today = new Date();
            const currentYear = today.getFullYear();
            const currentMonth = today.getMonth(); // 0-11
            
            let dateParam, message = null;
            
            switch(period) {
                case 'yesterday':
                    const yesterday = new Date(today);
                    yesterday.setDate(yesterday.getDate() - 1);
                    dateParam = yesterday.toISOString().split('T')[0];
                    break;
                    
                case 'current_month':
                    dateParam = `${currentYear}-${String(currentMonth + 1).padStart(2, '0')}`;
                    message = `Wyświetlam dane dla bieżącego miesiąca (${new Date(currentYear, currentMonth).toLocaleDateString('pl-PL', {month: 'long', year: 'numeric'})}).`;
                    break;
                    
                case 'previous_month':
                    let prevMonth = currentMonth - 1;
                    let prevYear = currentYear;
                    if (prevMonth < 0) {
                        prevMonth = 11;
                        prevYear--;
                    }
                    dateParam = `${prevYear}-${String(prevMonth + 1).padStart(2, '0')}`;
                    message = `Wyświetlam dane dla poprzedniego miesiąca (${new Date(prevYear, prevMonth).toLocaleDateString('pl-PL', {month: 'long', year: 'numeric'})}).`;
                    break;
                    
                case 'today':
                default:
                    dateParam = today.toISOString().split('T')[0];
                    break;
            }
            
            if (message) {
                showNotification(message, 'info');
            }
            
            // Aktualizuj aktywny przycisk
            updateActiveButton(period);
            
            // Generuj i przekieruj na nowy URL
            const newUrl = generateUrl(dateParam, period);
            window.location.href = newUrl;
        }

        // Oznacz aktywny przycisk na podstawie parametru period lub daty
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const periodParam = urlParams.get('period');
            const currentDate = '<?= $selected_date ?>';
            const today = new Date().toISOString().split('T')[0];
            
            let activePeriod = null;
            
            if (periodParam) {
                activePeriod = periodParam;
            } else {
                // Dedukuj na podstawie formatu daty
                if (currentDate === today) {
                    activePeriod = 'today';
                } else if (currentDate.length === 7) { // Format YYYY-MM
                    const currentMonth = new Date().getMonth() + 1;
                    const currentYear = new Date().getFullYear();
                    const selectedMonth = parseInt(currentDate.split('-')[1]);
                    const selectedYear = parseInt(currentDate.split('-')[0]);
                    
                    if (selectedYear === currentYear && selectedMonth === currentMonth) {
                        activePeriod = 'current_month';
                    } else {
                        activePeriod = 'previous_month';
                    }
                } else {
                    const yesterday = new Date();
                    yesterday.setDate(yesterday.getDate() - 1);
                    if (currentDate === yesterday.toISOString().split('T')[0]) {
                        activePeriod = 'yesterday';
                    }
                }
            }
            
            if (activePeriod) {
                updateActiveButton(activePeriod);
            } else {
                const todayButton = document.querySelector(`[data-period="today"]`);
                if (todayButton) {
                    todayButton.classList.add('today');
                }
            }
        });
    </script>
</body>
</html>
