
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
