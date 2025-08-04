// Globalne zmienne
let currentCounters = [];
let currentKpiGoals = [];
let selectedCounterId = null;
let currentView = localStorage.getItem('licznik_view') || 'grid';
let currentCategory = localStorage.getItem('licznik_category') || 'all';
let deleteCounterId = null;
let isToday = true;

// Inicjalizacja po załadowaniu DOM
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
    setupKeyboardNavigation();
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

// Konfiguracja event listenerów
function setupEventListeners() {
    // User selector
    const userSelector = document.getElementById('user-selector');
    if (userSelector) {
        userSelector.addEventListener('change', function() {
            loadCounterData();
        });
    }

    // Date selector
    const dateSelector = document.getElementById('date-selector');
    if (dateSelector) {
        dateSelector.addEventListener('change', function() {
            loadCounterData();
        });
    }

    // KPI month selector
    const kpiMonthSelector = document.getElementById('kpi-month-selector');
    if (kpiMonthSelector) {
        kpiMonthSelector.addEventListener('change', function() {
            loadKpiData();
        });
    }

    // Close modals on outside click
    document.addEventListener('click', function(e) {
        if (e.target.classList.contains('modal-overlay')) {
            closeAllModals();
        }
    });
}

// Nawigacja klawiaturą
function setupKeyboardNavigation() {
    document.addEventListener('keydown', function(e) {
        // ESC - zamknij modały
        if (e.key === 'Escape') {
            closeAllModals();
            return;
        }

        // Jeśli modal jest otwarty, nie obsługuj innych skrótów
        if (document.querySelector('.modal-overlay:not(.hidden)')) {
            return;
        }

        switch(e.key.toLowerCase()) {
            case 'v':
                e.preventDefault();
                toggleView();
                break;
            case 'k':
                e.preventDefault();
                cycleThroughCategories();
                break;
            case 'u':
                if (selectedCounterId) {
                    e.preventDefault();
                    openEditCounterModal(selectedCounterId);
                }
                break;
            case 'd':
                if (selectedCounterId && window.appData.isAdmin) {
                    e.preventDefault();
                    openDeleteModal(selectedCounterId);
                }
                break;
            case 'arrowup':
            case 'arrowdown':
                e.preventDefault();
                navigateCounters(e.key === 'ArrowUp' ? -1 : 1);
                break;
            case 'arrowleft':
            case '-':
                if (selectedCounterId) {
                    e.preventDefault();
                    adjustCounterValue(selectedCounterId, -1);
                }
                break;
            case 'arrowright':
            case '+':
                if (selectedCounterId) {
                    e.preventDefault();
                    adjustCounterValue(selectedCounterId, 1);
                }
                break;
            case 'i':
                if (selectedCounterId) {
                    e.preventDefault();
                    openAddAmountModal(selectedCounterId);
                }
                break;
        }
    });
}

