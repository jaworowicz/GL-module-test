
// Globalne zmienne
let currentCounters = [];
let currentKpiGoals = [];
let selectedCounterId = null;
let currentView = localStorage.getItem('licznik_view') || 'grid';
let currentCategory = localStorage.getItem('licznik_category') || 'all';
let deleteCounterId = null;

// Inicjalizacja po załadowaniu DOM
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
    loadCounterData();
    loadKpiData();
    setupKeyboardNavigation();
});

// Inicjalizacja aplikacji
function initializeApp() {
    populateCategoryDropdown();
    populateModalCategories();

    // Ustaw domyślną datę
    const dateSelector = document.getElementById('date-selector');
    if (dateSelector && !dateSelector.value) {
        dateSelector.value = window.appData.today;
    }
    
    // Przywróć widok i kategorię z localStorage
    changeView(currentView);
    
    const savedCategoryName = localStorage.getItem('licznik_category_name');
    if (savedCategoryName) {
        document.getElementById('current-category-name').textContent = savedCategoryName;
    }
}

// Konfiguracja event listeners
function setupEventListeners() {
    // Selector użytkownika
    document.getElementById('user-selector').addEventListener('change', function() {
        loadCounterData();
    });

    // Selector daty
    document.getElementById('date-selector').addEventListener('change', function() {
        loadCounterData();
    });

    // Selector miesiąca KPI
    document.getElementById('kpi-month-selector').addEventListener('change', function() {
        loadKpiData();
    });

    // Zamykanie modali kliknięciem w tło
    document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeAllModals();
            }
        });
    });
}

// Populacja kategorii w dropdown
function populateCategoryDropdown() {
    const menu = document.getElementById('category-menu');
    if (!menu) return;

    let html = '<div class="category-menu-item" onclick="filterByCategory(\'all\', \'Wszystkie Kategorie\')">Wszystkie Kategorie</div>';
    
    window.appData.categories.forEach(category => {
        html += `<div class="category-menu-item" onclick="filterByCategory('${category.id}', '${category.name.replace(/'/g, "\\'")}')">${category.name}</div>`;
    });
    
    menu.innerHTML = html;
}

// Populacja kategorii w modalach
function populateModalCategories() {
    const selectors = ['edit-counter-category', 'new-counter-category'];
    
    selectors.forEach(selectorId => {
        const selector = document.getElementById(selectorId);
        if (!selector) return;

        let html = '<option value="">Wybierz kategorię</option>';
        window.appData.categories.forEach(category => {
            html += `<option value="${category.id}">${category.name}</option>`;
        });
        
        selector.innerHTML = html;
    });
}

// Przełącz menu kategorii
function toggleCategoryMenu() {
    const menu = document.getElementById('category-menu');
    menu.classList.toggle('show');
}

// Filtruj według kategorii
function filterByCategory(categoryId, categoryName) {
    currentCategory = categoryId;
    localStorage.setItem('licznik_category', categoryId);
    localStorage.setItem('licznik_category_name', categoryName);
    
    document.getElementById('current-category-name').textContent = categoryName;
    document.getElementById('category-menu').classList.remove('show');
    
    renderCounters();
}

// Ładowanie danych liczników
function loadCounterData() {
    const userId = document.getElementById('user-selector').value;
    const date = document.getElementById('date-selector').value;
    
    fetch('ajax_handler.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: `action=get_counters&user_id=${userId}&date=${date}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            currentCounters = data.counters;
            renderCounters();
        } else {
            console.error('Błąd ładowania liczników:', data.message);
        }
    })
    .catch(error => {
        console.error('Błąd:', error);
    });
}

// Renderowanie liczników
function renderCounters() {
    const grid = document.getElementById('counters-grid');
    if (!grid) return;

    let filteredCounters = currentCounters;
    
    // Filtruj według kategorii
    if (currentCategory !== 'all') {
        filteredCounters = currentCounters.filter(counter => 
            counter.category_id == currentCategory
        );
    }

    let html = '';
    filteredCounters.forEach(counter => {
        html += createCounterCard(counter);
    });

    grid.innerHTML = html;
}

