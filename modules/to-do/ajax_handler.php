
<?php
// Plik: /modules/to-do/ajax_handler.php
// Handler AJAX dla modułu To-Do Kanban Board

require_once __DIR__.'/../../includes/auth.php';
require_once __DIR__.'/../../includes/db.php';

header('Content-Type: application/json');

// Sprawdź autoryzację
if (!is_logged_in()) {
    echo json_encode(['success' => false, 'message' => 'Brak autoryzacji']);
    exit;
}

$current_user = get_current_user();
$user_id = $current_user['id'];
$user_role = $current_user['role'];

$action = $_POST['action'] ?? '';

try {
    switch ($action) {
        case 'get_users':
            echo json_encode(getUsers($pdo));
            break;
            
        case 'get_tasks':
            echo json_encode(getTasks($pdo, $user_id));
            break;
            
        case 'create_task':
            echo json_encode(createTask($pdo, $_POST, $user_id));
            break;
            
        case 'update_task':
            echo json_encode(updateTask($pdo, $_POST, $user_id));
            break;
            
        case 'delete_task':
            echo json_encode(deleteTask($pdo, $_POST['task_id'], $user_id));
            break;
            
        case 'update_task_status':
            echo json_encode(updateTaskStatus($pdo, $_POST['task_id'], $_POST['status'], $user_id));
            break;
            
        default:
            echo json_encode(['success' => false, 'message' => 'Nieznana akcja']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Błąd serwera: ' . $e->getMessage()]);
}

function getUsers($pdo) {
    $query = "SELECT id, CONCAT(first_name, ' ', last_name) as name FROM employees WHERE deleted_at IS NULL ORDER BY first_name, last_name";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    return ['success' => true, 'users' => $users];
}

function getTasks($pdo, $user_id) {
    $query = "
        SELECT t.*, CONCAT(e.first_name, ' ', e.last_name) as assigned_user_name
        FROM todo_tasks t
        LEFT JOIN employees e ON t.assigned_user = e.id
        WHERE t.deleted_at IS NULL
        ORDER BY t.created_at DESC
    ";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    return ['success' => true, 'tasks' => $tasks];
}

function createTask($pdo, $data, $user_id) {
    $query = "
        INSERT INTO todo_tasks (title, description, assignment_type, assigned_user, location, priority, status, created_by, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ";
    
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([
        $data['title'],
        $data['description'],
        $data['assignment_type'],
        $data['assigned_user'] ?: null,
        $data['location'],
        $data['priority'],
        $data['status'],
        $user_id
    ]);
    
    if ($result) {
        return ['success' => true, 'message' => 'Zadanie zostało utworzone'];
    } else {
        return ['success' => false, 'message' => 'Błąd podczas tworzenia zadania'];
    }
}

function updateTask($pdo, $data, $user_id) {
    $query = "
        UPDATE todo_tasks 
        SET title = ?, description = ?, assignment_type = ?, assigned_user = ?, 
            location = ?, priority = ?, status = ?, updated_at = NOW()
        WHERE id = ?
    ";
    
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([
        $data['title'],
        $data['description'],
        $data['assignment_type'],
        $data['assigned_user'] ?: null,
        $data['location'],
        $data['priority'],
        $data['status'],
        $data['task_id']
    ]);
    
    if ($result) {
        return ['success' => true, 'message' => 'Zadanie zostało zaktualizowane'];
    } else {
        return ['success' => false, 'message' => 'Błąd podczas aktualizacji zadania'];
    }
}

function deleteTask($pdo, $task_id, $user_id) {
    $query = "UPDATE todo_tasks SET deleted_at = NOW() WHERE id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([$task_id]);
    
    if ($result) {
        return ['success' => true, 'message' => 'Zadanie zostało usunięte'];
    } else {
        return ['success' => false, 'message' => 'Błąd podczas usuwania zadania'];
    }
}

function updateTaskStatus($pdo, $task_id, $status, $user_id) {
    $query = "UPDATE todo_tasks SET status = ?, updated_at = NOW() WHERE id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([$status, $task_id]);
    
    if ($result) {
        return ['success' => true, 'message' => 'Status zadania został zaktualizowany'];
    } else {
        return ['success' => false, 'message' => 'Błąd podczas aktualizacji statusu'];
    }
}
?>
