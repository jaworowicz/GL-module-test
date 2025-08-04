<?php
require_once '../../includes/auth.php';
require_once '../../includes/db.php';
require_once '../../includes/header-test.php';

// Sprawdź uprawnienia - używamy funkcji z auth.php
auth_require_login();

$current_user_id = $_SESSION['user_id'];
$current_sfid = $_SESSION['sfid_id'];
$is_admin = is_admin(); // Funkcja z auth.php
$is_superadmin = is_superadmin(); // Funkcja z auth.php

// Pobierz użytkowników z tej samej lokalizacji
$users_query = "SELECT id, name FROM users WHERE sfid_id = ? AND is_active = 1 ORDER BY name";
$users_stmt = $pdo->prepare($users_query);
$users_stmt->execute([$current_sfid]);
$users = $users_stmt->fetchAll(PDO::FETCH_ASSOC);

// Pobierz kategorie
$categories_query = "SELECT * FROM licznik_categories WHERE sfid_id = ? ORDER BY name";
$categories_stmt = $pdo->prepare($categories_query);
$categories_stmt->execute([$current_sfid]);
$categories = $categories_stmt->fetchAll(PDO::FETCH_ASSOC);

// Pobierz liczniki
$counters_query = "SELECT * FROM licznik_counters WHERE sfid_id = ? ORDER BY sort_order, id";
$counters_stmt = $pdo->prepare($counters_query);
$counters_stmt->execute([$current_sfid]);
$counters = $counters_stmt->fetchAll(PDO::FETCH_ASSOC);

// Pobierz cele KPI sortowane po ID
$kpi_query = "SELECT * FROM licznik_kpi_goals WHERE sfid_id = ? AND is_active = 1 ORDER BY id ASC";
$kpi_stmt = $pdo->prepare($kpi_query);
$kpi_stmt->execute([$current_sfid]);
$kpi_goals = $kpi_stmt->fetchAll(PDO::FETCH_ASSOC);

// Pobierz dni robocze dla bieżącego miesiąca
$today = date('Y-m-d');
$current_month = date('Y-m');
$current_year = date('Y');
$current_month_num = date('n');

// Funkcja do obliczania dni roboczych (pomijamy niedziele)
function calculateWorkingDays($year, $month) {
    $working_days = 0;
    $days_in_month = date('t', mktime(0, 0, 0, $month, 1, $year));

    for ($day = 1; $day <= $days_in_month; $day++) {
        $day_of_week = date('w', mktime(0, 0, 0, $month, $day, $year));
        if ($day_of_week != 0) { // 0 = niedziela
            $working_days++;
        }
    }

    return $working_days;
}

// Funkcja do obliczania pozostałych dni roboczych w miesiącu
function calculateRemainingWorkingDays($year, $month) {
    $today_day = date('j');
    $current_month_check = date('n');
    $current_year_check = date('Y');

    // Jeśli to nie jest bieżący miesiąc, zwróć wszystkie dni robocze
    if ($year != $current_year_check || $month != $current_month_check) {
        return calculateWorkingDays($year, $month);
    }

    $remaining_days = 0;
    $days_in_month = date('t', mktime(0, 0, 0, $month, 1, $year));

    for ($day = $today_day; $day <= $days_in_month; $day++) {
        $day_of_week = date('w', mktime(0, 0, 0, $month, $day, $year));
        if ($day_of_week != 0) { // 0 = niedziela
            $remaining_days++;
        }
    }

    return $remaining_days;
}

// Pobierz dni robocze z tabeli global_working_hours lub oblicz automatycznie
$working_days_query = "SELECT working_days FROM global_working_hours WHERE sfid_id = ? AND year = ? AND month = ?";
$working_days_stmt = $pdo->prepare($working_days_query);
$working_days_stmt->execute([$current_sfid, $current_year, $current_month_num]);
$working_days_data = $working_days_stmt->fetch(PDO::FETCH_ASSOC);

