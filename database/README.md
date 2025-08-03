
# Import bazy danych

## Kroki importu:

1. Utwórz bazę danych MySQL o nazwie `horusjcz_liberty`
2. Zaimportuj plik `horusjcz_liberty.sql` do swojej bazy danych

### Dla phpMyAdmin:
- Wejdź do phpMyAdmin
- Wybierz bazę `horusjcz_liberty` 
- Kliknij zakładkę "Import"
- Wybierz plik `horusjcz_liberty.sql`
- Kliknij "Wykonaj"

### Dla MySQL CLI:
```bash
mysql -u root -p horusjcz_liberty < database/horusjcz_liberty.sql
```

### Dla Replit Database:
W Replit możesz użyć wbudowanej bazy PostgreSQL zamiast MySQL. Będzie trzeba dostosować składnię SQL.

## Struktura bazy:

Baza zawiera następujące tabele modułu KPI:
- `licznik_categories` - Kategorie liczników
- `licznik_counters` - Liczniki/mierniki 
- `licznik_daily_values` - Wartości dzienne liczników
- `licznik_kpi_goals` - Cele KPI
- `licznik_kpi_linked_counters` - Powiązania celów z licznikami
- `sfid_locations` - Lokalizacje

## Przykładowe dane:

Baza zawiera przykładowe dane dla lokalizacji 20004014 (Pasaż Grunwaldzki) z różnymi licznikami jak:
- Pozyskanie FTTH/INNE
- VAS SU/INNE  
- Telefony, NKS, Akcesoria
- Delta, BAZA, itp.

Oraz cele KPI z odpowiednimi target'ami miesięcznymi.