// Ładowanie danych liczników
async function loadCounterData() {
    const userId = document.getElementById('user-selector').value;
    const date = document.getElementById('date-selector').value;
    const today = new Date().toISOString().split('T')[0];
    isToday = date === today;

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'get_counter_data',
                user_id: userId,
                date: date
            })
        });

        const data = await response.json();

        if (data.success) {
            currentCounters = data.data;
            renderCounters();
        } else {
            console.error('Błąd ładowania liczników:', data.message);
            showNotification('Błąd ładowania liczników: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// Renderowanie liczników
function renderCounters() {
    const gridContainer = document.getElementById('counters-grid');
    const listContainer = document.getElementById('counters-list');
    if (!gridContainer || !listContainer) return;

    // Filtruj liczniki według kategorii
    let filteredCounters = currentCounters;
    if (currentCategory !== 'all') {
        filteredCounters = currentCounters.filter(counter =>
            counter.category_id == currentCategory
        );
    }

    // Wyczyść oba kontenery
    gridContainer.innerHTML = '';
    listContainer.innerHTML = '';

    // Renderuj w obu widokach
    filteredCounters.forEach((counter, index) => {
        // Siatka - używaj istniejącej funkcji
        const gridCard = createCounterCard(counter, index, 'grid');
        gridContainer.appendChild(gridCard);

        // Lista - stwórz wersję listową
        const listCard = createCounterCard(counter, index, 'list');
        listContainer.appendChild(listCard);
    });

    // Zaznacz pierwszy licznik jeśli żaden nie jest zaznaczony
    if (filteredCounters.length > 0 && !selectedCounterId) {
        selectCounter(filteredCounters[0].id);
    }

    // Opóźnij ładowanie celów dziennych
    setTimeout(() => {
        updateDailyGoalsDisplay();
    }, 100);
}

// Tworzenie karty licznika
function createCounterCard(counter, index, viewType = 'grid') {
    const card = document.createElement('div');
    const baseClasses = 'counter-card cursor-pointer';
    const listClasses = viewType === 'list' ? ' counter-card-list flex items-center p-4' : '';
    card.className = baseClasses + listClasses;
    card.dataset.counterId = counter.id;
    card.dataset.viewType = viewType;
    card.style.borderLeftColor = counter.color || '#374151';

    // Obsługa liczników walutowych
    const currencySymbol = counter.type === 'currency' && counter.symbol ?
        `<span class="currency-symbol">${counter.symbol}</span>` : '';

    const controlsDisabled = !isToday;
    const controlsOpacity = controlsDisabled ? 'opacity-50 pointer-events-none' : '';

    if (viewType === 'list') {
        card.innerHTML = `
            <div class="flex-1 grid grid-cols-6 gap-4 items-center">
                <div class="col-span-2">
                    <h3 class="counter-title text-lg">${escapeHtml(counter.title)}</h3>
                    <div class="daily-goals-container-list text-xs text-gray-400" id="daily-goals-${counter.id}-list">
                        <!-- Cele dzienne będą załadowane później -->
                    </div>
                </div>
                <div class="text-center">
                    <span class="counter-value text-xl font-bold" id="counter-value-${counter.id}-list">${counter.value}${currencySymbol}</span>
                </div>
                <div class="text-center text-sm text-gray-400">
                    <div class="daily-goals-summary-list" id="daily-goals-summary-${counter.id}-list">
                        <!-- Podsumowanie celów -->
                    </div>
                </div>
                <div class="flex gap-2 ${controlsOpacity}">
                    <button class="counter-btn minus w-8 h-8 flex items-center justify-center" onclick="adjustCounterValue(${counter.id}, -1)" title="Zmniejsz" ${controlsDisabled ? 'disabled' : ''}>
                        <i class="fas fa-minus text-xs"></i>
                    </button>
                    <button class="counter-btn plus w-8 h-8 flex items-center justify-center" onclick="adjustCounterValue(${counter.id}, 1)" title="Zwiększ" ${controlsDisabled ? 'disabled' : ''}>
                        <i class="fas fa-plus text-xs"></i>
                    </button>
                </div>
                <div class="text-right relative">
                    <button onclick="toggleCounterMenu(${counter.id}, 'list')" class="text-gray-400 hover:text-white" title="Menu">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <div id="counter-menu-${counter.id}-list" class="counter-menu hidden">
                        <button onclick="openAddAmountModal(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Dodaj ilość</button>
                        <button onclick="openSetValueModal(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Ustaw licznik na</button>
                        <div class="border-t border-slate-600 my-1"></div>
                        <button onclick="openEditCounterModal(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Ustawienia (U)</button>
                        ${window.appData.isAdmin ? `
                        <button onclick="openDeleteModal(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-red-400 hover:bg-slate-700">Usuń (D)</button>
                        ` : ''}
                    </div>
                </div>
            </div>
        `;
    } else {
        card.innerHTML = `
            <div class="counter-header">
                <div class="flex justify-between items-start mb-2">
                    <div class="flex-1">
                        <h3 class="counter-title">${escapeHtml(counter.title)}</h3>
                        <div class="daily-goals-container text-xs text-gray-400 mt-1" id="daily-goals-${counter.id}">
                            <!-- Cele dzienne będą załadowane później -->
                        </div>
                    </div>
                    <div class="relative">
                        <button onclick="toggleCounterMenu(${counter.id})" class="text-gray-400 hover:text-white" title="Menu">
                            <i class="fas fa-ellipsis-v"></i>
                        </button>
                        <div id="counter-menu-${counter.id}" class="counter-menu hidden">
                            <button onclick="openAddAmountModal(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Dodaj ilość</button>
                            <button onclick="openSetValueModal(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Ustaw licznik na</button>
                            <div class="border-t border-slate-600 my-1"></div>
                            <button onclick="openEditCounterModal(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Ustawienia (U)</button>
                            ${window.appData.isAdmin ? `
                            <button onclick="openDeleteModal(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-red-400 hover:bg-slate-700">Usuń (D)</button>
                            ` : ''}
                        </div>
                    </div>
                </div>
            </div>

            <div class="counter-value" id="counter-value-${counter.id}">${counter.value}${currencySymbol}</div>

            <div class="counter-controls ${controlsOpacity}">
                <button class="counter-btn minus" onclick="adjustCounterValue(${counter.id}, -1)" title="Zmniejsz (←/-)"  ${controlsDisabled ? 'disabled' : ''}>
                    <i class="fas fa-minus"></i>
                </button>
                <button class="counter-btn plus" onclick="adjustCounterValue(${counter.id}, 1)" title="Zwiększ (→/+)"  ${controlsDisabled ? 'disabled' : ''}>
                    <i class="fas fa-plus"></i>
                </button>
            </div>
        `;
    }

    // Event listener dla zaznaczania
    card.addEventListener('click', function(e) {
        // Nie zaznaczaj jeśli kliknięto przycisk
        if (e.target.closest('button')) return;
        selectCounter(counter.id);
    });

    return card;
}

// Znajdź cel dzienny dla licznika z uwzględnieniem zespołowej realizacji
function getDailyGoalForCounter(counterId) {
    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return 0;

    // Znajdź wszystkie KPI cele które zawierają ten licznik
    const matchingKpiGoals = currentKpiGoals.filter(kpiGoal => {
        const linkedIds = kpiGoal.linked_counter_ids || [];
        return linkedIds.includes(counterId.toString()) || linkedIds.includes(counterId);
    });

    if (matchingKpiGoals.length === 0) return 0;

    // Jeśli jest więcej niż jeden cel, wybierz ten z najmniejszą liczbą powiązanych liczników
    // (priorytet dla celów pojedynczych nad zespołowymi)
    let selectedKpiGoal = matchingKpiGoals[0];
    
    if (matchingKpiGoals.length > 1) {
        selectedKpiGoal = matchingKpiGoals.reduce((prev, current) => {
            const prevLinkedCount = (prev.linked_counter_ids || []).length;
            const currentLinkedCount = (current.linked_counter_ids || []).length;
            return currentLinkedCount < prevLinkedCount ? current : prev;
        });
    }

    // Używamy dynamicznego celu dziennego z serwera (uwzględnia zespołową realizację)
    const dynamicDailyGoal = selectedKpiGoal.daily_goal || 0;

    // Oblicz realizację użytkownika dla tego licznika
    const currentUserValue = parseInt(counter.value) || 0;

    // Cel dla użytkownika = dynamiczny cel dzienny / liczba aktywnych użytkowników
    const activeUsersCount = window.appData.users ? window.appData.users.length : 1;
    const userDailyGoal = Math.ceil(dynamicDailyGoal / activeUsersCount);

    const remaining = Math.max(0, userDailyGoal - currentUserValue);

    return { 
        total: userDailyGoal, 
        remaining: remaining, 
        current: currentUserValue,
        teamDaily: dynamicDailyGoal, // cel całego zespołu
        kpiName: selectedKpiGoal.name // nazwa wybranego KPI dla debugowania
    };
}

// Zaznaczanie licznika
function selectCounter(counterId) {
    // Usuń poprzednie zaznaczenie z obu widoków
    document.querySelectorAll('.counter-card').forEach(card => {
        card.classList.remove('selected');
    });

    // Zaznacz nowy w obu widokach
    document.querySelectorAll(`[data-counter-id="${counterId}"]`).forEach(card => {
        card.classList.add('selected');
    });

    selectedCounterId = counterId;
}

// Aktualizuj zaznaczenie w aktualnym widoku
function updateCounterSelection() {
    if (selectedCounterId) {
        selectCounter(selectedCounterId);
    }
}

// Nawigacja między licznikami
function navigateCounters(direction) {
    const cards = document.querySelectorAll('.counter-card');
    if (cards.length === 0) return;

    let currentIndex = -1;
    if (selectedCounterId) {
        cards.forEach((card, index) => {
            if (card.dataset.counterId == selectedCounterId) {
                currentIndex = index;
            }
        });
    }

    let newIndex = currentIndex + direction;
    if (newIndex < 0) newIndex = cards.length - 1;
    if (newIndex >= cards.length) newIndex = 0;

    const newCounterId = cards[newIndex].dataset.counterId;
    selectCounter(newCounterId);
}

// Zmiana wartości licznika
async function adjustCounterValue(counterId, direction) {
    if (!isToday) {
        showNotification('Można edytować wartości tylko dla dzisiejszej daty', 'warning');
        return;
    }

    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return;

    const increment = counter.increment || 1;
    const change = direction * increment;
    const newValue = parseInt(counter.value) + change; // Usuń ograniczenie Math.max(0, ...)

    // Natychmiastowa aktualizacja UI w obu widokach
    const valueElement = document.getElementById(`counter-value-${counterId}`);
    const valueElementList = document.getElementById(`counter-value-${counterId}-list`);
    
    const currencySymbol = counter.type === 'currency' && counter.symbol ? counter.symbol : '';
    const displayValue = newValue + currencySymbol;
    
    if (valueElement) {
        valueElement.innerHTML = displayValue;
    }
    if (valueElementList) {
        valueElementList.innerHTML = displayValue;
    }

    // Aktualizuj w pamięci
    counter.value = newValue;

    try {
        const userId = document.getElementById('user-selector').value;
        const date = document.getElementById('date-selector').value;

        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'save_counter_value',
                counter_id: counterId,
                user_id: userId,
                date: date,
                value: newValue
            })
        });

        const data = await response.json();

        if (!data.success) {
            // Przywróć poprzednią wartość w przypadku błędu
            counter.value = newValue - change;
            if (valueElement) {
                valueElement.textContent = counter.value;
            }
            showNotification('Błąd zapisywania: ' + data.message, 'error');
        } else {
            // Odśwież dane KPI po zmianie wartości
            loadKpiData();
            // Odśwież cele dzienne dla wszystkich liczników
            updateDailyGoalsDisplay();
        }
    } catch (error) {
        // Przywróć poprzednią wartość w przypadku błędu
        counter.value = newValue - change;
        if (valueElement) {
            valueElement.textContent = counter.value;
        }
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// === FUNKCJE MODALI - SEPARACJA EDYCJI OD DODAWANIA ===

// Otwórz modal dodawania nowego licznika
function openAddCounterModal() {
    const modal = document.getElementById('add-counter-modal');
    if (!modal) return;

    // Wyczyść formularz
    document.getElementById('new-counter-name').value = '';
    document.getElementById('new-counter-increment').value = '1';
    document.getElementById('new-counter-category').value = '';

    showModal(modal);
}

// Otwórz modal edycji licznika
function openEditCounterModal(counterId) {
    const modal = document.getElementById('settings-modal');
    if (!modal) return;

    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return;

    // Wypełnij formularz danymi licznika
    document.getElementById('edit-counter-id').value = counter.id;
    document.getElementById('edit-counter-name').value = counter.title;
    document.getElementById('edit-counter-increment').value = counter.increment || 1;
    document.getElementById('edit-counter-category').value = counter.category_id || '';
    document.getElementById('edit-counter-color').value = counter.color || '#374151';
    document.getElementById('edit-counter-is-currency').checked = counter.type === 'currency';
    document.getElementById('edit-counter-symbol').value = counter.symbol || '';

    showModal(modal);
}

// Zapisz ustawienia licznika (edycja)
async function saveCounterSettings() {
    const counterId = document.getElementById('edit-counter-id').value;
    const title = document.getElementById('edit-counter-name').value.trim();
    const increment = document.getElementById('edit-counter-increment').value;
    const categoryId = document.getElementById('edit-counter-category').value;
    const color = document.getElementById('edit-counter-color').value;
    // Obsługa typu walutowego
    const isCurrency = document.getElementById('edit-counter-is-currency')?.checked || false;
    const symbol = document.getElementById('edit-counter-symbol')?.value.trim() || '';

    if (!title) {
        showNotification('Nazwa licznika jest wymagana', 'error');
        return;
    }

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'save_counter_settings',
                id: counterId,
                title: title,
                increment: increment,
                category_id: categoryId,
                color: color,
                type: isCurrency ? 'currency' : 'number',
                symbol: isCurrency ? symbol : null
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Ustawienia zapisane pomyślnie', 'success');
            closeAllModals();
            loadCounterData(); // Odśwież dane
        } else {
            showNotification('Błąd zapisywania: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// Dodaj nowy licznik
async function addNewCounter() {
    const title = document.getElementById('new-counter-name').value.trim();
    const increment = document.getElementById('new-counter-increment').value;
    const categoryId = document.getElementById('new-counter-category').value;
    // Obsługa typu walutowego
    const isCurrency = document.getElementById('new-counter-is-currency')?.checked || false;
    const symbol = document.getElementById('new-counter-symbol')?.value.trim() || '';

    if (!title) {
        showNotification('Nazwa licznika jest wymagana', 'error');
        return;
    }

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'save_counter_settings',
                title: title,
                increment: increment,
                category_id: categoryId,
                color: '#374151',
                type: isCurrency ? 'currency' : 'number',
                symbol: isCurrency ? symbol : null
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Licznik dodany pomyślnie', 'success');
            closeAllModals();
            loadCounterData(); // Odśwież dane
        } else {
            showNotification('Błąd dodawania: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// Otwórz modal usuwania
function openDeleteModal(counterId) {
    deleteCounterId = counterId;
    const modal = document.getElementById('delete-confirm-modal');
    if (modal) {
        showModal(modal);
    }
}

// Potwierdź usunięcie
async function confirmDeletion() {
    if (!deleteCounterId) return;

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'delete_counter',
                counter_id: deleteCounterId
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Licznik usunięty pomyślnie', 'success');
            closeAllModals();
            loadCounterData(); // Odśwież dane
            deleteCounterId = null;
        } else {
            showNotification('Błąd usuwania: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// === FUNKCJE KPI ===

// Ładowanie danych KPI
async function loadKpiData() {
    const month = document.getElementById('kpi-month-selector').value;

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'get_kpi_data',
                month: month
            })
        });

        const data = await response.json();

        if (data.success) {
            currentKpiGoals = data.data;
            renderKpiTable();
        } else {
            console.error('Błąd ładowania KPI:', data.message);
        }
    } catch (error) {
        console.error('Błąd AJAX KPI:', error);
    }
}

// Renderowanie tabeli KPI
function renderKpiTable() {
    const tbody = document.getElementById('kpi-table-body');
    if (!tbody) return;

    tbody.innerHTML = '';

    // Sortuj cele KPI po ID od najmniejszej do większej wartości
    currentKpiGoals.sort((a, b) => a.id - b.id);

    currentKpiGoals.forEach(goal => {
        const row = document.createElement('tr');
        row.className = 'border-b border-slate-700 hover:bg-slate-800';

        row.innerHTML = `
            <td class="px-6 py-4 font-medium text-white">${escapeHtml(goal.name)}</td>
            <td class="px-6 py-4 text-right font-mono">${goal.realization}</td>
            <td class="px-6 py-4 text-right font-mono text-blue-400">${goal.daily_goal}</td>
            <td class="px-6 py-4 text-right font-mono">${goal.total_goal}</td>
            <td class="px-6 py-4">
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${goal.progress_percent}%"></div>
                </div>
                <div class="text-xs text-gray-400 mt-1">${Math.round(goal.progress_percent)}%</div>
            </td>
            <td class="px-6 py-4 text-right">
                ${window.appData.isAdmin ? `
                <button onclick="openEditKpiModal(${goal.id})" class="text-blue-400 hover:text-blue-300 mr-2" title="Edytuj">
                    <i class="fas fa-edit"></i>
                </button>
                <button onclick="deleteKpiGoal(${goal.id})" class="text-red-400 hover:text-red-300" title="Usuń">
                    <i class="fas fa-trash"></i>
                </button>
                ` : ''}
            </td>
        `;

        tbody.appendChild(row);
    });
}

// Otwórz modal dodawania KPI
function openAddKpiModal() {
    const modal = document.getElementById('kpi-goal-modal');
    if (!modal) return;

    // Wyczyść formularz
    document.getElementById('kpi-goal-id').value = '';
    document.getElementById('kpi-goal-name').value = '';
    document.getElementById('kpi-total-goal').value = '';
    document.getElementById('kpi-modal-title').textContent = 'Dodaj Cel Zespołowy';

    populateKpiCounters();
    showModal(modal);
}

// Otwórz modal edycji KPI
function openEditKpiModal(goalId) {
    const modal = document.getElementById('kpi-goal-modal');
    if (!modal) return;

    const goal = currentKpiGoals.find(g => g.id == goalId);
    if (!goal) return;

    // Wypełnij formularz
    document.getElementById('kpi-goal-id').value = goal.id;
    document.getElementById('kpi-goal-name').value = goal.name;
    document.getElementById('kpi-total-goal').value = goal.total_goal;
    document.getElementById('kpi-modal-title').textContent = 'Edytuj Cel Zespołowy';

    populateKpiCounters(goal.linked_counter_ids);
    showModal(modal);
}

// Wypełnij checkboxy liczników w KPI
function populateKpiCounters(selectedIds = []) {
    const container = document.getElementById('kpi-linked-counters');
    if (!container) return;

    container.innerHTML = '';

    currentCounters.forEach(counter => {
        const isChecked = selectedIds.includes(counter.id.toString()) || selectedIds.includes(counter.id);

        const div = document.createElement('div');
        div.className = 'flex items-center';
        div.innerHTML = `
            <input type="checkbox" id="counter-${counter.id}" value="${counter.id}" ${isChecked ? 'checked' : ''}
                   class="mr-2 rounded border-gray-600 bg-gray-700 text-green-600">
            <label for="counter-${counter.id}" class="text-sm text-gray-300">${escapeHtml(counter.title)}</label>
        `;

        container.appendChild(div);
    });
}

// Zapisz cel KPI
async function saveKpiGoal() {
    const goalId = document.getElementById('kpi-goal-id').value;
    const name = document.getElementById('kpi-goal-name').value.trim();
    const totalGoal = document.getElementById('kpi-total-goal').value;

    // Pobierz zaznaczone liczniki
    const linkedCounterIds = [];
    document.querySelectorAll('#kpi-linked-counters input[type="checkbox"]:checked').forEach(checkbox => {
        linkedCounterIds.push(checkbox.value);
    });

    if (!name) {
        showNotification('Nazwa celu jest wymagana', 'error');
        return;
    }

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'save_kpi_goal',
                id: goalId,
                name: name,
                total_goal: totalGoal,
                linked_counter_ids: JSON.stringify(linkedCounterIds)
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Cel KPI zapisany pomyślnie', 'success');
            closeAllModals();
            loadKpiData(); // Odśwież dane
        } else {
            showNotification('Błąd zapisywania KPI: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// Usuń cel KPI
async function deleteKpiGoal(goalId) {
    if (!confirm('Czy na pewno chcesz usunąć ten cel KPI?')) return;

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'delete_kpi_goal',
                goal_id: goalId
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Cel KPI usunięty pomyślnie', 'success');
            loadKpiData(); // Odśwież dane
        } else {
            showNotification('Błąd usuwania KPI: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// === FUNKCJE KATEGORII ===

// Otwórz modal dodawania kategorii
function openAddCategoryModal() {
    const modal = document.getElementById('add-category-modal');
    if (!modal) return;

    // Wyczyść formularz
    document.getElementById('new-category-name').value = '';

    showModal(modal);
}

// Dodaj nową kategorię
async function addNewCategory() {
    const name = document.getElementById('new-category-name').value.trim();

    if (!name) {
        showNotification('Nazwa kategorii jest wymagana', 'error');
        return;
    }

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'add_category',
                name: name
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Kategoria dodana pomyślnie', 'success');
            closeAllModals();
            // Odśwież dane kategorii
            window.appData.categories.push({id: data.category_id, name: name});
            populateCategoryDropdown();
            populateModalCategories();
        } else {
            showNotification('Błąd dodawania kategorii: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// Wypełnij dropdown kategorii
function populateCategoryDropdown() {
    const menu = document.getElementById('category-menu');
    if (!menu) return;

    menu.innerHTML = `
        <div class="category-menu-item" onclick="selectCategory('all', 'Wszystkie Kategorie')">
            Wszystkie Kategorie
        </div>
    `;

    // Pokaż tylko kategorie które mają aktywne liczniki
    window.appData.categories.forEach(category => {
        const hasActiveCounters = currentCounters.some(counter => 
            counter.category_id == category.id
        );
        
        if (hasActiveCounters) {
            const item = document.createElement('div');
            item.className = 'category-menu-item';
            item.onclick = () => selectCategory(category.id, category.name);
            item.textContent = category.name;
            menu.appendChild(item);
        }
    });

    if (window.appData.isAdmin) {
        const addItem = document.createElement('div');
        addItem.className = 'category-menu-item border-t border-slate-600';
        addItem.onclick = () => openAddCategoryModal();
        addItem.innerHTML = '<i class="fas fa-plus mr-2"></i>Dodaj kategorię';
        menu.appendChild(addItem);
    }
}

// Wypełnij kategorie w modalach
function populateModalCategories() {
    const selects = ['edit-counter-category', 'new-counter-category'];

    selects.forEach(selectId => {
        const select = document.getElementById(selectId);
        if (!select) return;

        select.innerHTML = '<option value="">Bez kategorii</option>';

        window.appData.categories.forEach(category => {
            const option = document.createElement('option');
            option.value = category.id;
            option.textContent = category.name;
            select.appendChild(option);
        });
    });
}

// Przełącz menu kategorii
function toggleCategoryMenu() {
    const menu = document.getElementById('category-menu');
    if (!menu) return;

    menu.classList.toggle('show');
}

// Wybierz kategorię
function selectCategory(categoryId, categoryName) {
    currentCategory = categoryId;
    localStorage.setItem('licznik_category', categoryId);
    localStorage.setItem('licznik_category_name', categoryName);
    document.getElementById('current-category-name').textContent = categoryName;
    document.getElementById('category-menu').classList.remove('show');
    renderCounters();
}

// === FUNKCJE POMOCNICZE ===

// Pokaż modal
function showModal(modal) {
    modal.classList.remove('hidden');
    // Dodaj małe opóźnienie dla animacji
    setTimeout(() => {
        modal.querySelector('.modal-content').style.transform = 'scale(1)';
        modal.querySelector('.modal-content').style.opacity = '1';
    }, 10);
}

// Zamknij wszystkie modale
function closeAllModals() {
    document.querySelectorAll('.modal-overlay').forEach(modal => {
        const content = modal.querySelector('.modal-content');
        if (content) {
            content.style.transform = 'scale(0.95)';
            content.style.opacity = '0';
        }
        setTimeout(() => {
            modal.classList.add('hidden');
        }, 200);
    });
}

// Zmień widok
function changeView(view) {
    currentView = view;
    localStorage.setItem('licznik_view', view);

    const container = document.getElementById('counters-container');
    const gridContainer = document.getElementById('counters-grid');
    const listContainer = document.getElementById('counters-list');

    if (view === 'list') {
        container.classList.remove('grid-view');
        container.classList.add('list-view');
        gridContainer.classList.add('hidden');
        listContainer.classList.remove('hidden');
        listContainer.className = 'space-y-2';
    } else {
        container.classList.remove('list-view');
        container.classList.add('grid-view');
        listContainer.classList.add('hidden');
        gridContainer.classList.remove('hidden');
        // 4 kolumny na desktop (lg breakpoint)
        gridContainer.className = 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6';
    }

    // Aktualizuj przyciski
    document.getElementById('grid-view-btn').classList.toggle('bg-gray-500', view === 'grid');
    document.getElementById('grid-view-btn').classList.toggle('text-white', view === 'grid');
    document.getElementById('grid-view-btn').classList.toggle('text-gray-300', view !== 'grid');

    document.getElementById('list-view-btn').classList.toggle('bg-gray-500', view === 'list');
    document.getElementById('list-view-btn').classList.toggle('text-white', view === 'list');
    document.getElementById('list-view-btn').classList.toggle('text-gray-300', view !== 'list');

    // Nie renderuj ponownie, tylko pokaż odpowiedni kontener
    updateCounterSelection();
}

// Przełącz widok
function toggleView() {
    changeView(currentView === 'grid' ? 'list' : 'grid');
}

// Przełącz kategorie w pętli
function cycleThroughCategories() {
    // Filtruj kategorie tylko do tych które mają aktywne liczniki
    const categoriesWithCounters = ['all'];
    const categoryNamesWithCounters = ['Wszystkie Kategorie'];

    // Sprawdź które kategorie mają aktywne liczniki
    window.appData.categories.forEach(category => {
        const hasActiveCounters = currentCounters.some(counter => 
            counter.category_id == category.id
        );
        if (hasActiveCounters) {
            categoriesWithCounters.push(category.id.toString());
            categoryNamesWithCounters.push(category.name);
        }
    });

    if (categoriesWithCounters.length <= 1) return; // Brak kategorii do przełączania

    const currentIndex = categoriesWithCounters.indexOf(currentCategory.toString());
    const nextIndex = (currentIndex + 1) % categoriesWithCounters.length;

    selectCategory(categoriesWithCounters[nextIndex], categoryNamesWithCounters[nextIndex]);
}

// Escape HTML
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Otwórz widok publiczny
function openPublicView() {
    const sfid = window.appData.currentSfid;
    const url = `/modules/licznik2/public.php?sfid=${sfid}`;
    window.open(url, '_blank');
}

// Przełącz menu licznika
function toggleCounterMenu(counterId, viewType = 'grid') {
    // Zamknij wszystkie inne menu
    document.querySelectorAll('[id^="counter-menu-"]').forEach(menu => {
        if (menu.id !== `counter-menu-${counterId}` && menu.id !== `counter-menu-${counterId}-list`) {
            menu.classList.add('hidden');
        }
    });

    // Przełącz obecne menu
    const menuId = viewType === 'list' ? `counter-menu-${counterId}-list` : `counter-menu-${counterId}`;
    const menu = document.getElementById(menuId);
    if (menu) {
        menu.classList.toggle('hidden');
        
        // Ustaw pozycję względem przycisku dla wszystkich widoków
        if (!menu.classList.contains('hidden')) {
            const button = event.target.closest('button');
            if (button) {
                const rect = button.getBoundingClientRect();
                menu.style.position = 'fixed';
                
                // Sprawdź czy menu zmieści się z prawej strony
                const menuWidth = 180; // przewidywana szerokość menu
                if (rect.right + menuWidth > window.innerWidth) {
                    // Umieść z lewej strony przycisku
                    menu.style.left = (rect.left - menuWidth) + 'px';
                } else {
                    // Umieść z prawej strony przycisku
                    menu.style.left = rect.right + 'px';
                }
                
                // Sprawdź czy menu zmieści się poniżej
                const menuHeight = 200; // przewidywana wysokość menu
                if (rect.bottom + menuHeight > window.innerHeight) {
                    // Umieść powyżej przycisku
                    menu.style.top = (rect.top - menuHeight) + 'px';
                } else {
                    // Umieść poniżej przycisku
                    menu.style.top = rect.bottom + 'px';
                }
                
                menu.style.zIndex = '1000';
            }
        }
    }
}

// Otwórz modal dodawania ilości
function openAddAmountModal(counterId) {
    const modal = document.getElementById('add-amount-modal');
    const counter = currentCounters.find(c => c.id == counterId);
    if (!modal || !counter) return;

    // Wypełnij dane
    document.getElementById('add-amount-counter-id').value = counterId;
    document.getElementById('add-amount-title').textContent = `Dodaj ilość do "${counter.title}"`;
    document.getElementById('add-amount-value').value = counter.increment;

    // Zamknij menu (sprawdź oba warianty)
    const gridMenu = document.getElementById(`counter-menu-${counterId}`);
    const listMenu = document.getElementById(`counter-menu-${counterId}-list`);
    if (gridMenu) gridMenu.classList.add('hidden');
    if (listMenu) listMenu.classList.add('hidden');
    
    showModal(modal);
}

// Otwórz modal ustawiania wartości
function openSetValueModal(counterId) {
    const modal = document.getElementById('set-value-modal');
    const counter = currentCounters.find(c => c.id == counterId);
    if (!modal || !counter) return;

    // Wypełnij dane
    document.getElementById('set-value-counter-id').value = counterId;
    document.getElementById('set-value-title').textContent = `Ustaw "${counter.title}" na`;
    document.getElementById('set-value-input').value = counter.value;

    // Zamknij menu (sprawdź oba warianty)
    const gridMenu = document.getElementById(`counter-menu-${counterId}`);
    const listMenu = document.getElementById(`counter-menu-${counterId}-list`);
    if (gridMenu) gridMenu.classList.add('hidden');
    if (listMenu) listMenu.classList.add('hidden');
    
    showModal(modal);
}

// Zapisz dodaną ilość
async function saveAddAmount() {
    const counterId = document.getElementById('add-amount-counter-id').value;
    const amount = parseInt(document.getElementById('add-amount-value').value);

    if (!isNaN(amount)) {
        adjustCounterValue(counterId, amount);
    }

    closeAllModals();
}

// Zapisz ustawioną wartość
async function saveSetValue() {
    const counterId = document.getElementById('set-value-counter-id').value;
    const newValue = parseInt(document.getElementById('set-value-input').value);
    const counter = currentCounters.find(c => c.id == counterId);

    if (!isNaN(newValue) && counter) {
        const difference = newValue - counter.value;
        adjustCounterValue(counterId, difference);
    }

    closeAllModals();
}

// Pokaż powiadomienie
function showNotification(message, type = 'info') {
    // Usuń poprzednie powiadomienia
    document.querySelectorAll('.notification').forEach(n => n.remove());

    const notification = document.createElement('div');
    notification.className = `notification fixed top-4 right-4 p-4 rounded-lg z-50 ${
        type === 'success' ? 'bg-green-600' :
        type === 'error' ? 'bg-red-600' : 'bg-blue-600'
    } text-white shadow-lg`;
    notification.textContent = message;

    document.body.appendChild(notification);

    // Animacja wejścia
    setTimeout(() => {
        notification.style.transform = 'translateX(0)';
        notification.style.opacity = '1';
    }, 10);

    // Automatyczne usunięcie
    setTimeout(() => {
        notification.style.transform = 'translateX(100%)';
        notification.style.opacity = '0';
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}

// Funkcja do aktualizacji wyświetlania celów dziennych
function updateDailyGoalsDisplay() {
    document.querySelectorAll('.counter-card').forEach(card => {
        const counterId = card.dataset.counterId;
        const counter = currentCounters.find(c => c.id == counterId);
        if (!counter) return;

        const dailyGoal = getDailyGoalForCounter(counter.id);
        const viewType = card.dataset.viewType;

        if (viewType === 'list') {
            const goalContainer = document.getElementById(`daily-goals-${counterId}-list`);
            const goalSummary = document.getElementById(`daily-goals-summary-${counterId}-list`);
            
            if (goalContainer && goalSummary) {
                if (dailyGoal && typeof dailyGoal === 'object') {
                    const personalGoalText = dailyGoal.current >= dailyGoal.total ? 
                        `✅ Osobisty: ${dailyGoal.current}/${dailyGoal.total}` : 
                        `Osobisty: ${dailyGoal.current}/${dailyGoal.total}`;
                    
                    goalContainer.innerHTML = personalGoalText;
                    
                    if (dailyGoal.teamDaily > 0) {
                        goalSummary.innerHTML = `Zespół: ${dailyGoal.teamDaily}`;
                    } else {
                        goalSummary.innerHTML = '';
                    }
                } else {
                    goalContainer.innerHTML = '';
                    goalSummary.innerHTML = '';
                }
            }
        } else {
            const goalContainer = document.getElementById(`daily-goals-${counterId}`);
            
            if (goalContainer) {
                if (dailyGoal && typeof dailyGoal === 'object') {
                    const personalGoalText = dailyGoal.current >= dailyGoal.total ? 
                        `✅ Cel: ${dailyGoal.current}/${dailyGoal.total}` : 
                        `Cel: ${dailyGoal.current}/${dailyGoal.total}`;
                    
                    let goalHtml = `<div class="daily-goal">${personalGoalText}</div>`;
                    
                    if (dailyGoal.teamDaily > 0) {
                        goalHtml += `<div class="daily-goal">Zespół: ${dailyGoal.teamDaily}</div>`;
                    }
                    
                    goalContainer.innerHTML = goalHtml;
                } else {
                    goalContainer.innerHTML = '';
                }
            }
        }
    });
}

// Zamknij menu kategorii i menu liczników przy kliknięciu poza nim
document.addEventListener('click', function(e) {
    const dropdown = document.getElementById('category-dropdown-container');
    const menu = document.getElementById('category-menu');

    if (dropdown && menu && !dropdown.contains(e.target)) {
        menu.classList.remove('show');
    }

    // Zamknij wszystkie menu liczników jeśli kliknięto poza nimi
    document.querySelectorAll('[id^="counter-menu-"]').forEach(counterMenu => {
        if (!counterMenu.contains(e.target) && !e.target.closest('button[onclick*="toggleCounterMenu"]')) {
            counterMenu.classList.add('hidden');
        }
    });
});

function handleDateChange() {
    const dateSelector = document.getElementById('date-selector');
    selectedDate = dateSelector.value;
    const today = new Date().toISOString().split('T')[0];
    isToday = selectedDate === today;
    loadCounterData();
}

// Obsługa skrótów klawiszowych
document.addEventListener('keydown', function(e) {
    if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.tagName === 'SELECT') {
        return;
    }

    const selectedCard = document.querySelector('.counter-card.selected');

    switch(e.key.toLowerCase()) {
        case 'arrowup':
        case 'w':
            e.preventDefault();
            navigateCounters('up');
            break;
        case 'arrowdown':
        case 's':
            e.preventDefault();
            navigateCounters('down');
            break;
        case 'arrowleft':
        case 'a':
            e.preventDefault();
            navigateCounters('left');
            break;
        case 'arrowright':
        case 'd':
            e.preventDefault();
            navigateCounters('right');
            break;
        case ' ':
        case 'enter':
            e.preventDefault();
            if (selectedCard && isToday) {
                const counterId = parseInt(selectedCard.dataset.counterId);
                const counter = currentCounters.find(c => c.id === counterId);
                if (counter) {
                    const increment = parseInt(counter.increment) || 1;
                    adjustCounterValue(counterId, increment);
                }
            }
            break;
        case 'backspace':
        case 'x':
            e.preventDefault();
            if (selectedCard && isToday) {
                const counterId = parseInt(selectedCard.dataset.counterId);
                const counter = currentCounters.find(c => c.id === counterId);
                if (counter) {
                    const increment = parseInt(counter.increment) || 1;
                    adjustCounterValue(counterId, -increment);
                }
            }
            break;
        case 'k':
            e.preventDefault();
            cycleThroughCategories();
            break;
        case 'v':
            e.preventDefault();
            toggleView();
            break;
    }
});

function switchCategory() {
    if (!currentCounters.length) return;

    const categoriesWithCounters = [...new Set(currentCounters.map(c => c.category || 'Bez kategorii'))];

    if (categoriesWithCounters.length <= 1) return;

    const selectedCard = document.querySelector('.counter-card.selected');

    if (!selectedCard) {
        const firstCounter = document.querySelector('.counter-card');
        if (firstCounter) selectCounter(firstCounter.dataset.counterId);
        return;
    }

    const currentCounterId = parseInt(selectedCard.dataset.counterId);
    const currentCounter = currentCounters.find(c => c.id === currentCounterId);
    const currentCategory = currentCounter.category || 'Bez kategorii';

    const currentCategoryIndex = categoriesWithCounters.indexOf(currentCategory);
    const nextCategoryIndex = (currentCategoryIndex + 1) % categoriesWithCounters.length;
    const nextCategory = categoriesWithCounters[nextCategoryIndex];

    const nextCategoryCounter = currentCounters.find(c => (c.category_id || 'Bez kategorii') === nextCategory);
     if (nextCategoryCounter) {
         const nextCard = document.querySelector(`[data-counter-id="${nextCategoryCounter.id}"]`);
         if (nextCard) selectCounter(nextCard.dataset.counterId);
     }
}

function setupViewSwitching() {
    const gridBtn = document.getElementById('grid-view-btn');
    const listBtn = document.getElementById('list-view-btn');
    const container = document.getElementById('counters-container');
    const grid = document.getElementById('counters-grid');

    gridBtn.addEventListener('click', () => {
        changeView('grid');
    });

    listBtn.addEventListener('click', () => {
        changeView('list');
    });
}