// Tworzenie karty licznika
function createCounterCard(counter) {
    const categoryName = window.appData.categories.find(cat => cat.id == counter.category_id)?.name || 'Bez kategorii';
    
    // Znajdź cel dzienny dla tego licznika
    const dailyGoal = getDailyGoalForCounter(counter.id);
    let dailyGoalText = '';
    
    if (dailyGoal && typeof dailyGoal === 'object') {
        if (dailyGoal.current >= dailyGoal.total) {
            dailyGoalText = `Cel dzienny: ✅ ${dailyGoal.current}/${dailyGoal.total}`;
        } else {
            dailyGoalText = `Cel dzienny: ${dailyGoal.current}/${dailyGoal.total} (pozostało: ${dailyGoal.remaining})`;
        }
    } else if (dailyGoal > 0) {
        dailyGoalText = `Cel dzienny: ${dailyGoal}`;
    }

    const card = `
        <div class="counter-card p-6" data-counter-id="${counter.id}">
            <div class="card-header">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <h4 class="counter-title">${counter.title}</h4>
                        <p class="counter-category">${categoryName}</p>
                    </div>
                    <div class="relative">
                        <button class="text-gray-400 hover:text-white p-1" onclick="event.stopPropagation(); openCounterSettings(${counter.id})">
                            <i class="fas fa-cog"></i>
                        </button>
                    </div>
                </div>
            </div>
            
            <div class="value-display text-center">
                <div class="counter-value">${counter.value || 0}</div>
                ${dailyGoalText ? `<div class="daily-goal">${dailyGoalText}</div>` : ''}
            </div>
            
            <div class="list-view-value">${counter.value || 0}</div>
            
            <div class="controls counter-controls">
                <button class="counter-btn minus" onclick="changeCounterValue(${counter.id}, -${counter.increment || 1})">
                    <i class="fas fa-minus"></i>
                </button>
                <button class="counter-btn plus" onclick="changeCounterValue(${counter.id}, ${counter.increment || 1})">
                    <i class="fas fa-plus"></i>
                </button>
            </div>
            
            <div class="goal-status">
                ${dailyGoalText ? `<div class="daily-goal">${dailyGoalText}</div>` : ''}
            </div>
        </div>
    `;

    return card;
}

// Znajdź cel dzienny dla licznika z uwzględnieniem dzisiejszej realizacji
function getDailyGoalForCounter(counterId) {
    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return 0;

    for (const kpiGoal of currentKpiGoals) {
        const linkedIds = kpiGoal.linked_counter_ids || [];
        if (linkedIds.includes(counterId.toString()) || linkedIds.includes(counterId)) {
            const dailyGoal = kpiGoal.daily_goal || 0;
            const currentValue = parseInt(counter.value) || 0;
            const remaining = Math.max(0, dailyGoal - currentValue);
            return { total: dailyGoal, remaining: remaining, current: currentValue };
        }
    }
    return 0;
}

// Zmiana wartości licznika
function changeCounterValue(counterId, change) {
    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return;

    const newValue = Math.max(0, (parseInt(counter.value) || 0) + change);
    
    const userId = document.getElementById('user-selector').value;
    const date = document.getElementById('date-selector').value;

    fetch('ajax_handler.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: `action=save_counter_value&counter_id=${counterId}&value=${newValue}&user_id=${userId}&date=${date}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Aktualizuj lokalną wartość
            counter.value = newValue;
            
            // Odśwież wyświetlanie
            renderCounters();
            
            // Odśwież dane KPI po zmianie wartości
            loadKpiData();
            // Odśwież cele dzienne dla wszystkich liczników
            updateDailyGoalsDisplay();
        } else {
            console.error('Błąd zapisywania:', data.message);
        }
    })
    .catch(error => {
        console.error('Błąd:', error);
    });
}

// Funkcja do aktualizacji wyświetlania celów dziennych
function updateDailyGoalsDisplay() {
    document.querySelectorAll('.counter-card').forEach(card => {
        const counterId = card.dataset.counterId;
        const counter = currentCounters.find(c => c.id == counterId);
        if (!counter) return;

        const dailyGoal = getDailyGoalForCounter(counter.id);
        const goalElement = card.querySelector('.daily-goal');
        
        if (goalElement) {
            let dailyGoalText = '';
            if (dailyGoal && typeof dailyGoal === 'object') {
                if (dailyGoal.current >= dailyGoal.total) {
                    dailyGoalText = `Cel dzienny: ✅ ${dailyGoal.current}/${dailyGoal.total}`;
                } else {
                    dailyGoalText = `Cel dzienny: ${dailyGoal.current}/${dailyGoal.total} (pozostało: ${dailyGoal.remaining})`;
                }
            } else if (dailyGoal > 0) {
                dailyGoalText = `Cel dzienny: ${dailyGoal}`;
            }
            goalElement.textContent = dailyGoalText;
        }
    });
}

