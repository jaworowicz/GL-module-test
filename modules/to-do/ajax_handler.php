
<?php
// Plik: /modules/to-do/ajax_handler.php
// Obsługa żądań AJAX dla modułu To-Do

session_start();
require_once __DIR__.'/../../includes/db.php';

// Sprawdź czy użytkownik jest zalogowany
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit;
}

$user_id = $_SESSION['user_id'];
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
            
        case 'update_task_status':
            echo json_encode(updateTaskStatus($pdo, $_POST['task_id'], $_POST['status'], $user_id));
            break;
            
        case 'delete_task':
            echo json_encode(deleteTask($pdo, $_POST['task_id'], $user_id));
            break;
            
        default:
            echo json_encode(['success' => false, 'message' => 'Invalid action']);
    }
} catch (Exception $e) {
    error_log('Todo AJAX Error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Server error occurred']);
}

function getUsers($pdo) {
    $query = "SELECT id, name 
              FROM users 
              WHERE is_active = 1 
              ORDER BY name";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    return ['success' => true, 'users' => $users];
}

function getTasks($pdo, $user_id) {
    $query = "
        SELECT 
            t.*,
            u.name as assigned_user_name,
            c.name as created_by_name
        FROM todo_tasks t
        LEFT JOIN users u ON t.assigned_user = u.id
        LEFT JOIN users c ON t.created_by = c.id
        WHERE t.deleted_at IS NULL
        ORDER BY 
            CASE 
                WHEN t.due_date IS NOT NULL AND t.due_date <= CURDATE() THEN 1
                WHEN t.due_date IS NOT NULL AND t.due_date <= DATE_ADD(CURDATE(), INTERVAL 1 DAY) THEN 2
                ELSE 3
            END,
            t.created_at DESC
    ";
    $stmt = $pdo->prepare($query);
    $stmt->execute();
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    return ['success' => true, 'tasks' => $tasks];
}

function createTask($pdo, $data, $user_id) {
    $query = "
        INSERT INTO todo_tasks (
            title, description, assignment_type, assigned_user, 
            sfid_id, priority, status_id, due_date, created_by, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ";
    
    // Mapowanie statusów na ID
    $statusMap = ['new' => 1, 'in-progress' => 2, 'returned' => 3, 'completed' => 4];
    $statusId = $statusMap[$data['status']] ?? 1;
    
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([
        $data['title'],
        $data['description'] ?? null,
        $data['assignment_type'],
        $data['assigned_user'] ?? null,
        $data['location'] ?? null,
        $data['priority'] ?? 'medium',
        $statusId,
        $data['due_date'] ?? null,
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
            sfid_id = ?, priority = ?, status_id = ?, due_date = ?, updated_at = NOW()
        WHERE id = ?
    ";
    
    // Mapowanie statusów na ID
    $statusMap = ['new' => 1, 'in-progress' => 2, 'returned' => 3, 'completed' => 4];
    $statusId = $statusMap[$data['status']] ?? 1;
    
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([
        $data['title'],
        $data['description'] ?? null,
        $data['assignment_type'],
        $data['assigned_user'] ?? null,
        $data['location'] ?? null,
        $data['priority'] ?? 'medium',
        $statusId,
        $data['due_date'] ?? null,
        $data['task_id']
    ]);
    
    if ($result) {
        return ['success' => true, 'message' => 'Zadanie zostało zaktualizowane'];
    } else {
        return ['success' => false, 'message' => 'Błąd podczas aktualizacji zadania'];
    }
}

function updateTaskStatus($pdo, $task_id, $status, $user_id) {
    // Mapowanie statusów na ID
    $statusMap = ['new' => 1, 'in-progress' => 2, 'returned' => 3, 'completed' => 4];
    $statusId = $statusMap[$status] ?? 1;
    
    $query = "UPDATE todo_tasks SET status_id = ?, updated_at = NOW() WHERE id = ?";
    $stmt = $pdo->prepare($query);
    $result = $stmt->execute([$statusId, $task_id]);
    
    if ($result) {
        // Jeśli zadanie jest zakończone, ustaw completed_by i completed_at
        if ($status === 'completed') {
            $completeQuery = "UPDATE todo_tasks SET completed_by = ?, completed_at = NOW() WHERE id = ?";
            $completeStmt = $pdo->prepare($completeQuery);
            $completeStmt->execute([$user_id, $task_id]);
        }
        
        return ['success' => true, 'message' => 'Status zadania został zaktualizowany'];
    } else {
        return ['success' => false, 'message' => 'Błąd podczas aktualizacji statusu'];
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
?>
