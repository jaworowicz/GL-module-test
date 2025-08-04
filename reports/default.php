<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Raport KPI - {REPORT_DATE}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            color: #333;
            background: #f8f9fa;
        }
        .header {
            background: #2563eb;
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 30px;
        }
        .report-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .report-table th {
            background: #374151;
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        .report-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #e5e7eb;
        }
        .report-table tr:hover {
            background: #f9fafb;
        }
        .value-cell {
            text-align: right;
            font-weight: 600;
            font-family: 'Courier New', monospace;
        }
        .footer {
            margin-top: 30px;
            text-align: center;
            color: #6b7280;
            font-size: 14px;
        }
        @media print {
            body { margin: 0; }
            .header { background: #333 !important; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>RAPORT KPI ZESPOŁOWY</h1>
        <p>Data raportu: {REPORT_DATE}</p>
        <p>Dane za dzień: {REPORT_DATE}</p>
    </div>

    <table class="report-table">
        <thead>
            <tr>
                <th>KPI</th>
                <th>Realizacja</th>
                <th>Cel dzienny</th>
                <th>Cel miesięczny</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>{KPI_NAME=12}</td>
                <td class="value-cell">{KPI_VALUE=12}</td>
                <td class="value-cell">{KPI_TARGET_DAILY=12}</td>
                <td class="value-cell">{KPI_TARGET_MONTHLY=12}</td>
                <td class="value-cell">
                    <span style="color: #16a34a;">✓</span>
                </td>
            </tr>
            <tr>
                <td>{KPI_NAME=13}</td>
                <td class="value-cell">{KPI_VALUE=13}</td>
                <td class="value-cell">{KPI_TARGET_DAILY=13}</td>
                <td class="value-cell">{KPI_TARGET_MONTHLY=13}</td>
                <td class="value-cell">
                    <span style="color: #dc2626;">●</span>
                </td>
            </tr>
            <tr>
                <td>{KPI_NAME=14}</td>
                <td class="value-cell">{KPI_VALUE=14}</td>
                <td class="value-cell">{KPI_TARGET_DAILY=14}</td>
                <td class="value-cell">{KPI_TARGET_MONTHLY=14}</td>
                <td class="value-cell">
                    <span style="color: #f59e0b;">◐</span>
                </td>
            </tr>
        </tbody>
    </table>

    <div class="footer">
        <p>Raport wygenerowany automatycznie {TODAY}</p>
        <p>System Liczników KPI - Moduł Raportowania</p>
    </div>
</body>
</html>