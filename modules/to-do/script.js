
// Globalne zmienne
let tasks = [];
let editingTaskId = null;
let currentUser = window.appData?.currentUser?.id || 1;
let confirmCallback = null;

// Inicjalizacja
document.addEventListener('DOMContentLoaded', function() {
    loadTasks();
    loadUsers();
    renderTasks();
    renderWidget();
    setupDragAndDrop();
    setupFilters();
    setupTouchEvents();
});

// Ładowanie użytkowników z bazy danych
async function loadUsers() {
    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=get_users'
        });
        const data = await response.json();
        
        if (data.success) {
            const userFilter = document.getElementById('userFilter');
            const taskAssignedUser = document.getElementById('taskAssignedUser');
            
            // Wyczyść poprzednie opcje (oprócz "Wszyscy użytkownicy")
            userFilter.innerHTML = '<option value="all">Wszyscy użytkownicy</option>';
            taskAssignedUser.innerHTML = '';
            
            data.users.forEach(user => {
                const option1 = new Option(user.name, user.id);
                const option2 = new Option(user.name, user.id);
                userFilter.appendChild(option1);
                taskAssignedUser.appendChild(option2);
            });
        }
    } catch (error) {
        console.error('Błąd ładowania użytkowników:', error);
    }
}

// Modal potwierdzenia
function showConfirm(message, callback) {
    document.getElementById('confirmModalText').textContent = message;
    document.getElementById('confirmModal').style.display = 'block';
    confirmCallback = callback;
}

function closeConfirmModal() {
    document.getElementById('confirmModal').style.display = 'none';
    confirmCallback = null;
}

document.getElementById('confirmModalOk').addEventListener('click', function() {
    if (confirmCallback) {
        confirmCallback();
    }
    closeConfirmModal();
});

// Zarządzanie zadaniami
async function loadTasks() {
    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: 'action=get_tasks'
        });
        const data = await response.json();
        
        if (data.success) {
            tasks = data.tasks;
        } else {
            console.error('Błąd ładowania zadań:', data.message);
            tasks = [];
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        tasks = [];
    }
}

async function saveTasks() {
    // Synchronizacja z bazą danych zamiast localStorage
    renderTasks();
    renderWidget();
}

function renderTasks() {
    const columns = {
        'new': document.getElementById('new-tasks'),
        'in-progress': document.getElementById('in-progress-tasks'),
        'returned': document.getElementById('returned-tasks'),
        'completed': document.getElementById('completed-tasks')
    };

    // Wyczyść kolumny
    Object.values(columns).forEach(column => {
        column.innerHTML = '';
    });

    // Filtruj zadania
    const filteredTasks = getFilteredTasks();

    // Renderuj zadania
    filteredTasks.forEach(task => {
        const taskElement = createTaskElement(task);
        columns[task.status].appendChild(taskElement);
    });

    // Aktualizuj liczniki
    updateTaskCounts();
}

function getFilteredTasks() {
    const locationFilter = document.getElementById('locationFilter').value;
    const userFilter = document.getElementById('userFilter').value;

    return tasks.filter(task => {
        // Filtr lokalizacji
        if (locationFilter !== 'all' && task.location !== locationFilter) {
            return false;
        }

        // Filtr użytkownika
        if (userFilter !== 'all') {
            const userId = parseInt(userFilter);
            if (task.assignment_type === 'user' && task.assigned_user !== userId) {
                return false;
            }
            if (task.assignment_type === 'self' && task.assigned_user !== userId) {
                return false;
            }
        }

        return true;
    });
}

