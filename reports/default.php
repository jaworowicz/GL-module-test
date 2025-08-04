
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Szybki Raport KPI</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        }
        .report-container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .report-header {
            background: #1e293b;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .report-table {
            width: 100%;
            border-collapse: collapse;
        }
        .report-table th {
            background: #64748b;
            color: white;
            padding: 12px;
            text-align: center;
            font-weight: bold;
        }
        .report-table td {
            padding: 10px 12px;
            border-bottom: 1px solid #e2e8f0;
            text-align: center;
        }
        .section-header {
            background: #e2e8f0;
            font-weight: bold;
            text-align: left;
            padding: 8px 12px;
        }
        .value-positive { background-color: #dcfce7; color: #166534; }
        .value-negative { background-color: #fecaca; color: #dc2626; }
        .value-neutral { background-color: #f8fafc; color: #374151; }
        
        /* Responsywne style */
        @media (max-width: 768px) {
            body { 
                padding: 10px; 
                font-size: 14px; 
            }
            .report-container { 
                margin: 0; 
                border-radius: 4px;
                box-shadow: 0 1px 5px rgba(0,0,0,0.1);
            }
            .report-header { 
                padding: 15px; 
            }
            .report-header h1 { 
                font-size: 1.4rem; 
                margin: 0 0 8px 0;
            }
            .report-table { 
                font-size: 12px; 
                overflow-x: auto;
                display: block;
                white-space: nowrap;
            }
            .report-table thead, .report-table tbody, .report-table tr {
                display: table;
                width: 100%;
                table-layout: fixed;
            }
            .report-table th, .report-table td { 
                padding: 8px 4px; 
                word-wrap: break-word;
            }
            .section-header { 
                font-size: 13px; 
                padding: 8px;
                background: #94a3b8 !important;
            }
        }
        
        @media (max-width: 480px) {
            body {
                padding: 5px;
                font-size: 12px;
            }
            .report-header { 
                padding: 10px; 
            }
            .report-header h1 {
                font-size: 1.2rem;
                margin: 0;
            }
            .report-table {
                font-size: 11px;
            }
            .report-table th, .report-table td {
                padding: 6px 2px;
            }
        }
        
        /* Dodatkowe style dla podglądu */
        .preview-notice {
            background: #f59e0b;
            color: white;
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="report-container">
        <div class="report-header">
            <h1>📊 Raport KPI - {REPORT_DATE}</h1>
            <p>Dzienny przegląd celów i osiągnięć</p>
        </div>
        
        <div class="report-content">
            <table class="report-table">
                <thead>
                    <tr class="section-header">
                        <th colspan="4">Cele KPI na dzień {REPORT_DATE}</th>
                    </tr>
                    <tr>
                        <th>Nazwa celu</th>
                        <th>Osiągnięcie</th>
                        <th>Cel dzienny</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>{KPI_NAME=1}</td>
                        <td class="value-good">{KPI_VALUE=1}</td>
                        <td>{KPI_TARGET_DAILY=1}</td>
                        <td class="value-good">✓</td>
                    </tr>
                    <tr>
                        <td>{KPI_NAME=2}</td>
                        <td class="value-neutral">{KPI_VALUE=2}</td>
                        <td>{KPI_TARGET_DAILY=2}</td>
                        <td class="value-neutral">○</td>
                    </tr>
                    <tr>
                        <td>{KPI_NAME=3}</td>
                        <td class="value-warning">{KPI_VALUE=3}</td>
                        <td>{KPI_TARGET_DAILY=3}</td>
                        <td class="value-warning">!</td>
                    </tr>
                    <tr>
                        <td>{KPI_NAME=4}</td>
                        <td class="value-good">{KPI_VALUE=4}</td>
                        <td>{KPI_TARGET_DAILY=4}</td>
                        <td class="value-good">✓</td>
                    </tr>
                    <tr>
                        <td>{KPI_NAME=5}</td>
                        <td class="value-neutral">{KPI_VALUE=5}</td>
                        <td>{KPI_TARGET_DAILY=5}</td>
                        <td class="value-neutral">○</td>
                    </tr>
                </tbody>
            </table>
            
            <div style="margin-top: 30px; padding: 15px; background: #f8fafc; border-radius: 8px;">
                <h3 style="margin: 0 0 10px 0; color: #374151;">📈 Podsumowanie</h3>
                <p style="margin: 5px 0; color: #6b7280;">Raport wygenerowany automatycznie na podstawie danych z systemu liczników KPI.</p>
                <p style="margin: 5px 0; color: #6b7280;">Data generowania: <?php echo date('d.m.Y H:i'); ?></p>
            </div>
        </div>
    </div>
</body>
</html> 
                font-size: 1.1rem; 
                margin: 0 0 5px 0;
            }
            .report-header p {
                font-size: 12px;
                margin: 0;
            }
            .report-table { 
                font-size: 10px; 
            }
            .report-table th, .report-table td { 
                padding: 4px 2px; 
                font-size: 9px;
            }
            .section-header {
                font-size: 10px;
                padding: 4px;
                font-weight: bold;
            }
        }
        
        /* Zapewnienie czytelności na wszystkich urządzeniach */
        @media print {
            body { background: white; }
            .report-container { box-shadow: none; }
        }
    </style>
</head>
<body>
    <div class="report-container">
        <div class="report-header">
            <h1>RAPORT DZIENNY</h1>
            <p>Data: {REPORT_DATE}</p>
        </div>
        
        <table class="report-table">
            <thead>
                <tr>
                    <th>A</th>
                    <th>B</th>
                    <th>C</th>
                    <th>D</th>
                    <th>E</th>
                </tr>
            </thead>
            <tbody>
                <!-- SEKCJA WOLUMEN -->
                <tr class="section-header">
                    <td colspan="5">WOLUMEN</td>
                </tr>
                <tr>
                    <td>POZ TOTAL</td>
                    <td>{KPI_VALUE=1}</td>
                    <td>{KPI_TARGET_DAILY=1}</td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td>POZ FTTH</td>
                    <td>{KPI_VALUE=2}</td>
                    <td>{KPI_TARGET_DAILY=2}</td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td>ZATRZYMANIE</td>
                    <td>{KPI_VALUE=3}</td>
                    <td>x</td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td>TELEFONY</td>
                    <td>{KPI_VALUE=4}</td>
                    <td>{KPI_TARGET_DAILY=4}</td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td>VAS SU/INNE</td>
                    <td>{KPI_VALUE=5}/{KPI_VALUE=6}</td>
                    <td>0</td>
                    <td></td>
                    <td></td>
                </tr>

                <!-- SEKCJA WARTOŚĆ Z KLIENTA -->
                <tr class="section-header">
                    <td>WARTOŚĆ Z KLIENTA</td>
                    <td>ILOŚĆ</td>
                    <td>ŁĄCZNA KWOTA</td>
                    <td>ND</td>
                    <td></td>
                </tr>
                <tr>
                    <td>DELTA DODATNIA</td>
                    <td></td>
                    <td>{KPI_VALUE=7}</td>
                    <td>{KPI_TARGET_MONTHLY=7}</td>
                    <td></td>
                </tr>
                <tr>
                    <td>DELTA ZERO</td>
                    <td></td>
                    <td>0</td>
                    <td>x</td>
                    <td></td>
                </tr>
                <tr>
                    <td>DELTA UJEMNA</td>
                    <td></td>
                    <td></td>
                    <td>x</td>
                    <td></td>
                </tr>

                <!-- SEKCJA BAZA ZESPAW -->
                <tr class="section-header">
                    <td>BAZA ZESAW</td>
                    <td>WYKONANE</td>
                    <td>ODEBRANE</td>
                    <td>CEL DZIENNY ODEBRANE</td>
                    <td></td>
                </tr>
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>{KPI_TARGET_DAILY=8}</td>
                    <td></td>
                </tr>
            </tbody>
        </table>
    </div>
</body>
</html>