// Zmień widok
function changeView(view) {
    currentView = view;
    localStorage.setItem('licznik_view', view);

    const container = document.getElementById('counters-container');
    const grid = document.getElementById('counters-grid');
    
    if (view === 'list') {
        container.classList.remove('grid-view');
        container.classList.add('list-view');
        grid.className = 'space-y-2';
    } else {
        container.classList.remove('list-view');
        container.classList.add('grid-view');
        grid.className = 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6';
    }

    // Aktualizuj przyciski
    document.getElementById('grid-view-btn').classList.toggle('bg-gray-500', view === 'grid');
    document.getElementById('grid-view-btn').classList.toggle('text-white', view === 'grid');
    document.getElementById('grid-view-btn').classList.toggle('text-gray-300', view !== 'grid');

    document.getElementById('list-view-btn').classList.toggle('bg-gray-500', view === 'list');
    document.getElementById('list-view-btn').classList.toggle('text-white', view === 'list');
    document.getElementById('list-view-btn').classList.toggle('text-gray-300', view !== 'list');
}

// Ładowanie danych KPI
function loadKpiData() {
    const month = document.getElementById('kpi-month-selector').value;
    
    fetch('ajax_handler.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: `action=get_kpi_data&month=${month}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            currentKpiGoals = data.kpi_goals;
            renderKpiTable();
        } else {
            console.error('Błąd ładowania KPI:', data.message);
        }
    })
    .catch(error => {
        console.error('Błąd:', error);
    });
}

// Renderowanie tabeli KPI
function renderKpiTable() {
    const tbody = document.getElementById('kpi-table-body');
    if (!tbody) return;

    let html = '';
    currentKpiGoals.forEach(goal => {
        const progressPercent = goal.total_goal > 0 ? Math.min(100, (goal.monthly_total / goal.total_goal) * 100) : 0;
        
        html += `
            <tr class="border-b border-slate-700">
                <td class="px-6 py-4 font-medium text-white">${goal.name}</td>
                <td class="px-6 py-4 text-right font-mono">${goal.monthly_total || 0}</td>
                <td class="px-6 py-4 text-right font-mono">${goal.daily_goal || 0}</td>
                <td class="px-6 py-4 text-right font-mono">${goal.total_goal}</td>
                <td class="px-6 py-4">
                    <div class="progress-bar h-4">
                        <div class="progress-fill" style="width: ${progressPercent}%"></div>
                    </div>
                    <div class="text-xs text-gray-400 mt-1">${Math.round(progressPercent)}%</div>
                </td>
                <td class="px-6 py-4">
                    <button onclick="editKpiGoal(${goal.id})" class="text-blue-400 hover:text-blue-300 mr-2">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button onclick="deleteKpiGoal(${goal.id})" class="text-red-400 hover:text-red-300">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            </tr>
        `;
    });

    tbody.innerHTML = html;
}

// Konfiguracja nawigacji klawiszowej
function setupKeyboardNavigation() {
    document.addEventListener('keydown', function(e) {
        // Jeśli modal jest otwarty, nie obsługuj skrótów
        if (document.querySelector('.modal-overlay:not(.hidden)')) {
            if (e.key === 'Escape') {
                closeAllModals();
            }
            return;
        }

        switch(e.key.toLowerCase()) {
            case 'v':
                e.preventDefault();
                changeView(currentView === 'grid' ? 'list' : 'grid');
                break;
            case 'escape':
                closeAllModals();
                break;
        }
    });
}

// ============= FUNKCJE MODALI I ZARZĄDZANIA =============

// Nowy licznik
function showNewCounterModal() {
    document.getElementById('new-counter-modal').classList.remove('hidden');
    document.getElementById('new-counter-title').value = '';
    document.getElementById('new-counter-category').value = '';
    document.getElementById('new-counter-increment').value = '1';
    document.getElementById('new-counter-personal').checked = true;
}

function saveNewCounter() {
    const title = document.getElementById('new-counter-title').value.trim();
    const categoryId = document.getElementById('new-counter-category').value;
    const increment = parseInt(document.getElementById('new-counter-increment').value) || 1;
    const isPersonal = document.getElementById('new-counter-personal').checked;
    
    if (!title) {
        alert('Wprowadź nazwę licznika');
        return;
    }
    
    if (!categoryId) {
        alert('Wybierz kategorię');
        return;
    }

    fetch('ajax_handler.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: `action=create_counter&title=${encodeURIComponent(title)}&category_id=${categoryId}&increment=${increment}&is_personal=${isPersonal ? 1 : 0}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closeAllModals();
            loadCounterData();
        } else {
            alert('Błąd tworzenia licznika: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Błąd:', error);
        alert('Błąd sieciowy');
    });
}

