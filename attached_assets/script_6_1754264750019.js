
// Globalne zmienne
let currentCounters = [];
let currentKpiGoals = [];
let selectedCounterId = null;
let currentView = localStorage.getItem('licznik_view') || 'grid';
let currentCategory = localStorage.getItem('licznik_category') || 'all';
let deleteCounterId = null;
let currentKpiGoalId = null;
let sortable = null;

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
            closeLargeTileView();
            return;
        }

        // Jeśli modal jest otwarty, nie obsługuj innych skrótów
        if (document.querySelector('.modal-overlay:not(.hidden)')) {
            return;
        }

        // Jeśli Large Tile View jest otwarty
        if (!document.getElementById('large-tile-view').classList.contains('hidden')) {
            if (e.key === 'Escape') {
                closeLargeTileView();
            }
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
            case 'enter':
                if (selectedCounterId) {
                    e.preventDefault();
                    openLargeTileView(selectedCounterId);
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
        }
    });
}

// Ładowanie danych liczników
async function loadCounterData() {
    const userId = document.getElementById('user-selector').value;
    const date = document.getElementById('date-selector').value;

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
            setupDragAndDrop();
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
    const container = document.getElementById('counters-grid');
    if (!container) return;

    // Filtruj liczniki według kategorii
    let filteredCounters = currentCounters;
    if (currentCategory !== 'all') {
        filteredCounters = currentCounters.filter(counter =>
            counter.category_id == currentCategory
        );
    }

    container.innerHTML = '';

    filteredCounters.forEach((counter, index) => {
        const counterCard = createCounterCard(counter, index);
        container.appendChild(counterCard);
    });

    // Zaznacz pierwszy licznik jeśli żaden nie jest zaznaczony
    if (filteredCounters.length > 0 && !selectedCounterId) {
        selectCounter(filteredCounters[0].id);
    }
}

// Tworzenie karty licznika
function createCounterCard(counter, index) {
    const card = document.createElement('div');
    card.className = currentView === 'list' ? 'counter-card-list p-4 cursor-pointer' : 'counter-card p-6 cursor-pointer';
    card.dataset.counterId = counter.id;
    
    if (currentView === 'grid') {
        card.style.borderLeftColor = counter.color || '#374151';
    }

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

    if (currentView === 'list') {
        // Widok listy - kompaktowy
        card.innerHTML = `
            <div class="flex items-center justify-between">
                <div class="flex items-center space-x-4">
                    <div class="w-1 h-12 rounded" style="background-color: ${counter.color || '#374151'}"></div>
                    <div>
                        <h3 class="counter-title text-sm font-semibold">${escapeHtml(counter.title)}</h3>
                        <p class="counter-category text-xs text-gray-400">${escapeHtml(counter.category || 'Bez kategorii')}</p>
                        ${dailyGoalText ? `<div class="daily-goal text-xs">${dailyGoalText}</div>` : ''}
                    </div>
                </div>
                <div class="flex items-center space-x-4">
                    <div class="counter-value-small" id="counter-value-${counter.id}">${counter.value}</div>
                    <div class="counter-controls-small">
                        <button class="counter-btn-small minus" onclick="adjustCounterValue(${counter.id}, -1)" title="Zmniejsz (←/-)">
                            <i class="fas fa-minus"></i>
                        </button>
                        <button class="counter-btn-small plus" onclick="adjustCounterValue(${counter.id}, 1)" title="Zwiększ (→/+)">
                            <i class="fas fa-plus"></i>
                        </button>
                    </div>
                    <div class="relative">
                        <button onclick="toggleCounterMenu(${counter.id})" class="text-gray-400 hover:text-white p-2" title="Menu">
                            <i class="fas fa-ellipsis-v"></i>
                        </button>
                        <div id="counter-menu-${counter.id}" class="hidden absolute right-0 mt-2 w-48 bg-slate-800 border border-slate-700 rounded-md shadow-lg py-1 z-50">
                            <button onclick="openLargeTileView(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Large Tile (ENTER)</button>
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
        `;
    } else {
        // Widok siatki - normalny
        card.innerHTML = `
            <div class="flex justify-between items-start mb-4">
                <div class="flex-1">
                    <h3 class="counter-title mb-1">${escapeHtml(counter.title)}</h3>
                    <p class="counter-category">${escapeHtml(counter.category || 'Bez kategorii')}</p>
                </div>
                <div class="flex space-x-2">
                    <div class="relative">
                        <button onclick="toggleCounterMenu(${counter.id})" class="text-gray-400 hover:text-white" title="Menu">
                            <i class="fas fa-ellipsis-v"></i>
                        </button>
                        <div id="counter-menu-${counter.id}" class="hidden absolute right-0 mt-2 w-48 bg-slate-800 border border-slate-700 rounded-md shadow-lg py-1 z-50">
                            <button onclick="openLargeTileView(${counter.id})" class="block w-full text-left px-4 py-2 text-sm text-slate-300 hover:bg-slate-700">Large Tile (ENTER)</button>
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

            <div class="text-center mb-4">
                <div class="counter-value" id="counter-value-${counter.id}">${counter.value}</div>
            </div>

            <div class="counter-controls">
                <button class="counter-btn minus" onclick="adjustCounterValue(${counter.id}, -1)" title="Zmniejsz (←/-)">
                    <i class="fas fa-minus"></i>
                </button>
                <button class="counter-btn plus" onclick="adjustCounterValue(${counter.id}, 1)" title="Zwiększ (→/+)">
                    <i class="fas fa-plus"></i>
                </button>
            </div>

            ${dailyGoalText ? `<div class="daily-goal">${dailyGoalText}</div>` : ''}
        `;
    }

    // Event listener dla zaznaczania
    card.addEventListener('click', function(e) {
        // Nie zaznaczaj jeśli kliknięto przycisk
        if (e.target.closest('button')) return;
        selectCounter(counter.id);
    });

    // Event listener dla podwójnego kliknięcia (Large Tile)
    card.addEventListener('dblclick', function(e) {
        if (!e.target.closest('button')) {
            openLargeTileView(counter.id);
        }
    });

    return card;
}

