
-- ===================================================================
-- SQL dla modułu To-Do Kanban Board
-- ===================================================================

-- Tabela zadań
CREATE TABLE `todo_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('new','in-progress','returned','completed') NOT NULL DEFAULT 'new',
  `priority` enum('low','medium','high') NOT NULL DEFAULT 'medium',
  `assignment_type` enum('global','user','self') NOT NULL DEFAULT 'self',
  `created_by` int(11) NOT NULL,
  `assigned_to` int(11) DEFAULT NULL COMMENT 'NULL dla globalnych, ID użytkownika dla przypisanych',
  `sfid_id` int(11) NOT NULL,
  `due_date` date DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_assigned_to` (`assigned_to`),
  KEY `idx_sfid` (`sfid_id`),
  KEY `idx_due_date` (`due_date`),
  KEY `idx_assignment_type` (`assignment_type`),
  CONSTRAINT `fk_todo_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_todo_assigned_to` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_todo_sfid` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela komentarzy do zadań
CREATE TABLE `todo_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_comment_task` FOREIGN KEY (`task_id`) REFERENCES `todo_tasks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela historii zmian zadań
CREATE TABLE `todo_task_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `action` varchar(50) NOT NULL COMMENT 'created, status_changed, assigned, completed, etc.',
  `old_value` varchar(255) DEFAULT NULL,
  `new_value` varchar(255) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_action` (`action`),
  CONSTRAINT `fk_history_task` FOREIGN KEY (`task_id`) REFERENCES `todo_tasks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_history_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela przypisań zadań (dla zadań, które mogą być przypisane wielu użytkownikom)
CREATE TABLE `todo_task_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `assigned_by` int(11) NOT NULL,
  `accepted` tinyint(1) DEFAULT 0,
  `accepted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_task_user` (`task_id`,`user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_assigned_by` (`assigned_by`),
  CONSTRAINT `fk_assignment_task` FOREIGN KEY (`task_id`) REFERENCES `todo_tasks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assignment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assignment_assigner` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- OPIS TABEL I ZALEŻNOŚCI
-- ===================================================================

/*
TABELE MODUŁU TO-DO:

1. **todo_tasks** - główna tabela zadań
   - Przechowuje wszystkie zadania w systemie
   - Zależności:
     * created_by -> users(id) - kto utworzył zadanie
     * assigned_to -> users(id) - komu przypisane (może być NULL)
     * sfid_id -> sfid_locations(id) - lokalizacja zadania

2. **todo_comments** - komentarze do zadań
   - Umożliwia dodawanie komentarzy do zadań
   - Zależności:
     * task_id -> todo_tasks(id) - do którego zadania
     * user_id -> users(id) - kto dodał komentarz

3. **todo_task_history** - historia zmian zadań
   - Śledzi wszystkie zmiany w zadaniach (audit log)
   - Zależności:
     * task_id -> todo_tasks(id) - którego zadania dotyczy
     * user_id -> users(id) - kto wykonał zmianę

4. **todo_task_assignments** - przypisania zadań
   - Dla przypadków gdy zadanie może być przypisane wielu użytkownikom
   - Zależności:
     * task_id -> todo_tasks(id) - które zadanie
     * user_id -> users(id) - komu przypisane
     * assigned_by -> users(id) - kto przypisał

RELACJE Z ISTNIEJĄCYMI TABELAMI:
- **users** - użytkownicy systemu (twórcy, wykonawcy zadań)
- **sfid_locations** - lokalizacje (zadania są przypisane do lokalizacji)

TYPY PRZYPISANIA ZADAŃ:
- **global** - zadanie widoczne dla wszystkich w lokalizacji
- **user** - zadanie przypisane konkretnemu użytkownikowi  
- **self** - zadanie tylko dla siebie

UPRAWNIENIA UŻYTKOWNIKÓW:
- **user**: może zarządzać swoimi zadaniami, tworzyć zadania globalne w swojej lokalizacji
- **admin**: może zarządzać wszystkimi zadaniami w swojej lokalizacji
- **superadmin**: pełny dostęp do wszystkich zadań we wszystkich lokalizacjach

INDEKSY:
- Wszystkie klucze obce mają indeksy dla wydajności
- Dodatkowe indeksy na często używanych polach (status, due_date, assignment_type)
*/
