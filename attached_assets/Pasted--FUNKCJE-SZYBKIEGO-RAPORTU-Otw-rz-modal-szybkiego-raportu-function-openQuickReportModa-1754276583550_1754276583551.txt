// === FUNKCJE SZYBKIEGO RAPORTU ===

// Otwórz modal szybkiego raportu
function openQuickReportModal() {
    const modal = document.getElementById('quick-report-modal');
    if (!modal) return;

    // Załaduj dostępne szablony
    loadReportTemplates();

    showModal(modal);
}

// Załaduj dostępne szablony
async function loadReportTemplates() {
    try {
        const response = await fetch('reports/report_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'get_report_templates'
            })
        });

        const data = await response.json();

        if (data.success) {
            const select = document.getElementById('report-template');
            select.innerHTML = '';

            data.templates.forEach(template => {
                const option = document.createElement('option');
                option.value = template.filename;
                option.textContent = template.name;
                select.appendChild(option);
            });

            // Załaduj podgląd pierwszego szablonu
            if (data.templates.length > 0) {
                loadReportPreview(data.templates[0].filename);
            }
        }
    } catch (error) {
        console.error('Błąd ładowania szablonów:', error);
        showNotification('Błąd ładowania szablonów raportu', 'error');
    }
}

// Załaduj podgląd szablonu
async function loadReportPreview(templateName) {
    try {
        const response = await fetch('reports/report_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'get_report_preview',
                template: templateName,
                date: document.getElementById('report-date').value
            })
        });

        const data = await response.json();

        if (data.success) {
            document.getElementById('report-preview').innerHTML = data.preview;
        } else {
            document.getElementById('report-preview').innerHTML = `<p class="text-red-400">Błąd: ${data.message}</p>`;
        }
    } catch (error) {
        console.error('Błąd ładowania podglądu:', error);
        document.getElementById('report-preview').innerHTML = '<p class="text-red-400">Błąd ładowania podglądu</p>';
    }
}

// Generuj raport
async function generateReport() {
    const template = document.getElementById('report-template').value;
    const date = document.getElementById('report-date').value;

    try {
        const response = await fetch('reports/report_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'generate_report',
                template: template,
                date: date
            })
        });

        const data = await response.json();

        if (data.success) {
            // Otwórz raport w nowym oknie
            const newWindow = window.open('', '_blank');
            newWindow.document.write(data.html);
            newWindow.document.close();

            showNotification('Raport wygenerowany pomyślnie', 'success');
            closeAllModals();
        } else {
            showNotification('Błąd generowania raportu: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd generowania raportu:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// Pobierz raport jako HTML
async function downloadReport() {
    const template = document.getElementById('report-template').value;
    const date = document.getElementById('report-date').value;

    try {
        const response = await fetch('reports/report_handler.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams({
                action: 'generate_report',
                template: template,
                date: date
            })
        });

        const data = await response.json();

        if (data.success) {
            // Utwórz plik do pobrania
            const blob = new Blob([data.html], { type: 'text/html' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `raport_${date}.html`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);

            showNotification('Raport pobrany pomyślnie', 'success');
            closeAllModals();
        } else {
            showNotification('Błąd pobierania raportu: ' + data.message, 'error');
        }
    } catch (error) {
        console.error('Błąd pobierania raportu:', error);
        showNotification('Błąd połączenia z serwerem', 'error');
    }
}

// Event listenery dla raportów
document.addEventListener('DOMContentLoaded', function() {
    const templateSelect = document.getElementById('report-template');
    const dateInput = document.getElementById('report-date');

    if (templateSelect) {
        templateSelect.addEventListener('change', function() {
            loadReportPreview(this.value);
        });
    }

    if (dateInput) {
        dateInput.addEventListener('change', function() {
            const template = document.getElementById('report-template').value;
            if (template) {
                loadReportPreview(template);
            }
        });
    }
});