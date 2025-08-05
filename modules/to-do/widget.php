
<?php
// Plik: /modules/to-do/widget.php
// Widget responsywny dla modułu To-Do

require_once __DIR__.'/../../includes/db.php';

// Sprawdź czy użytkownik jest zalogowany
if (!isset($_SESSION['user_id'])) {
    echo '<div class="todo-widget-error">Musisz być zalogowany</div>';
    return;
}

$user_id = $_SESSION['user_id'];

try {
    // Pobierz zadania dla aktualnego użytkownika
    $query = "
        SELECT t.*, CONCAT(e.first_name, ' ', e.last_name) as assigned_user_name
        FROM todo_tasks t
        LEFT JOIN employees e ON t.assigned_user = e.id
        WHERE t.deleted_at IS NULL 
        AND t.status_id != 4
        AND (
            t.assignment_type = 'global' 
            OR (t.assignment_type = 'user' AND t.assigned_user = ?)
            OR (t.assignment_type = 'self' AND t.assigned_user = ?)
        )
        ORDER BY 
            CASE 
                WHEN t.due_date IS NOT NULL AND t.due_date <= CURDATE() THEN 1
                WHEN t.due_date IS NOT NULL AND t.due_date <= DATE_ADD(CURDATE(), INTERVAL 1 DAY) THEN 2
                ELSE 3
            END,
            t.created_at DESC
        LIMIT 10
    ";
    $stmt = $pdo->prepare($query);
    $stmt->execute([$user_id, $user_id]);
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
} catch (Exception $e) {
    error_log('Todo Widget Error: ' . $e->getMessage());
    $tasks = [];
}

// Funkcja pomocnicza do formatowania dat
function formatDueDateWidget($dateString) {
    if (!$dateString) return '';
    $date = new DateTime($dateString);
    $today = new DateTime();
    $today->setTime(0, 0, 0);
    $date->setTime(0, 0, 0);
    
    $diff = $today->diff($date);
    $diffDays = (int)$diff->format('%r%a');
    
    if ($diffDays < 0) {
        return 'Przeterminowane (' . abs($diffDays) . ' dni)';
    } else if ($diffDays === 0) {
        return 'Dziś ostatni dzień!';
    } else if ($diffDays === 1) {
        return 'Jutro';
    } else {
        return 'Za ' . $diffDays . ' dni';
    }
}

function getDueDateClassWidget($dateString) {
    if (!$dateString) return '';
    $date = new DateTime($dateString);
    $today = new DateTime();
    $today->setTime(0, 0, 0);
    $date->setTime(0, 0, 0);
    
    $diff = $today->diff($date);
    $diffDays = (int)$diff->format('%r%a');
    
    if ($diffDays < 0) {
        return 'due-overdue';
    } else if ($diffDays === 0) {
        return 'due-today';
    }
    return '';
}
?>

<style>
.todo-widget {
    background: rgba(30, 41, 59, 0.8);
    border: 1px solid rgb(51, 65, 85);
    border-radius: 12px;
    padding: 16px;
    backdrop-filter: blur(10px);
    height: 100%;
    display: flex;
    flex-direction: column;
}

.todo-widget-title {
    color: #34d399;
    margin-bottom: 12px;
    font-size: 1rem;
    font-weight: bold;
    display: flex;
    align-items: center;
    gap: 8px;
}

.todo-widget-tasks {
    flex: 1;
    overflow-y: auto;
    max-height: 200px;
}

.todo-widget-task {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 8px;
    margin-bottom: 6px;
    background: rgba(51, 65, 85, 0.6);
    border-radius: 6px;
    border: 1px solid rgba(75, 85, 99, 0.5);
    transition: all 0.2s ease;
    font-size: 0.8rem;
}

.todo-widget-task:hover {
    background: rgba(51, 65, 85, 0.8);
    transform: translateX(2px);
}

.todo-widget-task.due-today {
    border-left: 3px solid #f59e0b;
    background: rgba(245, 158, 11, 0.1);
}

.todo-widget-task.due-overdue {
    border-left: 3px solid #ef4444;
    background: rgba(239, 68, 68, 0.1);
}

/* Custom Checkbox pro widget */
.todo-widget-checkbox {
    position: relative;
    display: inline-block;
    width: 16px;
    height: 16px;
    cursor: pointer;
    margin-top: 2px;
    flex-shrink: 0;
}

.todo-widget-checkbox input {
    opacity: 0;
    position: absolute;
    width: 100%;
    height: 100%;
    margin: 0;
    cursor: pointer;
}

.todo-widget-checkmark {
    position: absolute;
    top: 0;
    left: 0;
    width: 16px;
    height: 16px;
    background: rgba(55, 65, 81, 0.8);
    border: 2px solid #4b5563;
    border-radius: 3px;
    transition: all 0.3s ease;
    display: flex;
    align-items: center;
    justify-content: center;
}

.todo-widget-checkbox input:checked + .todo-widget-checkmark {
    background: #34d399;
    border-color: #34d399;
    transform: scale(1.1);
}