// Edycja licznika
function editCounter(counterId) {
    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return;

    selectedCounterId = counterId;
    
    document.getElementById('edit-counter-title').value = counter.title;
    document.getElementById('edit-counter-category').value = counter.category_id;
    document.getElementById('edit-counter-increment').value = counter.increment || 1;
    document.getElementById('edit-counter-personal').checked = counter.is_personal == 1;
    
    document.getElementById('edit-counter-modal').classList.remove('hidden');
}

function saveEditCounter() {
    if (!selectedCounterId) return;

    const title = document.getElementById('edit-counter-title').value.trim();
    const categoryId = document.getElementById('edit-counter-category').value;
    const increment = parseInt(document.getElementById('edit-counter-increment').value) || 1;
    const isPersonal = document.getElementById('edit-counter-personal').checked;
    
    if (!title) {
        alert('Wprowadź nazwę licznika');
        return;
    }
    
    if (!categoryId) {
        alert('Wybierz kategorię');
        return;
    }

    fetch('ajax_handler.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: `action=update_counter&counter_id=${selectedCounterId}&title=${encodeURIComponent(title)}&category_id=${categoryId}&increment=${increment}&is_personal=${isPersonal ? 1 : 0}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closeAllModals();
            loadCounterData();
            selectedCounterId = null;
        } else {
            alert('Błąd aktualizacji licznika: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Błąd:', error);
        alert('Błąd sieciowy');
    });
}

// Usuwanie licznika
function deleteCounter(counterId) {
    deleteCounterId = counterId;
    const counter = currentCounters.find(c => c.id == counterId);
    document.getElementById('delete-counter-name').textContent = counter ? counter.title : 'licznik';
    document.getElementById('delete-counter-modal').classList.remove('hidden');
}

function confirmDeleteCounter() {
    if (!deleteCounterId) return;

    fetch('ajax_handler.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: `action=delete_counter&counter_id=${deleteCounterId}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closeAllModals();
            loadCounterData();
            deleteCounterId = null;
        } else {
            alert('Błąd usuwania licznika: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Błąd:', error);
        alert('Błąd sieciowy');
    });
}

// ============= FUNKCJE KPI =============

// Nowy cel KPI
function showNewKpiModal() {
    document.getElementById('new-kpi-modal').classList.remove('hidden');
    document.getElementById('new-kpi-name').value = '';
    document.getElementById('new-kpi-total-goal').value = '';
    document.getElementById('new-kpi-daily-goal').value = '';
    populateKpiCountersList('new-kpi-counters');
}

function populateKpiCountersList(containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;

    let html = '';
    currentCounters.forEach(counter => {
        const categoryName = window.appData.categories.find(cat => cat.id == counter.category_id)?.name || 'Bez kategorii';
        html += `
            <label class="flex items-center p-2 hover:bg-slate-700 rounded">
                <input type="checkbox" value="${counter.id}" class="mr-2">
                <span>${counter.title} (${categoryName})</span>
            </label>
        `;
    });
    
    container.innerHTML = html;
}

function saveNewKpi() {
    const name = document.getElementById('new-kpi-name').value.trim();
    const totalGoal = parseInt(document.getElementById('new-kpi-total-goal').value) || 0;
    const dailyGoal = parseInt(document.getElementById('new-kpi-daily-goal').value) || 0;
    
    const selectedCounters = [];
    document.querySelectorAll('#new-kpi-counters input:checked').forEach(checkbox => {
        selectedCounters.push(checkbox.value);
    });
    
    if (!name) {
        alert('Wprowadź nazwę celu KPI');
        return;
    }
    
    if (totalGoal <= 0) {
        alert('Wprowadź cel miesięczny większy od 0');
        return;
    }

    fetch('ajax_handler.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: `action=create_kpi_goal&name=${encodeURIComponent(name)}&total_goal=${totalGoal}&daily_goal=${dailyGoal}&linked_counters=${JSON.stringify(selectedCounters)}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closeAllModals();
            loadKpiData();
        } else {
            alert('Błąd tworzenia celu KPI: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Błąd:', error);
        alert('Błąd sieciowy');
    });
}