function createTaskElement(task) {
    const taskDiv = document.createElement('div');
    taskDiv.className = 'task-card';
    taskDiv.draggable = true;
    taskDiv.dataset.taskId = task.id;

    const assignmentTypeClass = `type-${task.assignment_type}`;
    const assignmentTypeText = {
        'global': 'Globalne',
        'user': 'Użytkownik',
        'self': 'Własne'
    }[task.assignment_type];

    const userName = task.assigned_user ? getUserName(task.assigned_user) : 'Wszyscy';

    taskDiv.innerHTML = `
        <div class="task-priority priority-${task.priority}"></div>
        <div class="task-title">${escapeHtml(task.title)}</div>
        <div class="task-description">${escapeHtml(task.description)}</div>
        <div class="task-meta">
            <div class="task-assignee">
                <span class="assignee-type ${assignmentTypeClass}">${assignmentTypeText}</span>
                <span>${userName}</span>
            </div>
            <div>ID: ${task.location}</div>
        </div>
        <div class="task-actions">
            <button class="task-action-btn btn-edit" onclick="editTask(${task.id})">
                <i class="fas fa-edit"></i>
            </button>
            <button class="task-action-btn btn-delete" onclick="deleteTask(${task.id})">
                <i class="fas fa-trash"></i>
            </button>
        </div>
    `;

    return taskDiv;
}

function getUserName(userId) {
    // To będzie pobierane z listy użytkowników załadowanej z bazy
    const userSelect = document.getElementById('taskAssignedUser');
    const option = userSelect.querySelector(`option[value="${userId}"]`);
    return option ? option.textContent : 'Nieznany';
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function updateTaskCounts() {
    const filteredTasks = getFilteredTasks();
    const counts = {
        'new': 0,
        'in-progress': 0,
        'returned': 0,
        'completed': 0
    };

    filteredTasks.forEach(task => {
        counts[task.status]++;
    });

    Object.keys(counts).forEach(status => {
        const countElement = document.getElementById(`${status}-count`);
        if (countElement) {
            countElement.textContent = counts[status];
        }
    });
}

// Modal zarządzanie
function openTaskModal(taskId = null) {
    editingTaskId = taskId;
    const modal = document.getElementById('taskModal');
    const title = document.getElementById('modalTitle');
    
    if (taskId) {
        title.textContent = 'Edytuj zadanie';
        const task = tasks.find(t => t.id === taskId);
        if (task) {
            document.getElementById('taskTitle').value = task.title;
            document.getElementById('taskDescription').value = task.description;
            document.getElementById('taskAssignmentType').value = task.assignment_type;
            document.getElementById('taskAssignedUser').value = task.assigned_user || '';
            document.getElementById('taskLocation').value = task.location;
            document.getElementById('taskPriority').value = task.priority;
            document.getElementById('taskStatus').value = task.status;
            toggleUserSelect();
        }
    } else {
        title.textContent = 'Dodaj nowe zadanie';
        document.getElementById('taskForm').reset();
        document.getElementById('taskLocation').value = window.appData.currentUser.sfid || '20004014';
    }
    
    modal.style.display = 'block';
}

function closeTaskModal() {
    document.getElementById('taskModal').style.display = 'none';
    editingTaskId = null;
}

function toggleUserSelect() {
    const assignmentType = document.getElementById('taskAssignmentType').value;
    const userSelectGroup = document.getElementById('userSelectGroup');
    
    if (assignmentType === 'user') {
        userSelectGroup.style.display = 'block';
    } else {
        userSelectGroup.style.display = 'none';
    }
}

// Obsługa formularza
document.getElementById('taskForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    
    const formData = {
        title: document.getElementById('taskTitle').value,
        description: document.getElementById('taskDescription').value,
        assignment_type: document.getElementById('taskAssignmentType').value,
        assigned_user: document.getElementById('taskAssignedUser').value || null,
        location: document.getElementById('taskLocation').value,
        priority: document.getElementById('taskPriority').value,
        status: document.getElementById('taskStatus').value
    };

    if (formData.assignment_type === 'self') {
        formData.assigned_user = currentUser;
    } else if (formData.assignment_type === 'global') {
        formData.assigned_user = null;
    } else if (formData.assignment_type === 'user') {
        formData.assigned_user = parseInt(formData.assigned_user);
    }

    try {
        const action = editingTaskId ? 'update_task' : 'create_task';
        const body = new URLSearchParams({
            action: action,
            ...formData
        });
        
        if (editingTaskId) {
            body.append('task_id', editingTaskId);
        }

        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body
        });
        
        const data = await response.json();
        
        if (data.success) {
            await loadTasks();
            renderTasks();
            renderWidget();
            closeTaskModal();
            showToast(data.message, 'success');
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd zapisywania zadania:', error);
        showToast('Błąd połączenia z serwerem', 'error');
    }
});

