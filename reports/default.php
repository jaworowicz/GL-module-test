<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Raport KPI zespołowy</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #16a34a; color: white; padding: 15px; margin-bottom: 20px; border-radius: 8px; }
        .kpi-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .kpi-table th, .kpi-table td { border: 1px solid #ddd; padding: 12px; text-align: center; }
        .kpi-table th { background: #f8f9fa; font-weight: bold; }
        .kpi-row:nth-child(even) { background: #f8f9fa; }
        .debug { background: #fff3cd; padding: 10px; margin: 10px 0; border-radius: 5px; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎯 PODGLĄD RAPORTU ZESPOŁOWEGO - dane całej lokalizacji za dzień: {REPORT_DATE}</h1>
    </div>

    <div class="debug">
        <strong>DEBUG INFO:</strong> Ten szablon pokazuje rzeczywiste dane z modułu liczników dla KPI ID=12.
    </div>

    <table class="kpi-table">
        <thead>
            <tr>
                <th>NAZWA KPI</th>
                <th>REALIZACJA DZIENNA</th>
                <th>CEL DZIENNY</th>
                <th>CEL MIESIĘCZNY</th>
            </tr>
        </thead>
        <tbody>
            <tr class="kpi-row">
                <td><strong>{KPI_NAME=12}</strong></td>
                <td style="font-size: 18px; font-weight: bold; color: #059669;">{KPI_VALUE=12}</td>
                <td>{KPI_TARGET_DAILY=12}</td>
                <td>{KPI_TARGET_MONTHLY=12}</td>
            </tr>
        </tbody>
    </table>

    <div style="margin-top: 30px; font-size: 12px; color: #666;">
        Raport wygenerowany: {TODAY}<br>
        System automatycznie agreguje wartości wszystkich pracowników z lokalizacji
    </div>
</body>
</html>