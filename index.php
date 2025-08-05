
<?php
// Strona główna - Dashboard
session_start();

// Symulacja danych użytkownika dla mockupu
$current_user = 4;
$current_sfid = '20004014';
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - System zarządzania</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            color: #e2e8f0;
            min-height: 100vh;
            position: relative;
            overflow-x: hidden;
        }

        /* Animowane tło */
        body::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: 
                radial-gradient(circle at 20% 80%, rgba(52, 211, 153, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 80% 20%, rgba(59, 130, 246, 0.1) 0%, transparent 50%),
                radial-gradient(circle at 40% 40%, rgba(168, 85, 247, 0.05) 0%, transparent 50%);
            animation: backgroundFloat 20s ease-in-out infinite;
            z-index: -1;
        }

        @keyframes backgroundFloat {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            33% { transform: translate(30px, -30px) rotate(120deg); }
            66% { transform: translate(-20px, 20px) rotate(240deg); }
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            position: relative;
            z-index: 1;
        }

        .header {
            text-align: center;
            margin-bottom: 40px;
            padding: 30px;
            background: rgba(30, 41, 59, 0.8);
            border-radius: 12px;
            border: 1px solid rgb(51, 65, 85);
            backdrop-filter: blur(10px);
        }

        .header h1 {
            color: #34d399;
            font-size: 2.5rem;
            margin-bottom: 10px;
        }

        .header p {
            color: #94a3b8;
            font-size: 1.1rem;
        }

        .modules-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .module-card {
            background: rgba(30, 41, 59, 0.8);
            border: 1px solid rgb(51, 65, 85);
            border-radius: 12px;
            padding: 25px;
            text-decoration: none;
            color: inherit;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .module-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
            border-color: #34d399;
        }

        .module-icon {
            font-size: 3rem;
            color: #34d399;
            margin-bottom: 15px;
        }

        .module-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 10px;
            color: #f8fafc;
        }

        .module-description {
            color: #cbd5e1;
            line-height: 1.6;
        }

        .widgets-section {
            margin-top: 40px;
        }

        .widgets-title {
            color: #34d399;
            font-size: 1.8rem;
            margin-bottom: 20px;
            text-align: center;
        }

        .widgets-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }

        .widget-card {
            min-height: 250px;
        }

        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }

            .header h1 {
                font-size: 2rem;
            }

            .modules-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header class="header">
            <h1><i class="fas fa-tachometer-alt"></i> Dashboard</h1>
            <p>System zarządzania - Panel główny</p>
        </header>

        <div class="modules-grid">
            <a href="/modules/licznik2/public.php" class="module-card">
                <div class="module-icon">
                    <i class="fas fa-chart-line"></i>
                </div>
                <h2 class="module-title">Liczniki & KPI</h2>
                <p class="module-description">
                    Monitorowanie wskaźników wydajności, analiza danych i raporty w czasie rzeczywistym.
                </p>
            </a>

            <a href="/modules/to-do/mockup.html" class="module-card">
                <div class="module-icon">
                    <i class="fas fa-tasks"></i>
                </div>
                <h2 class="module-title">Tablica To-Do (Mockup)</h2>
                <p class="module-description">
                    System zarządzania zadaniami w stylu Kanban Board z możliwością przypisywania i śledzenia postępów.
                </p>
            </a>

            <a href="/reports/" class="module-card">
                <div class="module-icon">
                    <i class="fas fa-file-alt"></i>
                </div>
                <h2 class="module-title">Raporty</h2>
                <p class="module-description">
                    Generowanie szczegółowych raportów, analiz i zestawień danych z różnych modułów systemu.
                </p>
            </a>
        </div>

        <section class="widgets-section">
            <h2 class="widgets-title">
                <i class="fas fa-th-large"></i> Szybki podgląd
            </h2>
            <div class="widgets-grid">
                <div class="widget-card">
                    <!-- Widget To-Do -->
                    <div style="background: rgba(30, 41, 59, 0.8); border: 1px solid rgb(51, 65, 85); border-radius: 12px; padding: 20px; height: 100%;">
                        <h3 style="color: #34d399; margin-bottom: 15px; display: flex; align-items: center;">
                            <i class="fas fa-list-check" style="margin-right: 8px;"></i>
                            Widget To-Do (mockup)
                        </h3>
                        <p style="color: #94a3b8;">Kliknij w moduł To-Do powyżej, aby zobaczyć pełny mockup</p>
                    </div>
                </div>
                
                <div class="widget-card">
                    <!-- Tutaj może być widget liczników -->
                    <div style="background: rgba(30, 41, 59, 0.8); border: 1px solid rgb(51, 65, 85); border-radius: 12px; padding: 20px; height: 100%; display: flex; align-items: center; justify-content: center; color: #94a3b8;">
                        <i class="fas fa-chart-pie" style="font-size: 2rem; margin-right: 10px;"></i>
                        Widget liczników (wkrótce)
                    </div>
                </div>
            </div>
        </section>
    </div>

    <script>
        // Globalne dane aplikacji dla JavaScript
        window.appData = {
            currentUser: {
                id: <?php echo $current_user; ?>,
                sfid: '<?php echo $current_sfid; ?>'
            }
        };
    </script>
</body>
</html>