function editTask(taskId) {
    openTaskModal(taskId);
}

async function deleteTask(taskId) {
    showConfirm('Czy na pewno chcesz usunąć to zadanie?', async function() {
        try {
            const response = await fetch('ajax_handler.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `action=delete_task&task_id=${taskId}`
            });
            
            const data = await response.json();
            
            if (data.success) {
                await loadTasks();
                renderTasks();
                renderWidget();
                showToast(data.message, 'success');
            } else {
                showToast(data.message, 'error');
            }
        } catch (error) {
            console.error('Błąd usuwania zadania:', error);
            showToast('Błąd połączenia z serwerem', 'error');
        }
    });
}

// Drag & Drop with mobile support
let draggedElement = null;
let initialX = 0;
let initialY = 0;
let currentX = 0;
let currentY = 0;

function setupDragAndDrop() {
    const columns = document.querySelectorAll('.drop-zone');
    
    columns.forEach(column => {
        column.addEventListener('dragover', handleDragOver);
        column.addEventListener('drop', handleDrop);
        column.addEventListener('dragenter', handleDragEnter);
        column.addEventListener('dragleave', handleDragLeave);
    });

    document.addEventListener('dragstart', handleDragStart);
    document.addEventListener('dragend', handleDragEnd);
}

function setupTouchEvents() {
    document.addEventListener('touchstart', handleTouchStart, { passive: false });
    document.addEventListener('touchmove', handleTouchMove, { passive: false });
    document.addEventListener('touchend', handleTouchEnd, { passive: false });
}

function handleTouchStart(e) {
    const target = e.target.closest('.task-card');
    if (target) {
        draggedElement = target;
        const touch = e.touches[0];
        initialX = touch.clientX;
        initialY = touch.clientY;
        currentX = touch.clientX;
        currentY = touch.clientY;
        
        target.classList.add('dragging');
        target.style.position = 'fixed';
        target.style.zIndex = '1000';
        target.style.pointerEvents = 'none';
        target.style.transform = 'rotate(3deg) scale(1.05)';
        
        e.preventDefault();
    }
}

function handleTouchMove(e) {
    if (!draggedElement) return;
    
    e.preventDefault();
    const touch = e.touches[0];
    currentX = touch.clientX;
    currentY = touch.clientY;
    
    draggedElement.style.left = (currentX - 50) + 'px';
    draggedElement.style.top = (currentY - 50) + 'px';
    
    // Znajdź kolumnę pod palcem
    const elementBelow = document.elementFromPoint(currentX, currentY);
    const dropZone = elementBelow?.closest('.drop-zone');
    
    // Usuń poprzednie podświetlenia
    document.querySelectorAll('.drop-zone').forEach(zone => {
        zone.classList.remove('drag-over');
    });
    
    // Dodaj podświetlenie do aktualnej kolumny
    if (dropZone) {
        dropZone.classList.add('drag-over');
    }
}

async function handleTouchEnd(e) {
    if (!draggedElement) return;
    
    e.preventDefault();
    
    // Znajdź kolumnę pod miejscem puszczenia
    const elementBelow = document.elementFromPoint(currentX, currentY);
    const dropZone = elementBelow?.closest('.drop-zone');
    
    if (dropZone) {
        const newStatus = dropZone.id.replace('-tasks', '');
        const taskId = parseInt(draggedElement.dataset.taskId);
        const task = tasks.find(t => t.id === taskId);
        
        if (task && task.status !== newStatus) {
            await updateTaskStatus(taskId, newStatus);
        }
    }
    
    // Przywróć element do normalnego stanu
    draggedElement.classList.remove('dragging');
    draggedElement.style.position = '';
    draggedElement.style.zIndex = '';
    draggedElement.style.pointerEvents = '';
    draggedElement.style.transform = '';
    draggedElement.style.left = '';
    draggedElement.style.top = '';
    
    // Usuń podświetlenia
    document.querySelectorAll('.drop-zone').forEach(zone => {
        zone.classList.remove('drag-over');
    });
    
    draggedElement = null;
}