// Large Tile View
function openLargeTileView(counterId) {
    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return;

    const gridView = document.getElementById('counters-container');
    const kpiSection = document.getElementById('kpi-section');
    const largeTileView = document.getElementById('large-tile-view');
    const largeTileContent = document.getElementById('large-tile-content');

    // Ukryj główny widok
    gridView.style.display = 'none';
    kpiSection.style.display = 'none';
    largeTileView.classList.remove('hidden');

    // Znajdź cel dzienny
    const dailyGoal = getDailyGoalForCounter(counter.id);
    let dailyGoalText = '';
    
    if (dailyGoal && typeof dailyGoal === 'object') {
        if (dailyGoal.current >= dailyGoal.total) {
            dailyGoalText = `<div class="text-center text-green-400 text-xl mb-6">✅ Cel dzienny osiągnięty: ${dailyGoal.current}/${dailyGoal.total}</div>`;
        } else {
            dailyGoalText = `<div class="text-center text-blue-400 text-xl mb-6">Cel dzienny: ${dailyGoal.current}/${dailyGoal.total} (pozostało: ${dailyGoal.remaining})</div>`;
        }
    }

    // Renderuj Large Tile
    largeTileContent.innerHTML = `
        <div class="large-tile-card max-w-md mx-auto">
            <div class="text-center mb-8">
                <h1 class="text-4xl font-bold text-white mb-2">${escapeHtml(counter.title)}</h1>
                <p class="text-xl text-gray-400">${escapeHtml(counter.category || 'Bez kategorii')}</p>
            </div>

            ${dailyGoalText}

            <div class="text-center mb-8">
                <div class="large-counter-value text-8xl font-bold text-white mb-4" id="large-counter-value-${counter.id}">${counter.value}</div>
            </div>

            <div class="large-counter-controls">
                <button class="large-counter-btn minus" onclick="adjustCounterValueLarge(${counter.id}, -1)">
                    <i class="fas fa-minus text-3xl"></i>
                </button>
                <button class="large-counter-btn plus" onclick="adjustCounterValueLarge(${counter.id}, 1)">
                    <i class="fas fa-plus text-3xl"></i>
                </button>
            </div>

            <div class="text-center mt-8">
                <button onclick="openAddAmountModal(${counter.id})" class="bg-blue-600 hover:bg-blue-500 text-white font-bold py-3 px-6 rounded-lg mr-4">
                    Dodaj ilość
                </button>
                <button onclick="openSetValueModal(${counter.id})" class="bg-purple-600 hover:bg-purple-500 text-white font-bold py-3 px-6 rounded-lg">
                    Ustaw wartość
                </button>
            </div>
        </div>
    `;

    selectedCounterId = counterId;
}

function closeLargeTileView() {
    const gridView = document.getElementById('counters-container');
    const kpiSection = document.getElementById('kpi-section');
    const largeTileView = document.getElementById('large-tile-view');

    gridView.style.display = 'block';
    kpiSection.style.display = 'block';
    largeTileView.classList.add('hidden');
}

function goBackToGridView() {
    closeLargeTileView();
}

