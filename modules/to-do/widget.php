
<?php
// Plik: /modules/to-do/widget.php
// Niezależny widget To-Do dla kafelków dashboard

// Sprawdź czy widget jest wywoływany z odpowiednim kontekstem
if (!defined('WIDGET_CONTEXT')) {
    require_once __DIR__.'/../../includes/auth.php';
    require_once __DIR__.'/../../includes/db.php';
    
    if (!is_logged_in()) {
        echo '<div class="todo-widget-error">Wymagane logowanie</div>';
        return;
    }
    
    $current_user = get_current_user();
    $user_id = $current_user['id'];
}

// Pobierz zadania dla aktualnego użytkownika
try {
    $query = "
        SELECT id, title, description, assignment_type, status, priority
        FROM todo_tasks 
        WHERE deleted_at IS NULL 
        AND status != 'completed'
        AND (
            (assignment_type = 'self' AND assigned_user = ?) OR
            (assignment_type = 'user' AND assigned_user = ?) OR
            (assignment_type = 'global')
        )
        ORDER BY 
            CASE priority 
                WHEN 'high' THEN 1 
                WHEN 'medium' THEN 2 
                WHEN 'low' THEN 3 
            END,
            created_at DESC
        LIMIT 5
    ";
    
    $stmt = $pdo->prepare($query);
    $stmt->execute([$user_id, $user_id]);
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
} catch (Exception $e) {
    $tasks = [];
    error_log('Błąd widget To-Do: ' . $e->getMessage());
}
?>

<style>
.todo-widget {
    background: rgba(30, 41, 59, 0.8);
    border: 1px solid rgb(51, 65, 85);
    border-radius: 12px;
    padding: 15px;
    height: 100%;
    backdrop-filter: blur(10px);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
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

.todo-widget-checkbox {
    width: 16px;
    height: 16px;
    cursor: pointer;
    accent-color: #34d399;
    margin-top: 2px;
    flex-shrink: 0;
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
                <div class="todo-widget-task">
                    <input type="checkbox" 
                           class="todo-widget-checkbox" 
                           onchange="completeTaskFromWidget(<?php echo $task['id']; ?>, this.checked)">
                    
                    <div class="todo-widget-task-content">
                        <div class="todo-widget-task-title">
                            <?php echo htmlspecialchars($task['title']); ?>
                        </div>
                        <?php if (!empty($task['description'])): ?>
                            <div class="todo-widget-task-desc">
                                <?php echo htmlspecialchars($task['description']); ?>
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
    if (!isCompleted) return; // Widget tylko do oznaczania jako wykonane
    
    try {
        const response = await fetch('/modules/to-do/ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `action=update_task_status&task_id=${taskId}&status=completed`
        });
        
        const data = await response.json();
        
        if (data.success) {
            // Odśwież widget lub usuń zadanie z widoku
            location.reload();
        } else {
            console.error('Błąd oznaczania zadania:', data.message);
            // Cofnij checkbox
            event.target.checked = false;
        }
    } catch (error) {
        console.error('Błąd połączenia:', error);
        // Cofnij checkbox
        event.target.checked = false;
    }
}
</script>