function handleDragStart(e) {
    if (e.target.classList.contains('task-card')) {
        e.target.classList.add('dragging');
        e.dataTransfer.setData('text/plain', e.target.dataset.taskId);
    }
}

function handleDragEnd(e) {
    if (e.target.classList.contains('task-card')) {
        e.target.classList.remove('dragging');
    }
}

function handleDragOver(e) {
    e.preventDefault();
}

function handleDragEnter(e) {
    e.preventDefault();
    e.currentTarget.classList.add('drag-over');
}

function handleDragLeave(e) {
    e.currentTarget.classList.remove('drag-over');
}

async function handleDrop(e) {
    e.preventDefault();
    e.currentTarget.classList.remove('drag-over');
    
    const taskId = parseInt(e.dataTransfer.getData('text/plain'));
    const newStatus = e.currentTarget.id.replace('-tasks', '');
    
    const task = tasks.find(t => t.id === taskId);
    if (task && task.status !== newStatus) {
        await updateTaskStatus(taskId, newStatus);
    }
}

async function updateTaskStatus(taskId, newStatus) {
    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: `action=update_task_status&task_id=${taskId}&status=${newStatus}`
        });
        
        const data = await response.json();
        
        if (data.success) {
            await loadTasks();
            renderTasks();
            renderWidget();
        } else {
            showToast(data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd aktualizacji statusu:', error);
        showToast('Błąd połączenia z serwerem', 'error');
    }
}

// Widget
function renderWidget() {
    const widgetContainer = document.getElementById('widget-tasks');
    const myTasks = tasks.filter(task => {
        return (task.assignment_type === 'self' && task.assigned_user === currentUser) ||
               (task.assignment_type === 'user' && task.assigned_user === currentUser) ||
               (task.assignment_type === 'global');
    }).filter(task => task.status !== 'completed');

    widgetContainer.innerHTML = '';

    if (myTasks.length === 0) {
        widgetContainer.innerHTML = '<p style="color: #94a3b8; text-align: center; padding: 20px;">Brak zadań do wykonania</p>';
        return;
    }

    myTasks.forEach(task => {
        const taskDiv = document.createElement('div');
        taskDiv.className = 'widget-task';
        
        taskDiv.innerHTML = `
            <input type="checkbox" class="widget-checkbox" ${task.status === 'completed' ? 'checked' : ''} 
                   onchange="toggleTaskCompletion(${task.id}, this.checked)">
            <div class="widget-task-text ${task.status === 'completed' ? 'completed' : ''}">
                <strong>${escapeHtml(task.title)}</strong>
                <small>${escapeHtml(task.description)}</small>
            </div>
            <span class="assignee-type type-${task.assignment_type}">${task.assignment_type}</span>
        `;
        
        widgetContainer.appendChild(taskDiv);
    });
}

async function toggleTaskCompletion(taskId, isCompleted) {
    const newStatus = isCompleted ? 'completed' : 'new';
    await updateTaskStatus(taskId, newStatus);
}

// Filtry
function setupFilters() {
    document.getElementById('locationFilter').addEventListener('change', renderTasks);
    document.getElementById('userFilter').addEventListener('change', renderTasks);
}

// Toast notifications
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `fixed top-4 right-4 z-50 p-4 rounded-lg border max-w-md transition-all duration-300 transform translate-x-0 ${
        type === 'success' ? 'bg-green-600/90 border-green-500 text-white' : 
        type === 'error' ? 'bg-red-600/90 border-red-500 text-white' : 
        'bg-blue-600/90 border-blue-500 text-white'
    }`;
    toast.innerHTML = `
        <div class="flex items-center">
            <i class="fas fa-${type === 'success' ? 'check' : type === 'error' ? 'exclamation-triangle' : 'info-circle'} mr-2"></i>
            <span>${message}</span>
        </div>
    `;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.transform = 'translateX(100%)';
        toast.style.opacity = '0';
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 300);
    }, 3000);
}

// Zamykanie modali przy kliknięciu na tło
window.onclick = function(event) {
    const taskModal = document.getElementById('taskModal');
    const confirmModal = document.getElementById('confirmModal');
    
    if (event.target === taskModal) {
        closeTaskModal();
    }
    if (event.target === confirmModal) {
        closeConfirmModal();
    }
}
