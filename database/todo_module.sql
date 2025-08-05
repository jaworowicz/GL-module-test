
-- ========================================
-- SQL SCHEMA DLA MODUŁU TO-DO KANBAN BOARD
-- ========================================

-- Tabela statusów zadań
CREATE TABLE `todo_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `color` varchar(7) DEFAULT '#374151',
  `order_position` int(11) DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Wstawianie domyślnych statusów
INSERT INTO `todo_statuses` (`name`, `color`, `order_position`) VALUES
('Nowe', '#ef4444', 1),
('W toku', '#f59e0b', 2),
('Zwrócone', '#8b5cf6', 3),
('Zakończone', '#22c55e', 4);

-- Tabela kategorii zadań
CREATE TABLE `todo_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `color` varchar(7) DEFAULT '#374151',
  `icon` varchar(50) DEFAULT 'mdi-folder',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Wstawianie domyślnych kategorii
INSERT INTO `todo_categories` (`name`, `color`, `icon`) VALUES
('Ogólne', '#6b7280', 'mdi-folder'),
('Sprzedaż', '#22c55e', 'mdi-currency-usd'),
('Obsługa klienta', '#3b82f6', 'mdi-account-group'),
('Administracja', '#f59e0b', 'mdi-office-building'),
('Szkolenia', '#8b5cf6', 'mdi-school'),
('Technicza', '#ef4444', 'mdi-tools');