$total_working_days = $working_days_data['working_days'] ?? calculateWorkingDays($current_year, $current_month_num);
$remaining_working_days = calculateRemainingWorkingDays($current_year, $current_month_num);
?>

<!-- Font Awesome CDN for icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" integrity="sha512-DTOQO9RWCH3ppGqcWaEA1BIZOC6xxalwEsw9c2QQeAIftl+Vegovlnee1c9QX4TctnWMn13TZye+giMm8e2LwA==" crossorigin="anonymous" referrerpolicy="no-referrer" />
<!-- SortableJS for Drag and Drop -->
<script src="https://cdn.jsdelivr.net/npm/sortablejs@latest/Sortable.min.js"></script>
<link rel="stylesheet" href="style.css" data-precedence="next"/>
<style>
/* Style wzorowany na pomidor_report.php */
.counter-card {
    background: rgba(30, 41, 59, 0.7);
    border: 1px solid rgb(51, 65, 85);
    border-radius: 1rem;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}

.counter-card:hover {
    background: rgba(30, 41, 59, 0.9);
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
}

.counter-card.selected {
    border-color: rgb(34, 197, 94);
    box-shadow: 0 0 0 2px rgba(34, 197, 94, 0.3);
}

.counter-value {
    font-family: 'Inter', monospace;
    font-size: 2.5rem;
    font-weight: 700;
    color: white;
    text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.counter-title {
    color: rgb(203, 213, 225);
    font-weight: 600;
    font-size: 1.1rem;
}

.counter-category {
    color: rgb(148, 163, 184);
    font-size: 0.875rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}

.counter-controls {
    display: flex;
    gap: 0.5rem;
    margin-top: 1rem;
}

.counter-btn {
    flex: 1;
    padding: 0.75rem;
    border: 1px solid rgb(75, 85, 99);
    background: rgba(55, 65, 81, 0.8);
    color: white;
    border-radius: 0.5rem;
    font-weight: 600;
    transition: all 0.2s ease;
    cursor: pointer;
}

.counter-btn:hover {
    background: rgba(75, 85, 99, 0.9);
    border-color: rgb(107, 114, 128);
}

.counter-btn.minus:hover {
    background: rgba(239, 68, 68, 0.2);
    border-color: rgb(239, 68, 68);
    color: rgb(248, 113, 113);
}

.counter-btn.plus:hover {
    background: rgba(34, 197, 94, 0.2);
    border-color: rgb(34, 197, 94);
    color: rgb(74, 222, 128);
}

.daily-goal {
    font-size: 0.75rem;
    color: rgb(156, 163, 175);
    margin-top: 0.25rem;
    text-align: center;
}

.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.7);
    z-index: 9998;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1rem;
}

.modal-content {
    background: rgb(30, 41, 59);
    border: 1px solid rgb(51, 65, 85);
    border-radius: 1rem;
    box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
    width: 100%;
    max-width: 32rem;
    max-height: 90vh;
    overflow-y: auto;
}

.modal-lg {
    max-width: 48rem;
}

.custom-input {
    background: rgba(55, 65, 81, 0.5);
    border: 1px solid rgb(75, 85, 99);
    border-radius: 0.5rem;
    padding: 0.5rem 0.75rem;
    color: white;
}

.custom-input:focus {
    outline: none;
    border-color: rgb(34, 197, 94);
    box-shadow: 0 0 0 2px rgba(34, 197, 94, 0.3);
}

.category-menu {
    position: absolute;
    background: rgb(30, 41, 59);
    border: 1px solid rgb(51, 65, 85);
    border-radius: 0.5rem;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
    z-index: 1000;
    min-width: 200px;
    display: none;
}

.category-menu.show {
    display: block;
}

.category-menu-item {
    padding: 0.75rem 1rem;
    cursor: pointer;
    color: rgb(203, 213, 225);
    border-bottom: 1px solid rgb(51, 65, 85);
    transition: background-color 0.2s ease;
}