function adjustCounterValueLarge(counterId, direction) {
    adjustCounterValue(counterId, direction);
    
    // Aktualizuj również Large Tile
    setTimeout(() => {
        const counter = currentCounters.find(c => c.id == counterId);
        if (counter) {
            const largeValueElement = document.getElementById(`large-counter-value-${counterId}`);
            if (largeValueElement) {
                largeValueElement.textContent = counter.value;
            }
            // Odśwież cel dzienny
            openLargeTileView(counterId);
        }
    }, 100);
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

// Drag & Drop Setup
function setupDragAndDrop() {
    if (!window.appData.isAdmin) return;

    const grid = document.getElementById('counters-grid');
    if (grid && currentView === 'grid') {
        if (sortable) {
            sortable.destroy();
        }
        
        sortable = Sortable.create(grid, {
            animation: 150,
            ghostClass: 'sortable-ghost',
            chosenClass: 'sortable-chosen',
            dragClass: 'sortable-drag',
            onEnd: function(evt) {
                const counterIds = Array.from(grid.children).map(card => card.dataset.counterId);
                saveSortOrder(counterIds);
            }
        });
    } else if (sortable) {
        sortable.destroy();
        sortable = null;
    }
}

async function saveSortOrder(counterIds) {
    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'sort_counters',
                counter_ids: JSON.stringify(counterIds)
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Kolejność zapisana', 'success');
        } else {
            showNotification('Błąd zapisywania kolejności: ' + data.message, 'error');
            loadCounterData(); // Odśwież dane
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
        loadCounterData(); // Odśwież dane
    }
}

// Zaznaczanie licznika
function selectCounter(counterId) {
    // Usuń poprzednie zaznaczenie
    document.querySelectorAll('.counter-card, .counter-card-list').forEach(card => {
        card.classList.remove('selected');
    });

    // Zaznacz nowy
    const card = document.querySelector(`[data-counter-id="${counterId}"]`);
    if (card) {
        card.classList.add('selected');
        selectedCounterId = counterId;
    }
}