.todo-widget-checkmark::after {
    content: '';
    position: absolute;
    display: none;
    width: 4px;
    height: 8px;
    border: solid white;
    border-width: 0 1.5px 1.5px 0;
    transform: rotate(45deg);
}

.todo-widget-checkbox input:checked + .todo-widget-checkmark::after {
    display: block;
}

.todo-widget-task-content {
    flex: 1;
    min-width: 0;
}

.todo-widget-task-title {
    color: #f8fafc;
    font-weight: 500;
    margin-bottom: 2px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.todo-widget-task-desc {
    color: #cbd5e1;
    font-size: 0.7rem;
    line-height: 1.2;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    margin-bottom: 2px;
}

.todo-widget-task-due {
    color: #94a3b8;
    font-size: 0.65rem;
    font-weight: 500;
}

.todo-widget-task-due.due-today {
    color: #f59e0b;
    font-weight: bold;
}

.todo-widget-task-due.due-overdue {
    color: #ef4444;
    font-weight: bold;
}

.todo-widget-priority {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    margin-top: 4px;
    flex-shrink: 0;
}

.priority-high { background: #ef4444; }
.priority-medium { background: #f59e0b; }
.priority-low { background: #10b981; }

.todo-widget-empty {
    color: #94a3b8;
    text-align: center;
    padding: 20px;
    font-size: 0.8rem;
    font-style: italic;
}

.todo-widget-footer {
    margin-top: 10px;
    padding-top: 8px;
    border-top: 1px solid rgba(75, 85, 99, 0.5);
}

.todo-widget-link {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    color: #60a5fa;
    text-decoration: none;
    font-size: 0.75rem;
    transition: color 0.2s ease;
}

.todo-widget-link:hover {
    color: #93c5fd;
}

.todo-widget-error {
    color: #ef4444;
    text-align: center;
    padding: 20px;
    font-size: 0.8rem;
}

@media (max-width: 768px) {
    .todo-widget {
        padding: 12px;
    }
    
    .todo-widget-task {
        padding: 6px;
        font-size: 0.75rem;
    }
    
    .todo-widget-task-desc {
        font-size: 0.65rem;
    }
}
</style>

<div class="todo-widget">
    <h3 class="todo-widget-title">
        <i class="fas fa-list-check"></i> 
        Moje zadania
    </h3>
    
    <div class="todo-widget-tasks">
        <?php if (empty($tasks)): ?>
            <div class="todo-widget-empty">
                Brak zadań do wykonania
            </div>
        <?php else: ?>
            <?php foreach ($tasks as $task): ?>
                <?php 
                    $dueDateClass = getDueDateClassWidget($task['due_date']);
                    $taskClasses = 'todo-widget-task';
                    if ($dueDateClass) {
                        $taskClasses .= ' ' . $dueDateClass;
                    }
                ?>
                <div class="<?php echo $taskClasses; ?>">
                    <label class="todo-widget-checkbox">
                        <input type="checkbox" 
                               onchange="completeTaskFromWidget(<?php echo $task['id']; ?>, this.checked)">
                        <span class="todo-widget-checkmark"></span>
                    </label>
                    
                    <div class="todo-widget-task-content">
                        <div class="todo-widget-task-title">
                            <?php echo htmlspecialchars($task['title']); ?>
                        </div>
                        <?php if (!empty($task['description'])): ?>
                            <div class="todo-widget-task-desc">
                                <?php echo htmlspecialchars($task['description']); ?>
                            </div>
                        <?php endif; ?>
                        <?php if ($task['due_date']): ?>
                            <div class="todo-widget-task-due <?php echo $dueDateClass; ?>">
                                <i class="fas fa-calendar"></i> <?php echo formatDueDateWidget($task['due_date']); ?>
                            </div>
                        <?php endif; ?>
                    </div>
                    
                    <div class="todo-widget-priority priority-<?php echo $task['priority']; ?>"></div>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>
    
    <div class="todo-widget-footer">
        <a href="/modules/to-do/" class="todo-widget-link">
            <i class="fas fa-external-link-alt"></i>
            Zobacz wszystkie
        </a>
    </div>
</div>

<script>
async function completeTaskFromWidget(taskId, isCompleted) {
    try {
        const newStatus = isCompleted ? 'completed' : 'new';
        const response = await fetch('/modules/to-do/ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `action=update_task_status&task_id=${taskId}&status=${newStatus}`
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Opcjonalnie: odśwież widget lub usuń zadanie z listy
            if (isCompleted) {
                const taskElement = event.target.closest('.todo-widget-task');
                taskElement.style.opacity = '0.5';
                setTimeout(() => {
                    taskElement.remove();
                }, 300);
            }
        } else {
            // Przywróć poprzedni stan checkboxa w przypadku błędu
            event.target.checked = !isCompleted;
            console.error('Błąd aktualizacji zadania:', data.message);
        }
    } catch (error) {
        // Przywróć poprzedni stan checkboxa w przypadku błędu
        event.target.checked = !isCompleted;
        console.error('Błąd połączenia:', error);
    }
}
</script>