.category-menu-item:hover {
    background: rgba(55, 65, 81, 0.5);
}

.category-menu-item:last-child {
    border-bottom: none;
}

.key-legend {
    font-family: 'Inter', monospace;
}

.key-legend span {
    background: rgba(55, 65, 81, 0.8);
    padding: 0.125rem 0.375rem;
    border-radius: 0.25rem;
    margin-right: 0.25rem;
    font-weight: 600;
}

.counters-container.grid-view {
    display: block;
}

.counters-container.list-view {
    display: none;
}

.progress-bar {
    width: 100%;
    height: 0.5rem;
    background: rgba(55, 65, 81, 0.5);
    border-radius: 0.25rem;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    background: linear-gradient(90deg, rgb(34, 197, 94), rgb(16, 185, 129));
    transition: width 0.3s ease;
}
</style>

<div class="container mx-auto px-4 py-8">

    <!-- Header -->
    <header class="mb-6">
        <div class="flex flex-wrap justify-between items-center gap-4 mb-4">
            <!-- Left side: Category and admin buttons -->
            <div class="flex flex-wrap items-center gap-2">
                <div class="relative" id="category-dropdown-container">
                    <button onclick="toggleCategoryMenu()" class="bg-green-600 hover:bg-green-500 text-white font-bold py-2 px-4 rounded-lg flex items-center">
                        <span id="current-category-name">Wszystkie Kategorie</span>
                        <i class="fas fa-chevron-down ml-2 text-xs"></i>
                    </button>
                    <div id="category-menu" class="category-menu rounded-md shadow-lg py-1 mt-2 left-0">
                        <!-- Categories will be populated by JS -->
                    </div>
                </div>
                <?php if ($is_admin): ?>
                <button onclick="openAddCounterModal()" class="bg-blue-600 hover:bg-blue-500 text-white font-bold py-2 px-4 rounded-lg">Dodaj Licznik</button>
                <?php endif; ?>
                <button onclick="openPublicView()" class="bg-indigo-600 hover:bg-indigo-500 text-white font-bold py-2 px-4 rounded-lg">Widok Publiczny</button>
            </div>

            <!-- Right side: User, Date, and View controls -->
            <div class="flex flex-wrap items-center gap-2">
                <select id="user-selector" class="custom-input text-sm">
                    <?php foreach ($users as $user): ?>
                    <option value="<?php echo $user['id']; ?>" <?php echo ($user['id'] == $current_user_id) ? 'selected' : ''; ?>>
                        <?php echo htmlspecialchars($user['name']); ?>
                    </option>
                    <?php endforeach; ?>
                </select>
                <input type="date" id="date-selector" class="custom-input text-sm" value="<?php echo $today; ?>">
                <div class="flex items-center space-x-2 bg-gray-700 border border-gray-600 rounded-lg p-1">
                    <button id="grid-view-btn" class="px-3 py-1 rounded-md text-sm bg-gray-500 text-white" onclick="changeView('grid')" title="Widok siatki (V)"><i class="fas fa-th-large"></i></button>
                    <button id="list-view-btn" class="px-3 py-1 rounded-md text-sm text-gray-300 hover:bg-gray-600" onclick="changeView('list')" title="Widok listy (V)"><i class="fas fa-bars"></i></button>
                </div>
            </div>
        </div>

        <!-- Keyboard Legend -->
        <div class="key-legend flex flex-wrap gap-x-4 gap-y-2 text-xs text-gray-400">
            <div><span>↑↓</span>Nawigacja</div>
            <div><span>←→ / + / -</span>Zmień wartość</div>
            <div><span>U</span>Ustawienia</div>
            <div><span>D</span>Usuń</div>
            <div><span>V</span>Zmień widok</div>
            <div><span>K</span>Zmień kategorię</div>
            <div><span>I</span>Dodaj ilość</div>
            <div><span>ESC</span>Zamknij okno</div>
        </div>
    </header>

    <!-- Main container for the counters -->
    <main>
        <div id="counters-container" class="grid-view">
            <!-- Grid View -->
            <div id="counters-grid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                <!-- Counters will be rendered here via JavaScript -->
            </div>

            <!-- List View (hidden by default) -->
            <div id="counters-list" class="hidden space-y-2">
                <!-- List view will be rendered here via JavaScript -->
            </div>
        </div>

        <!-- Large Tile View Container (hidden by default) -->
        <div id="large-tile-view" class="hidden">
            <button class="mb-4 bg-gray-600 hover:bg-gray-500 text-white font-bold py-2 px-4 rounded" onclick="goBackToGridView()">
                <i class="fas fa-arrow-left mr-2"></i> Wróć
            </button>
            <div id="large-tile-content"></div>
        </div>

        <!-- KPI Goals Section -->
        <section id="kpi-section" class="mt-12">
            <div class="flex flex-wrap justify-between items-center gap-4 mb-4">
                <h2 class="text-2xl font-bold text-white">Cele Zespołowe (KPI)</h2>
                <div class="flex items-center gap-2">
                    <input type="month" id="kpi-month-selector" class="custom-input text-sm" value="<?php echo $current_month; ?>">
                    <button onclick="openQuickReportModal()" class="bg-purple-600 hover:bg-purple-500 text-white font-bold py-2 px-4 rounded-lg flex items-center">
                        <i class="fas fa-file-alt mr-2"></i> Raport KPI
                    </button>
                    <?php if ($is_admin): ?>
                    <button onclick="openMassCorrectionModal()" class="bg-indigo-600 hover:bg-indigo-500 text-white font-bold py-2 px-4 rounded-lg flex items-center">
                        <i class="fas fa-database mr-2"></i> Korekta Masowa
                    </button>
                    <button onclick="openAddKpiModal()" class="bg-green-600 hover:bg-green-500 text-white font-bold py-2 px-4 rounded-lg flex items-center">
                        <i class="fas fa-plus mr-2"></i> Dodaj Cel
                    </button>
                    <?php endif; ?>
                </div>
            </div>
            <div class="overflow-x-auto bg-slate-800/70 border border-slate-700 rounded-lg">
                <table class="min-w-full text-sm text-left text-gray-300">
                    <thead class="text-xs text-gray-400 uppercase bg-gray-800">
                        <tr>
                            <th scope="col" class="px-6 py-3">Cel</th>
                            <th scope="col" class="px-6 py-3">Realizacja (miesiąc)</th>
                            <th scope="col" class="px-6 py-3">Cel Dzienny (auto)</th>
                            <th scope="col" class="px-6 py-3">Cel Miesięczny</th>
                            <th scope="col" class="px-6 py-3 w-1/3">Postęp</th>
                            <th scope="col" class="px-6 py-3">Akcje</th>
                        </tr>
                    </thead>
                    <tbody id="kpi-table-body">
                        <!-- KPI Goals will be rendered here -->
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <!-- Settings Modal -->
    <div id="settings-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <h2 class="text-2xl font-bold mb-6 text-white p-6 border-b border-slate-700">Ustawienia licznika</h2>
            <input type="hidden" id="edit-counter-id">

            <div class="p-6 space-y-4">
                <div>
                    <label for="edit-counter-name" class="block text-sm font-medium text-gray-300 mb-1">Nazwa licznika</label>
                    <input type="text" id="edit-counter-name" class="w-full custom-input">
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label for="edit-counter-increment" class="block text-sm font-medium text-gray-300 mb-1">Krok zmiany</label>
                        <input type="number" id="edit-counter-increment" class="w-full custom-input" placeholder="1">
                    </div>
                    <div>
                        <label for="edit-counter-category" class="block text-sm font-medium text-gray-300 mb-1">Kategoria</label>
                        <select id="edit-counter-category" class="w-full custom-input">
                            <!-- Category options populated by JS -->
                        </select>
                    </div>
                </div>

                <div>
                    <label for="edit-counter-color" class="block text-sm font-medium text-gray-300 mb-1">Kolor karty</label>
                    <input type="color" id="edit-counter-color" class="w-full h-10 p-1 custom-input cursor-pointer">
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="flex items-center space-x-2">
                            <input type="checkbox" id="edit-counter-is-currency" class="rounded border-gray-600 bg-gray-700 text-green-600">
                            <span class="text-sm font-medium text-gray-300">Licznik walutowy</span>
                        </label>
                    </div>
                    <div>
                        <label for="edit-counter-symbol" class="block text-sm font-medium text-gray-300 mb-1">Symbol</label>
                        <input type="text" id="edit-counter-symbol" class="w-full custom-input" placeholder="zł, €, $">
                    </div>
                </div>
            </div>

            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="saveCounterSettings()" class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-500">Zapisz ustawienia</button>
            </div>
        </div>
    </div>

    <!-- Add Counter Modal -->
    <div id="add-counter-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <h2 class="text-2xl font-bold mb-4 text-white p-6 border-b border-slate-700">Dodaj nowy licznik</h2>

            <div class="p-6 space-y-4">
                <div>
                    <label for="new-counter-name" class="block text-sm font-medium text-gray-300 mb-1">Nazwa licznika</label>
                    <input type="text" id="new-counter-name" class="w-full custom-input" placeholder="np. Nowe umowy">
                </div>
                <div>
                    <label for="new-counter-increment" class="block text-sm font-medium text-gray-300 mb-1">Krok zmiany</label>
                    <input type="number" id="new-counter-increment" class="w-full custom-input" placeholder="1" value="1">
                </div>
                <div>
                    <label for="new-counter-category" class="block text-sm font-medium text-gray-300 mb-1">Kategoria</label>
                    <select id="new-counter-category" class="w-full custom-input">
                        <!-- Category options populated by JS -->
                    </select>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="flex items-center space-x-2">
                            <input type="checkbox" id="new-counter-is-currency" class="rounded border-gray-600 bg-gray-700 text-green-600">
                            <span class="text-sm font-medium text-gray-300">Licznik walutowy</span>
                        </label>
                    </div>
                    <div>
                        <label for="new-counter-symbol" class="block text-sm font-medium text-gray-300 mb-1">Symbol</label>
                        <input type="text" id="new-counter-symbol" class="w-full custom-input" placeholder="zł, €, $">
                    </div>
                </div>
            </div>

            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="addNewCounter()" class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-500">Dodaj licznik</button>
            </div>
        </div>
    </div>

    <!-- Add Category Modal -->
    <div id="add-category-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <h2 class="text-2xl font-bold mb-4 text-white p-6 border-b border-slate-700">Dodaj nową kategorię</h2>

            <div class="p-6 space-y-4">
                <div>
                    <label for="new-category-name" class="block text-sm font-medium text-gray-300 mb-1">Nazwa kategorii</label>
                    <input type="text" id="new-category-name" class="w-full custom-input" placeholder="np. Sprzedaż">
                </div>
            </div>

            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="addNewCategory()" class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-500">Dodaj kategorię</button>
            </div>
        </div>
    </div>

    <!-- Add/Edit KPI Goal Modal -->
    <div id="kpi-goal-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <h2 id="kpi-modal-title" class="text-2xl font-bold mb-6 text-white p-6 border-b border-slate-700">Dodaj Cel Zespołowy</h2>
            <input type="hidden" id="kpi-goal-id">

            <div class="p-6 space-y-4">
                <div>
                    <label for="kpi-goal-name" class="block text-sm font-medium text-gray-300 mb-1">Nazwa celu</label>
                    <input type="text" id="kpi-goal-name" class="w-full custom-input" placeholder="Np. Pozyskanie Miesięczne">
                </div>
                <div>
                    <label for="kpi-total-goal" class="block text-sm font-medium text-gray-300 mb-1">Cel Miesięczny (TOTAL)</label>
                    <input type="number" id="kpi-total-goal" class="w-full custom-input" placeholder="0">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-300 mb-1">Powiązane liczniki</label>
                    <div id="kpi-linked-counters" class="max-h-40 overflow-y-auto bg-slate-700/50 p-2 rounded-md border border-slate-600 space-y-2">
                        <!-- Checkboxes will be rendered here -->
                    </div>
                </div>
            </div>

            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="saveKpiGoal()" class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-500">Zapisz Cel</button>
            </div>
        </div>
    </div>

    <!-- KPI Details Modal -->
    <div id="kpi-details-modal" class="modal-overlay hidden">
        <div class="modal-content modal-lg">
            <h2 id="kpi-details-title" class="text-2xl font-bold mb-6 text-white p-6 border-b border-slate-700">Szczegóły KPI</h2>

            <div class="p-6">
                <div id="kpi-weekly-breakdown" class="overflow-x-auto">
                    <!-- Weekly breakdown will be rendered here -->
                </div>
            </div>

            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Zamknij</button>
                <?php if ($is_admin): ?>
                <button onclick="openKpiCorrectionModal()" class="px-4 py-2 bg-orange-600 text-white rounded-md hover:bg-orange-500">Dodaj Korektę</button>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- KPI Manual Correction Modal -->
    <div id="kpi-correction-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <h2 class="text-2xl font-bold mb-6 text-white p-6 border-b border-slate-700">Korekta Ręczna KPI</h2>

            <div class="p-6 space-y-4">
                <div>
                    <label for="correction-date" class="block text-sm font-medium text-gray-300 mb-1">Data korekty</label>
                    <input type="date" id="correction-date" class="w-full custom-input" value="<?php echo $today; ?>">
                </div>
                <div>
                    <label for="correction-value" class="block text-sm font-medium text-gray-300 mb-1">Wartość korekty</label>
                    <input type="number" id="correction-value" class="w-full custom-input" placeholder="0">
                </div>
                <div>
                    <label for="correction-description" class="block text-sm font-medium text-gray-300 mb-1">Opis korekty</label>
                    <textarea id="correction-description" class="w-full custom-input" rows="3" placeholder="Opcjonalny opis korekty"></textarea>
                </div>
            </div>

            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="saveKpiCorrection()" class="px-4 py-2 bg-orange-600 text-white rounded-md hover:bg-orange-500">Dodaj Korektę</button>
            </div>
        </div>
    </div>

    <!-- Mass Correction Modal -->
    <div id="mass-correction-modal" class="modal-overlay hidden">
        <div class="modal-content modal-lg">
            <h2 class="text-2xl font-bold mb-4 text-white p-6 border-b border-slate-700">Korekta Masowa</h2>
            <div class="p-6">
                <p class="text-sm text-gray-400 mb-4">Wprowadź wartości dla każdego użytkownika, które zostaną dodane do ich dzisiejszych wyników.</p>
                <div id="mass-correction-body" class="max-h-96 overflow-y-auto">
                    <!-- Mass correction table will be rendered here -->
                </div>
            </div>
            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="saveMassCorrection()" class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-500">Zapisz Korekty</button>
            </div>
        </div>
    </div>

    <!-- Add Amount Modal -->
    <div id="add-amount-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <h2 id="add-amount-title" class="text-xl font-bold mb-4 text-white p-6 border-b border-slate-700">Dodaj ilość</h2>
            <input type="hidden" id="add-amount-counter-id">
            <div class="p-6 space-y-4">
                <div>
                    <label for="add-amount-value" class="block text-sm font-medium text-gray-300 mb-1">Ilość do dodania</label>
                    <input type="number" id="add-amount-value" class="w-full custom-input" placeholder="0">
                </div>
            </div>
            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="saveAddAmount()" class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-500">Dodaj</button>
            </div>
        </div>
    </div>

    <!-- Set Value Modal -->
    <div id="set-value-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <h2 id="set-value-title" class="text-xl font-bold mb-4 text-white p-6 border-b border-slate-700">Ustaw wartość</h2>
            <input type="hidden" id="set-value-counter-id">
            <div class="p-6 space-y-4">
                <div>
                    <label for="set-value-input" class="block text-sm font-medium text-gray-300 mb-1">Nowa wartość</label>
                    <input type="number" id="set-value-input" class="w-full custom-input" placeholder="0">
                </div>
            </div>
            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="saveSetValue()" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-500">Ustaw</button>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div id="delete-confirm-modal" class="modal-overlay hidden">
        <div class="modal-content">
            <h2 class="text-xl font-bold mb-4 text-white p-6 border-b border-slate-700">Potwierdź usunięcie</h2>
            <p class="text-gray-300 mb-6 px-6">Czy na pewno chcesz trwale usunąć ten licznik?</p>
            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Anuluj</button>
                <button onclick="confirmDeletion()" class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-500">Tak, usuń</button>
            </div>
        </div>
    </div>

    <!-- Quick Report Modal -->
    <div id="quick-report-modal" class="modal-overlay hidden">
        <div class="modal-content modal-lg">
            <h2 class="text-2xl font-bold mb-6 text-white p-6 border-b border-slate-700">Szybki Raport KPI</h2>
            
            <div class="p-6">
                <div class="mb-4">
                    <label for="report-template" class="block text-sm font-medium text-gray-300 mb-2">Szablon raportu</label>
                    <select id="report-template" class="w-full custom-input">
                        <option value="default">Default Report</option>
                    </select>
                </div>
                
                <div class="mb-4">
                    <label for="report-date" class="block text-sm font-medium text-gray-300 mb-2">Data raportu</label>
                    <input type="date" id="report-date" class="w-full custom-input" value="<?php echo date('Y-m-d'); ?>">
                </div>
                
                <div class="bg-slate-800/50 border border-slate-600 rounded-lg p-4 max-h-96 overflow-y-auto">
                    <div id="report-preview">
                        <p class="text-gray-400">Wybierz szablon aby zobaczyć podgląd...</p>
                    </div>
                </div>
            </div>

            <div class="flex justify-end space-x-3 p-6 border-t border-slate-700">
                <button onclick="closeAllModals()" class="px-4 py-2 bg-gray-600 rounded-md hover:bg-gray-500 text-white">Zamknij</button>
                <button onclick="generateReport()" class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-500">Generuj Raport</button>
                <button onclick="downloadReport()" class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-500">Pobierz HTML</button>
            </div>
        </div>
    </div>

</div>

<!-- Przekaż dane PHP do JavaScript -->
<script>
    window.appData = {
        currentUserId: <?php echo $current_user_id; ?>,
        currentSfid: <?php echo $current_sfid; ?>,
        isAdmin: <?php echo $is_admin ? 'true' : 'false'; ?>,
        isSuperadmin: <?php echo $is_superadmin ? 'true' : 'false'; ?>,
        users: <?php echo json_encode($users); ?>,
        categories: <?php echo json_encode($categories); ?>,
        counters: <?php echo json_encode($counters); ?>,
        kpiGoals: <?php echo json_encode($kpi_goals); ?>,
        today: '<?php echo $today; ?>',
        currentMonth: '<?php echo $current_month; ?>',
        totalWorkingDays: <?php echo $total_working_days; ?>,
        remainingWorkingDays: <?php echo $remaining_working_days; ?>
    };
</script>

<script src="script.js"></script>
<script src="reports/report_scripts.js"></script>

<?php require_once '../../includes/footer-new.php'; ?>