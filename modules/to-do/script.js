
// Globalne zmienne
let tasks = [];
let editingTaskId = null;
let currentUser = window.appData?.currentUser?.id || 1;
let confirmCallback = null;
let dragStartTime = 0;
let isDragging = false;

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

// Funkcje pomocnicze dla dat
function formatDueDate(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    date.setHours(0, 0, 0, 0);
    
    const diffTime = date - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays < 0) {
        return `Przeterminowane (${Math.abs(diffDays)} dni)`;
    } else if (diffDays === 0) {
        return 'Dziś ostatni dzień!';
    } else if (diffDays === 1) {
        return 'Jutro';
    } else {
        return `Za ${diffDays} dni`;
    }
}

function getDueDateClass(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    date.setHours(0, 0, 0, 0);
    
    const diffTime = date - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays < 0) {
        return 'due-overdue';
    } else if (diffDays === 0) {
        return 'due-today';
    }
    return '';
}

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
            tasks = data.tasks.map(task => ({
                ...task,
                // Mapowanie ID statusów na nazwy
                status: ['', 'new', 'in-progress', 'returned', 'completed'][task.status_id] || 'new'
            }));
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
        if (locationFilter !== 'all' && task.sfid_id !== locationFilter) {
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

    const userName = task.assigned_user_name || 'Wszyscy';
    const dueDateClass = getDueDateClass(task.due_date);
    
    if (dueDateClass) {
        taskDiv.classList.add(dueDateClass);
    }

    const dueDateHtml = task.due_date ? `
        <div class="task-due-date ${dueDateClass}">
            <i class="fas fa-calendar"></i> ${formatDueDate(task.due_date)}
        </div>
    ` : '';

    taskDiv.innerHTML = `
        <div class="task-priority priority-${task.priority}"></div>
        <div class="task-title">${escapeHtml(task.title)}</div>
        <div class="task-description">${escapeHtml(task.description || '')}</div>
        <div class="task-meta">
            <div class="task-assignee">
                <span class="assignee-type ${assignmentTypeClass}">${assignmentTypeText}</span>
                <span>${userName}</span>
            </div>
            <div>ID: ${task.sfid_id || 'N/A'}</div>
        </div>
        ${dueDateHtml}
        <div class="task-actions">
            <button class="task-action-btn btn-edit" onclick="event.stopPropagation(); editTask(${task.id})">
                <i class="fas fa-edit"></i>
            </button>
            <button class="task-action-btn btn-delete" onclick="event.stopPropagation(); deleteTask(${task.id})">
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
    if (!text) return '';
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
            document.getElementById('taskDescription').value = task.description || '';
            document.getElementById('taskAssignmentType').value = task.assignment_type;
            document.getElementById('taskAssignedUser').value = task.assigned_user || '';
            document.getElementById('taskLocation').value = task.sfid_id || '';
            document.getElementById('taskDueDate').value = task.due_date || '';
            document.getElementById('taskPriority').value = task.priority;
            document.getElementById('taskStatus').value = task.status;
            toggleUserSelect();
        }
    } else {
        title.textContent = 'Dodaj nowe zadanie';
        document.getElementById('taskForm').reset();
        document.getElementById('taskLocation').value = window.appData?.currentUser?.sfid || '20004014';
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
        due_date: document.getElementById('taskDueDate').value || null,
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

// Drag & Drop with improved mobile support
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
    if (target && !e.target.closest('.task-action-btn')) {
        dragStartTime = Date.now();
        isDragging = false;
        
        draggedElement = target;
        const touch = e.touches[0];
        initialX = touch.clientX;
        initialY = touch.clientY;
        currentX = touch.clientX;
        currentY = touch.clientY;
        
        // Opóźnienie przed rozpoczęciem przeciągania
        setTimeout(() => {
            if (draggedElement && !isDragging) {
                isDragging = true;
                target.classList.add('dragging', 'mobile-drag-mode');
                target.style.position = 'fixed';
                target.style.zIndex = '1000';
                target.style.pointerEvents = 'none';
                target.style.transform = 'rotate(3deg) scale(1.05)';
                target.style.left = (currentX - 50) + 'px';
                target.style.top = (currentY - 50) + 'px';
            }
        }, 200);
    }
}

function handleTouchMove(e) {
    if (!draggedElement) return;
    
    const touch = e.touches[0];
    currentX = touch.clientX;
    currentY = touch.clientY;
    
    const deltaX = Math.abs(currentX - initialX);
    const deltaY = Math.abs(currentY - initialY);
    
    // Rozpocznij przeciąganie jeśli ruch jest większy niż 10px
    if ((deltaX > 10 || deltaY > 10) && !isDragging) {
        isDragging = true;
        draggedElement.classList.add('dragging', 'mobile-drag-mode');
        draggedElement.style.position = 'fixed';
        draggedElement.style.zIndex = '1000';
        draggedElement.style.pointerEvents = 'none';
        draggedElement.style.transform = 'rotate(3deg) scale(1.05)';
    }
    
    if (isDragging) {
        e.preventDefault();
        
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
}

async function handleTouchEnd(e) {
    if (!draggedElement) return;
    
    // Jeśli nie było przeciągania, pozwól na normalne kliknięcia
    if (!isDragging) {
        draggedElement = null;
        return;
    }
    
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
    draggedElement.classList.remove('dragging', 'mobile-drag-mode');
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
    isDragging = false;
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
    renderUserWidget();
    if (window.appData?.isAdmin) {
        renderAdminWidget();
    }
}

function renderUserWidget() {
    const widgetContainer = document.getElementById('widget-tasks');
    const myTasks = tasks.filter(task => {
        // Filtruj zadania przypisane do użytkownika
        return (task.assignment_type === 'self' && task.assigned_user === currentUser) ||
               (task.assignment_type === 'user' && task.assigned_user === currentUser) ||
               (task.assignment_type === 'global');
    });

    widgetContainer.innerHTML = '';

    if (myTasks.length === 0) {
        widgetContainer.innerHTML = '<p style="color: #94a3b8; text-align: center; padding: 20px;">Brak zadań do wykonania</p>';
        return;
    }

    myTasks.forEach(task => {
        const taskDiv = document.createElement('div');
        taskDiv.className = 'widget-task';
        
        const dueDateClass = getDueDateClass(task.due_date);
        if (dueDateClass) {
            taskDiv.classList.add(dueDateClass);
        }
        
        const dueDateHtml = task.due_date ? `
            <div class="widget-task-due ${dueDateClass}">
                ${formatDueDate(task.due_date)}
            </div>
        ` : '';
        
        taskDiv.innerHTML = `
            <label class="custom-checkbox">
                <input type="checkbox" ${task.status === 'completed' ? 'checked' : ''} 
                       onchange="toggleTaskCompletion(${task.id}, this.checked)">
                <span class="checkbox-checkmark"></span>
            </label>
            <div class="widget-task-text ${task.status === 'completed' ? 'completed' : ''}">
                <strong>${escapeHtml(task.title)}</strong>
                <small>${escapeHtml(task.description || '')}</small>
                ${dueDateHtml}
            </div>
            <span class="assignee-type type-${task.assignment_type}">${task.assignment_type}</span>
        `;
        
        widgetContainer.appendChild(taskDiv);
    });
}

function renderAdminWidget() {
    const adminWidget = document.getElementById('admin-widget');
    if (!adminWidget) return;
    
    adminWidget.style.display = 'block';

    // Statystyki
    const stats = {
        new: tasks.filter(t => t.status === 'new').length,
        progress: tasks.filter(t => t.status === 'in-progress').length,
        returned: tasks.filter(t => t.status === 'returned').length,
        completed: tasks.filter(t => t.status === 'completed').length
    };

    const statNew = document.getElementById('stat-new');
    const statProgress = document.getElementById('stat-progress');
    const statReturned = document.getElementById('stat-returned');
    const statCompleted = document.getElementById('stat-completed');

    if (statNew) statNew.textContent = stats.new;
    if (statProgress) statProgress.textContent = stats.progress;
    if (statReturned) statReturned.textContent = stats.returned;
    if (statCompleted) statCompleted.textContent = stats.completed;

    // Zadania wymagające uwagi
    const priorityTasks = tasks.filter(task => {
        const dueDateClass = getDueDateClass(task.due_date);
        return task.status === 'returned' || dueDateClass === 'due-overdue' || dueDateClass === 'due-today';
    });

    const priorityContainer = document.getElementById('admin-priority-tasks');
    if (!priorityContainer) return;
    
    priorityContainer.innerHTML = '';

    if (priorityTasks.length === 0) {
        priorityContainer.innerHTML = '<p style="color: #94a3b8; text-align: center; padding: 15px; font-size: 0.8rem;">Brak zadań wymagających uwagi</p>';
        return;
    }

    priorityTasks.forEach(task => {
        const taskDiv = document.createElement('div');
        taskDiv.className = 'admin-priority-task';
        
        const dueDateClass = getDueDateClass(task.due_date);
        let priorityClass = '';
        let icon = 'fas fa-info-circle';
        
        if (task.status === 'returned') {
            priorityClass = 'priority-warning';
            icon = 'fas fa-undo';
        } else if (dueDateClass === 'due-overdue') {
            priorityClass = 'priority-urgent';
            icon = 'fas fa-exclamation-triangle';
        } else if (dueDateClass === 'due-today') {
            priorityClass = 'priority-warning';
            icon = 'fas fa-clock';
        }
        
        if (priorityClass) {
            taskDiv.classList.add(priorityClass);
        }
        
        const statusText = {
            'returned': 'Zwrócone',
            'new': 'Nowe',
            'in-progress': 'W toku',
            'completed': 'Zakończone'
        }[task.status];
        
        const assigneeText = task.assignment_type === 'global' ? 'Globalne' : 
                           task.assignment_type === 'self' ? 'Własne' : 
                           (task.assigned_user_name || getUserName(task.assigned_user));
        
        taskDiv.innerHTML = `
            <div class="admin-task-icon">
                <i class="${icon}" style="color: ${priorityClass === 'priority-urgent' ? '#ef4444' : '#f59e0b'};"></i>
            </div>
            <div class="admin-task-content">
                <div class="admin-task-title">${escapeHtml(task.title)}</div>
                <div class="admin-task-meta">
                    ${assigneeText} • ${task.sfid_id || 'Brak lokalizacji'}
                    ${task.due_date ? ' • ' + formatDueDate(task.due_date) : ''}
                </div>
            </div>
            <div class="admin-task-status ${task.status === 'returned' ? 'status-returned' : dueDateClass === 'due-overdue' ? 'status-overdue' : ''}">
                ${statusText}
            </div>
        `;
        
        priorityContainer.appendChild(taskDiv);
    });
}

async function toggleTaskCompletion(taskId, isCompleted) {
    const newStatus = isCompleted ? 'completed' : 'returned';
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