-- Główna tabela zadań
CREATE TABLE `todo_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `status_id` int(11) NOT NULL DEFAULT 1,
  `category_id` int(11) NOT NULL DEFAULT 1,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `assignment_type` enum('global','location','user','self') NOT NULL DEFAULT 'global',
  `sfid_id` int(11) DEFAULT NULL,
  `assigned_user` int(11) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `due_date` datetime DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `completed_by` int(11) DEFAULT NULL,
  `order_position` int(11) DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `status_id` (`status_id`),
  KEY `category_id` (`category_id`),
  KEY `sfid_id` (`sfid_id`),
  KEY `assigned_user` (`assigned_user`),
  KEY `created_by` (`created_by`),
  KEY `completed_by` (`completed_by`),
  KEY `assignment_type` (`assignment_type`),
  KEY `priority` (`priority`),
  CONSTRAINT `todo_tasks_status_fk` FOREIGN KEY (`status_id`) REFERENCES `todo_statuses` (`id`),
  CONSTRAINT `todo_tasks_category_fk` FOREIGN KEY (`category_id`) REFERENCES `todo_categories` (`id`),
  CONSTRAINT `todo_tasks_location_fk` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela komentarzy do zadań
CREATE TABLE `todo_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment` text NOT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `todo_comments_task_fk` FOREIGN KEY (`task_id`) REFERENCES `todo_tasks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela załączników do zadań
CREATE TABLE `todo_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `file_size` int(11) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `upload_path` varchar(500) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `todo_attachments_task_fk` FOREIGN KEY (`task_id`) REFERENCES `todo_tasks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela obserwujących zadanie
CREATE TABLE `todo_watchers` (
  `task_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`task_id`, `user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `todo_watchers_task_fk` FOREIGN KEY (`task_id`) REFERENCES `todo_tasks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela historii zmian statusu
CREATE TABLE `todo_status_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `from_status_id` int(11) DEFAULT NULL,
  `to_status_id` int(11) NOT NULL,
  `changed_by` int(11) NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `task_id` (`task_id`),
  KEY `from_status_id` (`from_status_id`),
  KEY `to_status_id` (`to_status_id`),
  KEY `changed_by` (`changed_by`),
  CONSTRAINT `todo_history_task_fk` FOREIGN KEY (`task_id`) REFERENCES `todo_tasks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `todo_history_from_status_fk` FOREIGN KEY (`from_status_id`) REFERENCES `todo_statuses` (`id`),
  CONSTRAINT `todo_history_to_status_fk` FOREIGN KEY (`to_status_id`) REFERENCES `todo_statuses` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela powiadomień
CREATE TABLE `todo_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `type` enum('assigned','status_changed','comment_added','due_soon','overdue') NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `task_id` (`task_id`),
  KEY `is_read` (`is_read`),
  KEY `type` (`type`),
  CONSTRAINT `todo_notifications_task_fk` FOREIGN KEY (`task_id`) REFERENCES `todo_tasks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela ustawień modułu
CREATE TABLE `todo_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sfid_id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_location_setting` (`sfid_id`, `setting_key`),
  KEY `sfid_id` (`sfid_id`),
  CONSTRAINT `todo_settings_location_fk` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Wstawianie domyślnych ustawień
INSERT INTO `todo_settings` (`sfid_id`, `setting_key`, `setting_value`) VALUES
(20004014, 'auto_assign_global_tasks', '1'),
(20004014, 'notification_email_enabled', '1'),
(20004014, 'widget_tasks_limit', '5'),
(20004014, 'default_priority', 'medium'),
(20004014, 'allow_self_assignment', '1');

-- Przykładowe zadania testowe
INSERT INTO `todo_tasks` (`title`, `description`, `status_id`, `category_id`, `priority`, `assignment_type`, `sfid_id`, `created_by`, `due_date`) VALUES
('Przygotowanie raportu sprzedaży', 'Sporządzenie miesięcznego raportu sprzedaży za poprzedni miesiąc', 1, 2, 'high', 'location', 20004014, 4, DATE_ADD(NOW(), INTERVAL 2 DAY)),
('Aktualizacja bazy klientów', 'Weryfikacja i aktualizacja danych kontaktowych klientów', 2, 3, 'medium', 'global', 20004014, 4, DATE_ADD(NOW(), INTERVAL 5 DAY)),
('Szkolenie z nowych produktów', 'Uczestnictwo w szkoleniu z nowej oferty telekomunikacyjnej', 1, 5, 'medium', 'location', 20004014, 4, DATE_ADD(NOW(), INTERVAL 7 DAY)),
('Przegląd procedur obsługi', 'Analiza i optymalizacja procedur obsługi klienta', 3, 4, 'low', 'global', 20004014, 4, DATE_ADD(NOW(), INTERVAL 10 DAY));

-- Przykładowe komentarze
INSERT INTO `todo_comments` (`task_id`, `user_id`, `comment`, `is_system`) VALUES
(1, 4, 'Rozpoczęto pracę nad raportem', 0),
(2, 4, 'Zadanie zostało przypisane automatycznie', 1),
(2, 4, 'W trakcie weryfikacji pierwszej partii danych', 0);

-- Widoki pomocnicze
CREATE VIEW `todo_tasks_view` AS
SELECT 
    t.id,
    t.title,
    t.description,
    t.priority,
    t.assignment_type,
    t.due_date,
    t.completed_at,
    t.order_position,
    t.created_at,
    t.updated_at,
    ts.name as status_name,
    ts.color as status_color,
    tc.name as category_name,
    tc.color as category_color,
    tc.icon as category_icon,
    sl.name as location_name,
    CONCAT(creator.first_name, ' ', creator.last_name) as created_by_name,
    CONCAT(assignee.first_name, ' ', assignee.last_name) as assigned_user_name,
    CONCAT(completer.first_name, ' ', completer.last_name) as completed_by_name
FROM todo_tasks t
LEFT JOIN todo_statuses ts ON t.status_id = ts.id
LEFT JOIN todo_categories tc ON t.category_id = tc.id
LEFT JOIN sfid_locations sl ON t.sfid_id = sl.id
LEFT JOIN employees creator ON t.created_by = creator.id
LEFT JOIN employees assignee ON t.assigned_user = assignee.id
LEFT JOIN employees completer ON t.completed_by = completer.id
WHERE t.deleted_at IS NULL;

-- Triggery
DELIMITER ;;

-- Trigger do automatycznego dodawania wpisu w historii przy zmianie statusu
CREATE TRIGGER `todo_status_change_history` 
AFTER UPDATE ON `todo_tasks`
FOR EACH ROW
BEGIN
    IF OLD.status_id != NEW.status_id THEN
        INSERT INTO todo_status_history (task_id, from_status_id, to_status_id, changed_by, created_at)
        VALUES (NEW.id, OLD.status_id, NEW.status_id, NEW.updated_at, NOW());
    END IF;
END;;

-- Trigger do automatycznego ustawiania completed_at przy zmianie na status "Zakończone"
CREATE TRIGGER `todo_task_completion`
AFTER UPDATE ON `todo_tasks`
FOR EACH ROW
BEGIN
    IF NEW.status_id = 4 AND OLD.status_id != 4 THEN
        UPDATE todo_tasks SET completed_at = NOW() WHERE id = NEW.id;
    ELSEIF NEW.status_id != 4 AND OLD.status_id = 4 THEN
        UPDATE todo_tasks SET completed_at = NULL WHERE id = NEW.id;
    END IF;
END;;

DELIMITER ;

-- Indeksy dodatkowe dla wydajności
CREATE INDEX idx_todo_tasks_status_location ON todo_tasks(status_id, sfid_id);
CREATE INDEX idx_todo_tasks_assigned_active ON todo_tasks(assigned_user, is_active);
CREATE INDEX idx_todo_tasks_due_date ON todo_tasks(due_date);
CREATE INDEX idx_todo_tasks_priority ON todo_tasks(priority, status_id);
CREATE INDEX idx_todo_comments_task_created ON todo_comments(task_id, created_at);
CREATE INDEX idx_todo_notifications_user_unread ON todo_notifications(user_id, is_read);

-- ========================================
-- DOKUMENTACJA TABEL
-- ========================================

/*
TABELE W MODULE TO-DO:

1. todo_statuses - Statusy zadań (Nowe, W toku, Zwrócone, Zakończone)
2. todo_categories - Kategorie zadań (Sprzedaż, Obsługa klienta, itp.)
3. todo_tasks - Główna tabela zadań z wszystkimi informacjami
4. todo_comments - Komentarze do zadań
5. todo_attachments - Załączniki do zadań
6. todo_watchers - Obserwujący zadania
7. todo_status_history - Historia zmian statusów
8. todo_notifications - Powiadomienia dla użytkowników
9. todo_settings - Ustawienia modułu per lokalizacja
10. todo_tasks_view - Widok z połączonymi danymi (helper view)

ISTNIEJĄCE TABELE WYKORZYSTYWANE:
- sfid_locations (lokalizacje)
- employees (użytkownicy - założenie na podstawie foreign key w innych modułach)

TYPY PRZYPISAŃ (assignment_type):
- global: zadanie globalne dla wszystkich w systemie
- location: zadanie dla konkretnej lokalizacji 
- user: zadanie dla konkretnego użytkownika
- self: zadanie któremu każdy może się przypisać

PRIORYTETY:
- low: niski
- medium: średni  
- high: wysoki
- urgent: pilny

STATUSY DOMYŚLNE:
1. Nowe (czerwony)
2. W toku (żółty)
3. Zwrócone (fioletowy) 
4. Zakończone (zielony)
*/