// Edycja celu KPI
function editKpiGoal(goalId) {
    const goal = currentKpiGoals.find(g => g.id == goalId);
    if (!goal) return;

    document.getElementById('edit-kpi-name').value = goal.name;
    document.getElementById('edit-kpi-total-goal').value = goal.total_goal;
    document.getElementById('edit-kpi-daily-goal').value = goal.daily_goal || '';
    
    populateKpiCountersList('edit-kpi-counters');
    
    // Zaznacz powiązane liczniki
    setTimeout(() => {
        const linkedIds = goal.linked_counter_ids || [];
        document.querySelectorAll('#edit-kpi-counters input[type="checkbox"]').forEach(checkbox => {
            checkbox.checked = linkedIds.includes(checkbox.value);
        });
    }, 100);
    
    selectedKpiGoalId = goalId;
    document.getElementById('edit-kpi-modal').classList.remove('hidden');
}

function saveEditKpi() {
    if (!selectedKpiGoalId) return;

    const name = document.getElementById('edit-kpi-name').value.trim();
    const totalGoal = parseInt(document.getElementById('edit-kpi-total-goal').value) || 0;
    const dailyGoal = parseInt(document.getElementById('edit-kpi-daily-goal').value) || 0;
    
    const selectedCounters = [];
    document.querySelectorAll('#edit-kpi-counters input:checked').forEach(checkbox => {
        selectedCounters.push(checkbox.value);
    });
    
    if (!name) {
        alert('Wprowadź nazwę celu KPI');
        return;
    }
    
    if (totalGoal <= 0) {
        alert('Wprowadź cel miesięczny większy od 0');
        return;
    }

    fetch('ajax_handler.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: `action=update_kpi_goal&goal_id=${selectedKpiGoalId}&name=${encodeURIComponent(name)}&total_goal=${totalGoal}&daily_goal=${dailyGoal}&linked_counters=${JSON.stringify(selectedCounters)}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            closeAllModals();
            loadKpiData();
            selectedKpiGoalId = null;
        } else {
            alert('Błąd aktualizacji celu KPI: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Błąd:', error);
        alert('Błąd sieciowy');
    });
}

// Usuwanie celu KPI
function deleteKpiGoal(goalId) {
    const goal = currentKpiGoals.find(g => g.id == goalId);
    if (!goal) return;

    if (confirm(`Czy na pewno chcesz usunąć cel KPI "${goal.name}"?`)) {
        fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: `action=delete_kpi_goal&goal_id=${goalId}`
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                loadKpiData();
            } else {
                alert('Błąd usuwania celu KPI: ' + data.message);
            }
        })
        .catch(error => {
            console.error('Błąd:', error);
            alert('Błąd sieciowy');
        });
    }
}

// Zamknij wszystkie modale
function closeAllModals() {
    document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.classList.add('hidden');
    });
    selectedCounterId = null;
    deleteCounterId = null;
}

// Otwórz ustawienia licznika
function openCounterSettings(counterId) {
    const settingsMenu = document.getElementById('counter-settings-menu');
    const button = event.target.closest('button');
    
    // Ustaw pozycję menu
    const rect = button.getBoundingClientRect();
    settingsMenu.style.top = rect.bottom + 'px';
    settingsMenu.style.left = rect.left + 'px';
    
    // Zapisz ID licznika
    settingsMenu.dataset.counterId = counterId;
    
    // Pokaż menu
    settingsMenu.classList.remove('hidden');
    
    // Zamknij menu po kliknięciu poza nim
    setTimeout(() => {
        document.addEventListener('click', closeSettingsMenu);
    }, 10);
}

function closeSettingsMenu() {
    document.getElementById('counter-settings-menu').classList.add('hidden');
    document.removeEventListener('click', closeSettingsMenu);
}

function settingsEditCounter() {
    const counterId = document.getElementById('counter-settings-menu').dataset.counterId;
    closeSettingsMenu();
    editCounter(parseInt(counterId));
}

function settingsDeleteCounter() {
    const counterId = document.getElementById('counter-settings-menu').dataset.counterId;
    closeSettingsMenu();
    deleteCounter(parseInt(counterId));
}

// Otwórz widok publiczny
function openPublicView() {
    const sfid = window.appData.currentSfid;
    window.open(`/modules/licznik2/public.php?sfid=${sfid}`, '_blank');
}

// Eksport danych
function exportData() {
    const month = document.getElementById('kpi-month-selector').value;
    window.open(`ajax_handler.php?action=export_data&month=${month}`, '_blank');
}

// Zamknij menu kategorii przy kliknięciu poza nim
document.addEventListener('click', function(e) {
    const dropdown = document.getElementById('category-dropdown-container');
    const menu = document.getElementById('category-menu');
    
    if (!dropdown.contains(e.target) && menu.classList.contains('show')) {
        menu.classList.remove('show');
    }
});

// Dodaj zmienne globalne dla ID
let selectedKpiGoalId = null;