// Nawigacja między licznikami
function navigateCounters(direction) {
    const cards = document.querySelectorAll('.counter-card, .counter-card-list');
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
    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return;

    const increment = counter.increment || 1;
    const change = direction * increment;
    const newValue = Math.max(0, parseInt(counter.value) + change);

    // Natychmiastowa aktualizacja UI
    const valueElement = document.getElementById(`counter-value-${counterId}`);
    if (valueElement) {
        valueElement.textContent = newValue;
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
    document.getElementById('new-counter-is-personal').checked = false;

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
    document.getElementById('edit-counter-is-personal').checked = counter.is_personal == 1;

    showModal(modal);
}

// Zapisz ustawienia licznika (edycja)
async function saveCounterSettings() {
    const counterId = document.getElementById('edit-counter-id').value;
    const title = document.getElementById('edit-counter-name').value.trim();
    const increment = document.getElementById('edit-counter-increment').value;
    const categoryId = document.getElementById('edit-counter-category').value;
    const color = document.getElementById('edit-counter-color').value;
    const isPersonal = document.getElementById('edit-counter-is-personal').checked ? 1 : 0;

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
                is_personal: isPersonal
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
    const isPersonal = document.getElementById('new-counter-is-personal').checked ? 1 : 0;

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
                is_personal: isPersonal
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

// Otwórz modal dodawania kategorii
function openAddCategoryModal() {
    const modal = document.getElementById('add-category-modal');
    if (!modal) return;

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
                action: 'save_category',
                name: name
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Kategoria dodana pomyślnie', 'success');
            closeAllModals();
            // Odśwież dane kategorii
            location.reload();
        } else {
            showNotification('Błąd dodawania kategorii: ' + data.message, 'error');
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

    currentKpiGoals.forEach(goal => {
        const row = document.createElement('tr');
        row.className = 'border-b border-slate-700 hover:bg-slate-800 cursor-pointer';
        row.onclick = () => openKpiDetailsModal(goal.id);

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
                <button onclick="event.stopPropagation(); openEditKpiModal(${goal.id})" class="text-blue-400 hover:text-blue-300 mr-2" title="Edytuj">
                    <i class="fas fa-edit"></i>
                </button>
                <button onclick="event.stopPropagation(); deleteKpiGoal(${goal.id})" class="text-red-400 hover:text-red-300" title="Usuń">
                    <i class="fas fa-trash"></i>
                </button>
                ` : ''}
            </td>
        `;

        tbody.appendChild(row);
    });
}

// Szczegóły KPI Modal
async function openKpiDetailsModal(goalId) {
    currentKpiGoalId = goalId;
    const modal = document.getElementById('kpi-details-modal');
    if (!modal) return;

    const goal = currentKpiGoals.find(g => g.id == goalId);
    if (!goal) return;

    document.getElementById('kpi-details-title').textContent = `Szczegóły KPI: ${goal.name}`;

    try {
        const month = document.getElementById('kpi-month-selector').value;
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'get_kpi_details',
                goal_id: goalId,
                month: month
            })
        });

        const data = await response.json();

        if (data.success) {
            renderKpiWeeklyBreakdown(data.weekly_data, data.goal);
            showModal(modal);
        } else {
            showNotification('Błąd ładowania szczegółów KPI: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

function renderKpiWeeklyBreakdown(weeklyData, goal) {
    const container = document.getElementById('kpi-weekly-breakdown');
    
    let html = `
        <div class="bg-slate-800/50 p-4 rounded-lg mb-4">
            <h3 class="text-lg font-semibold text-white mb-2">Podsumowanie miesięczne</h3>
            <p class="text-gray-300">Cel miesięczny: <span class="font-mono text-blue-400">${goal.total_goal}</span></p>
        </div>
        
        <table class="w-full text-sm text-left text-gray-300">
            <thead class="text-xs text-gray-400 uppercase bg-gray-800">
                <tr>
                    <th class="px-4 py-3">Tydzień</th>
                    <th class="px-4 py-3 text-right">Realizacja</th>
                    <th class="px-4 py-3 text-right">% Celu</th>
                </tr>
            </thead>
            <tbody>
    `;

    if (weeklyData.length === 0) {
        html += `
                <tr>
                    <td colspan="3" class="px-4 py-8 text-center text-gray-500">Brak danych dla tego miesiąca</td>
                </tr>
        `;
    } else {
        weeklyData.forEach((week, index) => {
            const weekGoal = goal.total_goal / 4; // Przybliżony cel tygodniowy
            const percentage = weekGoal > 0 ? Math.round((week.weekly_total / weekGoal) * 100) : 0;
            
            html += `
                <tr class="border-b border-slate-700">
                    <td class="px-4 py-3">Tydzień ${index + 1}</td>
                    <td class="px-4 py-3 text-right font-mono">${week.weekly_total}</td>
                    <td class="px-4 py-3 text-right font-mono">${percentage}%</td>
                </tr>
            `;
        });
    }

    html += `
            </tbody>
        </table>
    `;

    container.innerHTML = html;
}

// Korekta KPI Modal
function openKpiCorrectionModal() {
    const modal = document.getElementById('kpi-correction-modal');
    if (!modal) return;

    document.getElementById('correction-date').value = window.appData.today;
    document.getElementById('correction-value').value = '';
    document.getElementById('correction-description').value = '';
    
    closeAllModals();
    showModal(modal);
}

async function saveKpiCorrection() {
    const date = document.getElementById('correction-date').value;
    const value = document.getElementById('correction-value').value;
    const description = document.getElementById('correction-description').value;

    if (!value) {
        showNotification('Wartość korekty jest wymagana', 'error');
        return;
    }

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'save_kpi_correction',
                goal_id: currentKpiGoalId,
                date: date,
                value: value,
                description: description
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Korekta zapisana pomyślnie', 'success');
            closeAllModals();
            loadKpiData();
        } else {
            showNotification('Błąd zapisywania korekty: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// Korekta masowa Modal
function openMassCorrectionModal() {
    const modal = document.getElementById('mass-correction-modal');
    if (!modal) return;

    renderMassCorrectionTable();
    showModal(modal);
}

function renderMassCorrectionTable() {
    const container = document.getElementById('mass-correction-body');
    
    let html = `
        <table class="w-full text-sm text-gray-300">
            <thead class="text-xs text-gray-400 uppercase bg-gray-800">
                <tr>
                    <th class="px-4 py-3">Użytkownik</th>
                    <th class="px-4 py-3">Licznik</th>
                    <th class="px-4 py-3">Korekta</th>
                </tr>
            </thead>
            <tbody>
    `;

    window.appData.users.forEach(user => {
        currentCounters.forEach(counter => {
            html += `
                <tr class="border-b border-slate-700">
                    <td class="px-4 py-3">${escapeHtml(user.name)}</td>
                    <td class="px-4 py-3">${escapeHtml(counter.title)}</td>
                    <td class="px-4 py-3">
                        <input type="number" 
                               class="w-20 bg-slate-700 border border-slate-600 rounded px-2 py-1 text-white"
                               data-user-id="${user.id}"
                               data-counter-id="${counter.id}"
                               placeholder="0">
                    </td>
                </tr>
            `;
        });
    });

    html += '</tbody></table>';
    container.innerHTML = html;
}

async function saveMassCorrection() {
    const inputs = document.querySelectorAll('#mass-correction-body input[type="number"]');
    const corrections = [];

    inputs.forEach(input => {
        const value = parseInt(input.value) || 0;
        if (value !== 0) {
            corrections.push({
                user_id: input.dataset.userId,
                counter_id: input.dataset.counterId,
                value: value
            });
        }
    });

    if (corrections.length === 0) {
        showNotification('Brak korekt do zapisania', 'error');
        return;
    }

    try {
        const response = await fetch('ajax_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'save_mass_correction',
                corrections: JSON.stringify(corrections),
                date: window.appData.today
            })
        });

        const data = await response.json();

        if (data.success) {
            showNotification('Korekty masowe zapisane pomyślnie', 'success');
            closeAllModals();
            loadCounterData();
            loadKpiData();
        } else {
            showNotification('Błąd zapisywania korekt: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd AJAX:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
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

// Wypełnij dropdown kategorii
function populateCategoryDropdown() {
    const menu = document.getElementById('category-menu');
    if (!menu) return;

    menu.innerHTML = `
        <div class="category-menu-item" onclick="selectCategory('all', 'Wszystkie Kategorie')">
            Wszystkie Kategorie
        </div>
    `;

    window.appData.categories.forEach(category => {
        const item = document.createElement('div');
        item.className = 'category-menu-item';
        item.onclick = () => selectCategory(category.id, category.name);
        item.textContent = category.name;
        menu.appendChild(item);
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
    
    renderCounters();
    setupDragAndDrop(); // Odśwież drag & drop po zmianie widoku
}

// Przełącz widok
function toggleView() {
    changeView(currentView === 'grid' ? 'list' : 'grid');
}

// Przełącz kategorie w pętli
function cycleThroughCategories() {
    const categories = ['all', ...window.appData.categories.map(c => c.id.toString())];
    const categoryNames = ['Wszystkie Kategorie', ...window.appData.categories.map(c => c.name)];
    
    const currentIndex = categories.indexOf(currentCategory.toString());
    const nextIndex = (currentIndex + 1) % categories.length;
    
    selectCategory(categories[nextIndex], categoryNames[nextIndex]);
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
function toggleCounterMenu(counterId) {
    // Zamknij wszystkie inne menu
    document.querySelectorAll('[id^="counter-menu-"]').forEach(menu => {
        if (menu.id !== `counter-menu-${counterId}`) {
            menu.classList.add('hidden');
        }
    });
    
    // Przełącz obecne menu
    const menu = document.getElementById(`counter-menu-${counterId}`);
    menu.classList.toggle('hidden');
}

// Otwórz modal dodawania ilości
function openAddAmountModal(counterId) {
    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return;
    
    const amount = prompt(`Dodaj ilość do "${counter.title}":`, counter.increment);
    if (amount !== null && !isNaN(amount)) {
        const direction = parseInt(amount) / (counter.increment || 1);
        adjustCounterValue(counterId, direction);
    }
    
    // Zamknij menu
    document.getElementById(`counter-menu-${counterId}`).classList.add('hidden');
}

// Otwórz modal ustawiania wartości
function openSetValueModal(counterId) {
    const counter = currentCounters.find(c => c.id == counterId);
    if (!counter) return;
    
    const newValue = prompt(`Ustaw "${counter.title}" na:`, counter.value);
    if (newValue !== null && !isNaN(newValue)) {
        const difference = parseInt(newValue) - counter.value;
        const direction = difference / (counter.increment || 1);
        adjustCounterValue(counterId, direction);
    }
    
    // Zamknij menu
    document.getElementById(`counter-menu-${counterId}`).classList.add('hidden');
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
    document.querySelectorAll('.counter-card, .counter-card-list').forEach(card => {
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

// Zamknij menu kategorii przy kliknięciu poza nim
document.addEventListener('click', function(e) {
    const dropdown = document.getElementById('category-dropdown-container');
    const menu = document.getElementById('category-menu');

    if (dropdown && menu && !dropdown.contains(e.target)) {
        menu.classList.remove('show');
    }

    // Zamknij menu liczników przy kliknięciu poza nim
    if (!e.target.closest('[id^="counter-menu-"]') && !e.target.closest('button[onclick*="toggleCounterMenu"]')) {
        document.querySelectorAll('[id^="counter-menu-"]').forEach(menu => {
            menu.classList.add('hidden');
        });
    }
});
