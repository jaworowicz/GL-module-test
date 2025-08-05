
<?php
// Plik: /modules/to-do/index.php
// Główny moduł To-Do Kanban Board

require_once __DIR__.'/../../includes/auth.php';
require_once __DIR__.'/../../includes/db.php';

// Sprawdź autoryzację
if (!is_logged_in()) {
    header('Location: /modules/auth/login.php?error=login_required');
    exit;
}

$current_user = get_current_user();
$user_id = $current_user['id'];
$user_role = $current_user['role'];
$sfid = $_SESSION['sfid'] ?? null;

?>
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>To-Do Kanban Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <header class="header">
            <h1><i class="fas fa-tasks"></i> To-Do Kanban Board</h1>
            <div class="controls">
                <select id="locationFilter" class="custom-select">
                    <option value="all">Wszystkie lokalizacje</option>
                    <option value="20004014">BAZA 20004014</option>
                    <option value="20004015">BAZA 20004015</option>
                </select>
                <select id="userFilter" class="custom-select">
                    <option value="all">Wszyscy użytkownicy</option>
                    <!-- Użytkownicy będą ładowani dynamicznie -->
                </select>
                <button class="btn btn-primary" onclick="openTaskModal()">
                    <i class="fas fa-plus"></i> Dodaj zadanie
                </button>
            </div>
        </header>

        <div class="kanban-board">
            <div class="kanban-column" data-status="new">
                <div class="column-header">
                    <div class="column-title">
                        <i class="fas fa-inbox"></i>
                        Nowe
                        <span class="task-count" id="new-count">0</span>
                    </div>
                </div>
                <div class="drop-zone" id="new-tasks"></div>
            </div>

            <div class="kanban-column" data-status="in-progress">
                <div class="column-header">
                    <div class="column-title">
                        <i class="fas fa-play"></i>
                        W toku
                        <span class="task-count" id="in-progress-count">0</span>
                    </div>
                </div>
                <div class="drop-zone" id="in-progress-tasks"></div>
            </div>

            <div class="kanban-column" data-status="returned">
                <div class="column-header">
                    <div class="column-title">
                        <i class="fas fa-undo"></i>
                        Zwrócone
                        <span class="task-count" id="returned-count">0</span>
                    </div>
                </div>
                <div class="drop-zone" id="returned-tasks"></div>
            </div>

            <div class="kanban-column" data-status="completed">
                <div class="column-header">
                    <div class="column-title">
                        <i class="fas fa-check"></i>
                        Zakończone
                        <span class="task-count" id="completed-count">0</span>
                    </div>
                </div>
                <div class="drop-zone" id="completed-tasks"></div>
            </div>
        </div>
    </div>

    <!-- Widget responsywny -->
    <div class="widget-container">
        <h3 class="widget-title">
            <i class="fas fa-list-check"></i> 
            Moje zadania do wykonania
        </h3>
        <div class="widget-tasks" id="widget-tasks"></div>
    </div>

    <!-- Modal dodawania/edycji zadania -->
    <div id="taskModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title" id="modalTitle">Dodaj nowe zadanie</h2>
                <button type="button" class="close-btn" onclick="closeTaskModal()">&times;</button>
            </div>
            <form id="taskForm">
                <div class="form-group">
                    <label class="form-label">Tytuł zadania *</label>
                    <input type="text" id="taskTitle" class="form-input" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Opis</label>
                    <textarea id="taskDescription" class="form-textarea"></textarea>
                </div>
                <div class="form-group">
                    <label class="form-label">Typ przypisania *</label>
                    <select id="taskAssignmentType" class="form-select" required onchange="toggleUserSelect()">
                        <option value="">Wybierz typ</option>
                        <option value="global">Globalne (dla wszystkich w lokalizacji)</option>
                        <option value="user">Dla konkretnego użytkownika</option>
                        <option value="self">Tylko dla siebie</option>
                    </select>
                </div>
                <div class="form-group" id="userSelectGroup" style="display: none;">
                    <label class="form-label">Użytkownik</label>
                    <select id="taskAssignedUser" class="form-select">
                        <!-- Opcje będą ładowane dynamicznie -->
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Lokalizacja</label>
                    <select id="taskLocation" class="form-select">
                        <option value="20004014">BAZA 20004014</option>
                        <option value="20004015">BAZA 20004015</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Priorytet</label>
                    <select id="taskPriority" class="form-select">
                        <option value="low">Niski</option>
                        <option value="medium">Średni</option>
                        <option value="high">Wysoki</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select id="taskStatus" class="form-select">
                        <option value="new">Nowe</option>
                        <option value="in-progress">W toku</option>
                        <option value="returned">Zwrócone</option>
                        <option value="completed">Zakończone</option>
                    </select>
                </div>
                <div class="form-group">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-save"></i> Zapisz zadanie
                    </button>
                    <button type="button" class="btn btn-secondary" onclick="closeTaskModal()">
                        <i class="fas fa-times"></i> Anuluj
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal potwierdzenia -->
    <div id="confirmModal" class="confirm-modal">
        <div class="confirm-modal-content">
            <h3 class="confirm-modal-title">
                <i class="fas fa-exclamation-triangle"></i>
                Potwierdź działanie
            </h3>
            <p class="confirm-modal-text" id="confirmModalText"></p>
            <div class="confirm-modal-actions">
                <button type="button" class="btn btn-danger" id="confirmModalOk">
                    <i class="fas fa-check"></i> Tak
                </button>
                <button type="button" class="btn btn-secondary" onclick="closeConfirmModal()">
                    <i class="fas fa-times"></i> Nie
                </button>
            </div>
        </div>
    </div>

    <script>
        // Konfiguracja aplikacji
        window.appData = {
            currentUser: {
                id: <?php echo $user_id; ?>,
                role: '<?php echo $user_role; ?>',
                sfid: '<?php echo $sfid; ?>'
            },
            isAdmin: <?php echo ($user_role === 'admin' || $user_role === 'superadmin') ? 'true' : 'false'; ?>
        };
    </script>
    <script src="script.js"></script>
</body>
</html>
