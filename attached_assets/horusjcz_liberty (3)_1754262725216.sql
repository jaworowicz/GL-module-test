-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Aug 03, 2025 at 11:28 PM
-- Wersja serwera: 10.5.29-MariaDB-cll-lve
-- Wersja PHP: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `horusjcz_liberty`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `app_menu`
--

CREATE TABLE `app_menu` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `url` varchar(255) NOT NULL,
  `roles` varchar(255) DEFAULT 'user,admin,superadmin',
  `order_position` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `app_menu`
--

INSERT INTO `app_menu` (`id`, `name`, `url`, `roles`, `order_position`) VALUES
(2, 'Zarządzanie ⚙️', '/admin/zarzadzanie.php', 'admin,superadmin', 3),
(4, 'Urlop', '/modules/vacations/request-new.php', 'user,admin,superadmin', 4),
(11, 'Ogłoszenia', '/modules/content/zarzadzanie-ogloszeniami.php', 'admin,superadmin', 9),
(13, '🖍️ Prośby Grafikowe', '/modules/wishes/index.php', 'user,admin,superadmin', 2),
(15, 'Grafik', '/modules/schedules/grafik-5.php', 'user,admin,superadmin', 1),
(17, 'Podsumowanie', '/modules/schedules/grafik-summary.php', 'user,admin,superadmin', 1),
(19, '🎯 KPI', '/modules/licznik2/index.php', 'user,admin,superadmin', 6);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `app_settings`
--

CREATE TABLE `app_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(50) NOT NULL,
  `setting_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`setting_value`)),
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `app_settings`
--

INSERT INTO `app_settings` (`id`, `setting_key`, `setting_value`, `description`) VALUES
(3, 'hidden_employees', '8', NULL),
(8, 'smtp', '{\"host\":\"mail.horus-jcz.pl\",\"port\":587,\"user\":\"workerty@horus-jcz.pl\",\"password\":\"75bTZGPBuHN7GkmC9S7D\"}', NULL),
(9, 'sms_key', '\"djakn33rn3klrnd\"', NULL),
(10, 'sms_password', '\"29dkd93mdkfi3nd\"', NULL),
(12, 'app_info', '{\"name\":\"GrafikLiberty\",\"logo\":\"\\/assets\\/images\\/logo.png\"}', NULL),
(13, 'app_domain', '\"https:\\/\\/workerty.eu\"', NULL),
(15, 'wishes_global_request_limit', '99', NULL),
(16, 'wishes_submission_deadline_range', '\"01-27\"', NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`details`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `details`, `created_at`) VALUES
(1237, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"martyna.pietak@salon.liberty.eu\",\"ip\":\"37.248.221.16\"}', '2025-04-24 13:28:25'),
(1239, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"martyna.pietak@salon.liberty.eu\",\"ip\":\"37.248.221.16\"}', '2025-04-24 13:28:39'),
(1242, NULL, 'login_failed', '{\"reason\":\"invalid_csrf\",\"email\":\"martyna.pietak@salon.liberty.eu\",\"ip\":\"37.248.221.16\"}', '2025-04-24 13:31:55'),
(1399, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"dominik.dechnik@salon.liberty.eu\",\"ip\":\"84.10.5.30\"}', '2025-04-28 09:29:46'),
(2048, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"martyna.pietak@salon.liberty.eu\",\"ip\":\"84.10.5.30\"}', '2025-05-24 12:47:10'),
(2099, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\",\"ip\":\"185.72.186.39\"}', '2025-05-25 12:47:44'),
(2738, 7, 'logout', '{\"timestamp\":\"2025-06-25 13:31:14\",\"ip_address\":\"84.10.5.30\"}', '2025-06-25 11:31:14'),
(3271, 4, 'vacation_approved', '{\"request_id\":\"34\"}', '2025-07-12 13:12:10'),
(3280, 7, 'vacation_requested', '{\"request_id\":\"36\"}', '2025-07-12 13:15:39'),
(3309, 5, 'vacation_requested', '{\"request_id\":\"37\"}', '2025-07-12 13:27:38'),
(3321, 4, 'vacation_approved', '{\"request_id\":\"37\"}', '2025-07-12 13:30:28'),
(3462, 4, 'logout', '{\"timestamp\":\"2025-07-16 11:58:40\",\"ip_address\":\"193.42.98.97\"}', '2025-07-16 09:58:40'),
(3530, 4, 'logout', '{\"timestamp\":\"2025-07-20 08:55:26\",\"ip_address\":\"185.72.184.59\"}', '2025-07-20 06:55:26'),
(3550, 4, 'logout', '{\"timestamp\":\"2025-07-20 09:39:13\",\"ip_address\":\"185.72.184.59\"}', '2025-07-20 07:39:13'),
(3577, 4, 'logout', '{\"timestamp\":\"2025-07-20 10:41:45\",\"ip_address\":\"185.72.184.59\"}', '2025-07-20 08:41:45'),
(3721, 5, 'logout', '{\"timestamp\":\"2025-07-21 00:42:06\",\"ip_address\":\"185.72.184.59\"}', '2025-07-20 22:42:06'),
(3738, 5, 'logout', '{\"timestamp\":\"2025-07-21 00:52:01\",\"ip_address\":\"185.72.184.59\"}', '2025-07-20 22:52:01'),
(3774, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"martyna@salon.liberty.eu\",\"ip\":\"185.72.184.59\"}', '2025-07-21 01:32:59'),
(3779, 4, 'logout', '{\"timestamp\":\"2025-07-21 03:35:29\",\"ip_address\":\"185.72.184.59\"}', '2025-07-21 01:35:29'),
(3819, 4, 'logout', '{\"timestamp\":\"2025-07-21 12:06:28\",\"ip_address\":\"84.10.5.30\"}', '2025-07-21 10:06:28'),
(3869, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"test@test.pl\",\"ip\":\"185.72.184.59\"}', '2025-07-21 21:28:47'),
(3875, 1, 'login_failed', '{\"reason\":\"account_suspended\",\"email\":\"test@test.pl\",\"ip\":\"185.72.184.59\"}', '2025-07-21 21:33:21'),
(3877, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"test@test.pl\",\"ip\":\"185.72.184.59\"}', '2025-07-21 21:33:26'),
(3879, 1, 'login_failed', '{\"reason\":\"account_suspended\",\"email\":\"test@test.pl\",\"ip\":\"185.72.184.59\"}', '2025-07-21 21:33:29'),
(3882, 4, 'profile_update', '{\"target_user_id\":1,\"changes\":[{\"field\":\"name\",\"from\":\"Super Admin\",\"to\":\"Super Admin2\"}]}', '2025-07-21 21:49:40'),
(3885, 1, 'logout', '{\"timestamp\":\"2025-07-21 23:55:14\",\"ip_address\":\"185.72.184.59\"}', '2025-07-21 21:55:14'),
(3892, 1, 'logout', '{\"timestamp\":\"2025-07-21 23:55:52\",\"ip_address\":\"185.72.184.59\"}', '2025-07-21 21:55:52'),
(3895, 1, 'password_change', '{\"target_user_id\":1,\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-21 21:56:17'),
(3897, 1, 'logout', '{\"timestamp\":\"2025-07-21 23:56:21\",\"ip_address\":\"185.72.184.59\"}', '2025-07-21 21:56:21'),
(3900, 1, 'profile_update', '{\"target_user_id\":1,\"changes\":[{\"field\":\"name\",\"from\":\"Super Admin2\",\"to\":\"Super Admin\"}],\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-21 22:08:55'),
(3901, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:09:49'),
(3902, 1, 'logout', '{\"timestamp\":\"2025-07-22 00:09:49\",\"ip_address\":\"185.72.184.59\"}', '2025-07-21 22:09:49'),
(3903, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:09:49'),
(3904, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:09:58'),
(3905, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:31:09'),
(3906, 1, 'logout', '{\"timestamp\":\"2025-07-22 00:31:09\",\"ip_address\":\"185.72.184.59\"}', '2025-07-21 22:31:09'),
(3907, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:31:09'),
(3908, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:31:38'),
(3909, 1, 'user_suspend', '{\"target_user_id\":4,\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-21 22:36:39'),
(3910, 1, 'user_unsuspend', '{\"target_user_id\":4,\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-21 22:36:45'),
(3911, 1, 'user_suspend', '{\"target_user_id\":1,\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-21 22:40:01'),
(3912, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:40:01'),
(3913, 4, 'user_unsuspend', '{\"target_user_id\":1,\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 22:40:16'),
(3914, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:40:28'),
(3915, 1, 'user_suspend', '{\"target_user_id\":1,\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-21 22:42:27'),
(3916, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:42:27'),
(3917, 4, 'user_unsuspend', '{\"target_user_id\":1,\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 22:44:43'),
(3918, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:44:54'),
(3919, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:47:09'),
(3920, 1, 'profile_update', '{\"target_user_id\":1,\"changes\":[{\"field\":\"name\",\"from\":\"Super Admin\",\"to\":\"AdminTest\"}],\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-21 22:47:25'),
(3921, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 22:53:54'),
(3922, 4, 'sfid_update', '{\"sfid_id\":20005056,\"old_data\":{\"id\":\"20005056\",\"name\":\"[TEST] WROCLAVIA\",\"address\":\"ul. Sucha 1, Wrocław\",\"work_hours\":\"{\\\"weekdays\\\": \\\"09:00-21:00\\\", \\\"weekend\\\": \\\"09:00-21:00\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-04-07 02:54:45\",\"is_active\":\"1\"},\"new_data\":{\"name\":\"[TEST] WROCLAVIA\",\"address\":\"ul. Sucha 1, Wrocław\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"10:00-20:00\\\"}\",\"max_monthly_hours\":168,\"id\":20005056},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:04:42'),
(3923, 4, 'sfid_update', '{\"sfid_id\":20005056,\"old_data\":{\"id\":\"20005056\",\"name\":\"[TEST] WROCLAVIA\",\"address\":\"ul. Sucha 1, Wrocław\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"09:00-21:00\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-04-07 02:54:45\",\"is_active\":\"1\"},\"new_data\":{\"id\":\"20005056\",\"new_id\":\"20005056\",\"name\":\"[TEST] WROCLAVIA\",\"address\":\"ul. Sucha 1, Wrocław\",\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"09:00-21:00\",\"max_monthly_hours\":\"168.00\",\"admin_password_confirm\":\"\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:10:42'),
(3924, 4, 'sfid_update', '{\"sfid_id\":20000000,\"old_data\":{\"id\":\"20000000\",\"name\":\"Pasaż Grunwaldzki\",\"address\":\"Pl. Grunwaldzki 22 50-363 Wrocław\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"10:00-20:00\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-04-07 02:54:45\",\"is_active\":\"1\"},\"new_data\":{\"id\":\"20000000\",\"new_id\":\"20000000\",\"name\":\"Pasaż Grunwaldzki\",\"address\":\"Pl. Grunwaldzki 22, 50-363 Wrocław\",\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"10:00-20:00\",\"max_monthly_hours\":\"168.00\",\"admin_password_confirm\":\"\",\"is_active\":\"1\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:11:31'),
(3925, 4, 'sfid_update', '{\"sfid_id\":20000001,\"old_data\":{\"id\":\"20000001\",\"name\":\"[TESTOWY] 01\",\"address\":\"ul. Centralna 1\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-04-07 02:54:45\",\"is_active\":\"1\"},\"new_data\":{\"id\":\"20000001\",\"new_id\":\"20000001\",\"name\":\"Testowa Lokalizacja Główna\",\"address\":\"ul. Centralna 1\",\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"\",\"max_monthly_hours\":\"168.00\",\"admin_password_confirm\":\"\",\"is_active\":\"1\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:11:49'),
(3926, 4, 'sfid_update', '{\"sfid_id\":20005056,\"old_data\":{\"id\":\"20005056\",\"name\":\"[TEST] WROCLAVIA\",\"address\":\"ul. Sucha 1, Wrocław\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"09:00-21:00\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-04-07 02:54:45\",\"is_active\":\"0\"},\"new_data\":{\"id\":\"20005056\",\"new_id\":\"20005056\",\"name\":\"Zawieszony\",\"address\":\"ul. Sucha 1, Wrocław\",\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"09:00-21:00\",\"max_monthly_hours\":\"168.00\",\"admin_password_confirm\":\"\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:12:04'),
(3927, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:29:58'),
(3928, 4, 'sfid_move', '{\"from_sfid\":20000001,\"to_sfid\":29999999,\"moved_users_count\":2,\"updated_schedules_count\":1,\"cloned_working_hours\":2,\"cloned_announcements\":1,\"cloned_cards\":0,\"cloned_invitations\":0,\"old_sfid_deactivated\":true,\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:32:14'),
(3929, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:32:32'),
(3930, 1, 'logout', '{\"timestamp\":\"2025-07-22 01:32:32\",\"ip_address\":\"185.72.184.59\"}', '2025-07-21 23:32:32'),
(3931, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:32:32'),
(3932, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:32:40'),
(3933, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:33:20'),
(3934, 4, 'sfid_move', '{\"from_sfid\":20000000,\"to_sfid\":20004014,\"moved_users_count\":3,\"updated_schedules_count\":543,\"cloned_working_hours\":10,\"cloned_announcements\":1,\"cloned_cards\":0,\"cloned_invitations\":2,\"old_sfid_deactivated\":true,\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:38:39'),
(3935, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:39:00'),
(3936, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:39:21'),
(3937, 4, 'logout', '{\"timestamp\":\"2025-07-22 01:39:21\",\"ip_address\":\"185.72.184.59\"}', '2025-07-21 23:39:21'),
(3938, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:39:21'),
(3939, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:39:25'),
(3940, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:39:37'),
(3941, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:39:40'),
(3942, 4, 'sfid_update', '{\"sfid_id\":20004014,\"old_data\":{\"id\":\"20004014\",\"name\":\"Pasaż Grunwaldzki (Kopia)\",\"address\":\"Pl. Grunwaldzki 22, 50-363 Wrocław\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"10:00-20:00\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-07-22 01:38:39\",\"is_active\":\"1\"},\"new_data\":{\"id\":\"20004014\",\"new_id\":\"20004014\",\"name\":\"Pasaż Grunwaldzki\",\"address\":\"Pl. Grunwaldzki 22, 50-363 Wrocław\",\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"10:00-20:00\",\"max_monthly_hours\":\"168.00\",\"admin_password_confirm\":\"\",\"is_active\":\"1\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:40:24'),
(3943, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:40:40'),
(3944, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:41:07'),
(3945, 4, 'sfid_delete', '{\"deleted_sfid\":{\"id\":\"20000001\",\"name\":\"Testowa Lokalizacja Główna (Zarchiwizowano)\",\"address\":\"ul. Centralna 1\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-04-07 02:54:45\",\"is_active\":\"0\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:41:52'),
(3946, 4, 'sfid_delete', '{\"deleted_sfid\":{\"id\":\"20005056\",\"name\":\"Zawieszony\",\"address\":\"ul. Sucha 1, Wrocław\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"09:00-21:00\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-04-07 02:54:45\",\"is_active\":\"0\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-21 23:41:56'),
(3947, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:42:10'),
(3948, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:42:47'),
(3949, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:42:50'),
(3950, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:42:52'),
(3951, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-21 23:54:55'),
(3952, 4, 'sfid_update', '{\"sfid_id\":20000000,\"old_data\":{\"id\":\"20000000\",\"name\":\"Pasaż Grunwaldzki (Zarchiwizowano)\",\"address\":\"Pl. Grunwaldzki 22, 50-363 Wrocław\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"10:00-20:00\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-04-07 02:54:45\",\"is_active\":\"0\"},\"new_data\":{\"id\":\"20000000\",\"new_id\":\"20000000\",\"name\":\"Zaarchiwizowany PG\",\"address\":\"Pl. Grunwaldzki 22, 50-363 Wrocław\",\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"10:00-20:00\",\"max_monthly_hours\":\"168.00\",\"admin_password_confirm\":\"\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-22 00:02:35'),
(3953, 4, 'sfid_update', '{\"sfid_id\":29999999,\"old_data\":{\"id\":\"29999999\",\"name\":\"Testowa Lokalizacja Główna (Kopia)\",\"address\":\"ul. Centralna 1\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-21:00\\\",\\\"saturday\\\":\\\"09:00-21:00\\\",\\\"sunday\\\":\\\"\\\"}\",\"max_monthly_hours\":\"168.00\",\"created_at\":\"2025-07-22 01:32:14\",\"is_active\":\"1\"},\"new_data\":{\"id\":\"29999999\",\"new_id\":\"29999999\",\"name\":\"Testowa\",\"address\":\"ul. Centralna 1\",\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"\",\"max_monthly_hours\":\"168.00\",\"admin_password_confirm\":\"\",\"is_active\":\"1\"},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-22 00:02:42'),
(3954, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:02:45'),
(3955, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:03:43'),
(3956, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:03:46'),
(3957, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:04:19'),
(3958, 4, 'global_hours_set', '{\"data\":{\"year\":2025,\"month\":9,\"hours\":176},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-22 00:18:28'),
(3959, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:20:09'),
(3960, 1, 'logout', '{\"timestamp\":\"2025-07-22 02:20:09\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 00:20:09'),
(3961, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:20:09'),
(3962, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:20:18'),
(3963, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:20:22'),
(3964, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:20:32'),
(3965, 4, 'logout', '{\"timestamp\":\"2025-07-22 02:20:32\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 00:20:32'),
(3966, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:20:32'),
(3967, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:20:39'),
(3968, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:27:43'),
(3969, 1, 'logout', '{\"timestamp\":\"2025-07-22 02:27:43\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 00:27:43'),
(3970, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:27:43'),
(3971, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:27:49'),
(3972, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:28:42'),
(3973, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:28:47'),
(3974, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:38:24'),
(3975, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:38:32'),
(3976, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:39:39'),
(3977, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:39:44'),
(3978, 1, 'logout', '{\"timestamp\":\"2025-07-22 02:39:44\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 00:39:44'),
(3979, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:39:44'),
(3980, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:40:06'),
(3981, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:40:32'),
(3982, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:49:54'),
(3983, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:53:56'),
(3984, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:54:37'),
(3985, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:57:25'),
(3986, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 00:59:38'),
(3987, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:07:20'),
(3988, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:07:35'),
(3989, 4, 'logout', '{\"timestamp\":\"2025-07-22 03:07:35\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:07:35'),
(3990, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:07:35'),
(3991, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:07:53'),
(3992, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:09:09'),
(3993, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:09:12'),
(3994, 4, 'logout', '{\"timestamp\":\"2025-07-22 03:09:12\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:09:12'),
(3995, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:09:12'),
(3996, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:09:16'),
(3997, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:09:41'),
(3998, 4, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:09:55'),
(3999, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:09:58'),
(4000, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:10:00'),
(4001, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:10:13'),
(4002, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:11:30'),
(4003, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:11:37'),
(4004, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:11:58'),
(4005, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:12:00'),
(4006, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:12:20'),
(4007, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:12:21'),
(4008, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:12:29'),
(4009, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:18:40'),
(4010, 4, 'session_hijacking_detected', '{\"session_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"session_user_agent\":\"NOT_SET\",\"current_user_agent\":\"Mozilla\\/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/138.0.0.0 Safari\\/537.36\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:18:40'),
(4011, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:18:43'),
(4012, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:18:47'),
(4013, 4, 'session_hijacking_detected', '{\"session_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"session_user_agent\":\"NOT_SET\",\"current_user_agent\":\"Mozilla\\/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/138.0.0.0 Safari\\/537.36\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:18:47'),
(4014, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:18:56'),
(4015, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:18:59'),
(4016, 4, 'session_hijacking_detected', '{\"session_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"session_user_agent\":\"NOT_SET\",\"current_user_agent\":\"Mozilla\\/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/138.0.0.0 Safari\\/537.36\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:18:59'),
(4017, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:20:54'),
(4018, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:21:03'),
(4019, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:21:06'),
(4020, 4, 'session_hijacking_detected', '{\"session_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"session_user_agent\":\"NOT_SET\",\"current_user_agent\":\"Mozilla\\/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/138.0.0.0 Safari\\/537.36\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:21:57'),
(4021, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:21:59'),
(4022, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:22:01'),
(4023, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:22:04'),
(4024, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:22:08'),
(4025, 4, 'session_hijacking_detected', '{\"session_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"session_user_agent\":\"NOT_SET\",\"current_user_agent\":\"Mozilla\\/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/138.0.0.0 Safari\\/537.36\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:22:19'),
(4026, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:22:19'),
(4027, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:22:48'),
(4028, 4, 'session_tampering_detected', '{\"session_data\":{\"role\":\"user\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:23:00'),
(4029, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:23:39'),
(4030, 4, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:24:37'),
(4031, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:27:07'),
(4032, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:27:10'),
(4033, 4, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:27:28'),
(4034, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:27:28'),
(4035, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:27:43'),
(4036, 4, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:27:54'),
(4037, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:27:54'),
(4038, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:27:58'),
(4039, 4, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:28:18'),
(4040, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:28:18'),
(4041, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:28:20'),
(4042, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:28:24'),
(4043, 1, 'session_hijacking_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"database_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"session_user_agent\":\"NOT_SET\",\"current_user_agent\":\"Mozilla\\/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit\\/537.36 (KHTML, like Gecko) Chrome\\/138.0.0.0 Safari\\/537.36\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:28:30'),
(4044, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:28:30'),
(4045, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:28:35'),
(4046, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:28:41'),
(4047, 4, 'logout', '{\"timestamp\":\"2025-07-22 03:28:41\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:28:41'),
(4048, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:28:41'),
(4049, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:28:52'),
(4050, 1, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"test@test.pl\"},\"database_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:29:07'),
(4051, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:29:07'),
(4052, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:33:49'),
(4053, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:38:36'),
(4054, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:38:44'),
(4055, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:38:59'),
(4056, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:39:18'),
(4057, 4, 'logout', '{\"timestamp\":\"2025-07-22 03:39:18\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:39:18'),
(4058, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:39:18'),
(4059, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:39:25'),
(4060, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:40:59'),
(4061, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:41:03'),
(4062, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:41:06'),
(4063, 4, 'logout', '{\"timestamp\":\"2025-07-22 03:41:06\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:41:06'),
(4064, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:41:06'),
(4065, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:41:14'),
(4066, 1, 'session_tampering_detected', '{\"session_data\":{\"role\":\"superadmin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"database_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:41:32'),
(4067, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:41:32'),
(4068, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:42:54'),
(4069, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:48:50'),
(4070, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:50:19'),
(4071, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:50:20'),
(4072, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:50:21'),
(4073, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:50:21'),
(4074, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:50:21'),
(4075, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:50:28'),
(4076, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:50:28'),
(4077, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:27'),
(4078, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:30'),
(4079, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:31'),
(4080, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:32'),
(4081, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:33'),
(4082, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:47'),
(4083, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:55'),
(4084, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:57'),
(4085, 4, 'logout', '{\"timestamp\":\"2025-07-22 03:51:57\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 01:51:57'),
(4086, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:51:57'),
(4087, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:52:00'),
(4088, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:52:02'),
(4089, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:52:03'),
(4090, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:53:36'),
(4091, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:53:38'),
(4092, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:53:42'),
(4093, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:53:44'),
(4094, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 01:53:48'),
(4095, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:04:39'),
(4096, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:04:45'),
(4097, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:04:51'),
(4098, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:05:03'),
(4099, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:05:07'),
(4100, 4, 'session_tampering_detected', '{\"session_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20000000\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 02:05:20'),
(4101, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:05:20'),
(4102, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:05:30'),
(4103, 4, 'session_tampering_detected', '{\"session_data\":{\"role\":\"superadmin\",\"sfid_id\":\"29999999\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"database_data\":{\"role\":\"superadmin\",\"sfid_id\":\"20004014\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\"},\"ip_address\":\"185.72.184.59\"}', '2025-07-22 02:05:52'),
(4104, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:05:52'),
(4105, 4, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:09:29'),
(4106, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:09:57'),
(4107, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"test@test.pl\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 02:09:57'),
(4108, 1, 'vacation_approve', '{\"vacation_id\":\"0\",\"status\":\"approved\",\"comment\":\"Zatwierdzono automatycznie\"}', '2025-07-22 02:10:03'),
(4124, 1, 'logout', '{\"timestamp\":\"2025-07-22 04:16:35\",\"ip_address\":\"185.72.184.59\"}', '2025-07-22 02:16:35'),
(4160, 4, 'vacation_restored', '{\"request_id\":20,\"request_owner_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 20:35:40'),
(4161, 4, 'vacation_edited', '{\"request_id\":20,\"request_owner_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 20:36:02'),
(4162, 4, 'vacation_rejected', '{\"request_id\":10,\"request_owner_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 20:37:27'),
(4163, 4, 'vacation_approved', '{\"request_id\":20,\"request_owner_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 20:39:14'),
(4164, 4, 'vacation_edited_by_user', '{\"request_id\":10,\"ip_address\":\"84.39.161.87\"}', '2025-07-23 20:44:15'),
(4165, 4, 'vacation_deleted_by_user', '{\"deleted_request_id\":10,\"ip_address\":\"84.39.161.87\"}', '2025-07-23 20:46:56'),
(4166, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 20:52:47'),
(4167, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 20:57:13'),
(4168, 1, 'vacation_deleted', '{\"deleted_request_id\":6,\"request_owner_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 21:03:15'),
(4169, 1, 'password_change', '{\"target_user_id\":8,\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-23 21:04:37'),
(4170, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 21:04:42'),
(4171, 8, 'vacation_requested', '{\"request_id\":\"38\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 21:05:26'),
(4172, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 21:06:39'),
(4173, 1, 'vacation_rejected', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 21:07:37'),
(4174, 1, 'vacation_deleted', '{\"deleted_request_id\":23,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 21:07:40'),
(4175, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 21:07:47'),
(4176, 4, 'wish_requested', '{\"request_date\":\"2025-08-24\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 22:27:26'),
(4177, 4, 'wish_approved', '{\"request_id\":1,\"owner_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 22:31:27'),
(4178, 4, 'wish_requested', '{\"request_date\":\"2025-08-22\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 22:35:11'),
(4179, 4, 'wish_rejected', '{\"request_id\":2,\"owner_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 22:36:56'),
(4180, 4, 'wish_force_approved', '{\"target_user_id\":4,\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 22:51:47'),
(4181, 4, 'wish_requested', '{\"target_user_id\":5,\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:04:40'),
(4182, 4, 'wish_requested', '{\"target_user_id\":5,\"date\":\"2025-08-02\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:09:35'),
(4183, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-06\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:10:39'),
(4184, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-26\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:37:17'),
(4185, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-27\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:37:33'),
(4186, 4, 'wish_rejected', '{\"request_id\":8,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:37:52'),
(4187, 4, 'wish_permanently_deleted', '{\"deleted_request_id\":8,\"request_owner_id\":\"7\",\"previous_status\":\"rejected\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:41:17'),
(4188, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-27\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:41:42'),
(4189, 4, 'wish_approved', '{\"request_id\":9,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:41:51'),
(4190, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-27\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:44:40'),
(4191, 4, 'wish_rejected', '{\"request_id\":10,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:53:50'),
(4192, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-27\",\"ip_address\":\"84.39.161.87\"}', '2025-07-23 23:54:05'),
(4193, 4, 'wish_rejected', '{\"request_id\":11,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:02:53'),
(4194, 4, 'wish_permanently_deleted', '{\"deleted_request_id\":11,\"request_owner_id\":\"7\",\"previous_status\":\"rejected\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:02:57'),
(4195, 4, 'wish_permanently_deleted', '{\"deleted_request_id\":10,\"request_owner_id\":\"7\",\"previous_status\":\"rejected\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:03:00'),
(4196, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-27\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:03:16'),
(4197, 4, 'wish_rejected', '{\"request_id\":12,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:04:18'),
(4198, 4, 'wish_permanently_deleted', '{\"deleted_request_id\":12,\"request_owner_id\":\"7\",\"previous_status\":\"rejected\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:04:21'),
(4199, 4, 'wish_permanently_deleted', '{\"deleted_request_id\":2,\"request_owner_id\":\"4\",\"previous_status\":\"rejected\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:06:18'),
(4200, 8, 'wish_requested', '{\"target_user_id\":\"8\",\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:28:53'),
(4201, 8, 'wish_edited_by_user', '{\"request_id\":13,\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:29:12'),
(4203, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:44:51'),
(4204, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:45:33'),
(4205, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:47:15'),
(4206, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:47:43');
INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `details`, `created_at`) VALUES
(4207, 8, 'wish_requested', '{\"target_user_id\":\"8\",\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:48:12'),
(4208, 8, 'wish_requested', '{\"target_user_id\":\"8\",\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:48:16'),
(4209, 8, 'wish_requested', '{\"target_user_id\":\"8\",\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:48:19'),
(4210, 8, 'wish_deleted_by_user', '{\"deleted_request_id\":16,\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:48:32'),
(4211, 8, 'wish_requested', '{\"target_user_id\":\"8\",\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:48:44'),
(4212, 8, 'wish_deleted_by_user', '{\"deleted_request_id\":17,\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:48:56'),
(4213, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:49:04'),
(4214, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:49:23'),
(4215, 8, 'wish_requested', '{\"target_user_id\":\"8\",\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:49:41'),
(4216, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:50:01'),
(4217, 1, 'wish_rejected', '{\"request_id\":18,\"owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:50:33'),
(4218, 1, 'wish_force_approved', '{\"target_user_id\":8,\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:51:05'),
(4219, 1, 'wish_force_approved', '{\"target_user_id\":1,\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 00:51:52'),
(4220, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-28\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 01:58:39'),
(4221, 4, 'wish_requested', '{\"target_user_id\":7,\"date\":\"2025-08-30\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 01:58:46'),
(4222, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 02:01:04'),
(4223, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 02:01:25'),
(4224, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 02:44:23'),
(4225, 4, 'logs_deleted_selected', '{\"count\":50,\"summary\":\"vacation_approve (50)\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 02:48:10'),
(4226, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 02:56:51'),
(4228, 4, 'logs_deleted_single', '{\"deleted_log_id\":4227,\"deleted_log_action\":\"logs_deleted_single\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 03:04:46'),
(4229, 4, 'password_change', '{\"target_user_id\":4,\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-24 03:09:56'),
(4230, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 03:10:04'),
(4231, 4, 'profile_update', '{\"target_user_id\":8,\"changes\":[{\"field\":\"personal_number\",\"from\":\"22005250\\n\",\"to\":\"22005250\"},{\"field\":\"email\",\"from\":\"pawel.banach@salon.liberty.eu\",\"to\":\"test@user.pl\"}],\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-24 08:14:54'),
(4232, 4, 'profile_update', '{\"target_user_id\":8,\"changes\":[{\"field\":\"name\",\"from\":\"Paweł Banach\",\"to\":\"User\"}],\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-24 08:15:06'),
(4233, 7, 'wish_deleted_by_user', '{\"deleted_request_id\":21,\"ip_address\":\"84.10.5.30\"}', '2025-07-24 09:27:02'),
(4234, 7, 'wish_deleted_by_user', '{\"deleted_request_id\":22,\"ip_address\":\"84.10.5.30\"}', '2025-07-24 09:27:07'),
(4235, 7, 'wish_requested', '{\"target_user_id\":\"7\",\"date\":\"2025-08-27\",\"ip_address\":\"84.10.5.30\"}', '2025-07-24 09:27:52'),
(4236, 7, 'wish_requested', '{\"target_user_id\":\"7\",\"date\":\"2025-08-28\",\"ip_address\":\"84.10.5.30\"}', '2025-07-24 09:28:07'),
(4237, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:21:12'),
(4238, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:21:23'),
(4239, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:21:33'),
(4240, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:21:48'),
(4241, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:32:38'),
(4242, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:32:59'),
(4243, 8, 'vacation_edited_by_user', '{\"request_id\":38,\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:35:47'),
(4244, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:35:58'),
(4245, 1, 'vacation_approved', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:36:28'),
(4246, 1, 'vacation_edited', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:37:21'),
(4247, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:37:26'),
(4248, 1, 'vacation_approved', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:41:35'),
(4249, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:41:53'),
(4250, 8, 'wish_requested', '{\"target_user_id\":\"8\",\"date\":\"2025-08-02\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:42:45'),
(4251, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:50:04'),
(4252, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 10:52:53'),
(4253, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 12:34:43'),
(4254, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 12:36:46'),
(4255, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 12:49:15'),
(4256, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 12:49:40'),
(4257, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 12:54:22'),
(4258, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 12:54:49'),
(4259, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 12:57:03'),
(4260, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 12:57:33'),
(4261, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:01:34'),
(4262, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:23:29'),
(4263, 1, 'wish_requested', '{\"target_user_id\":8,\"date\":\"2025-08-04\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:25:44'),
(4264, 1, 'wish_approved', '{\"request_id\":26,\"owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:26:13'),
(4265, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:27:16'),
(4266, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:28:32'),
(4267, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:29:01'),
(4268, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:30:00'),
(4269, 1, 'wish_rejected', '{\"request_id\":25,\"owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:32:29'),
(4270, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:32:48'),
(4271, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:41:08'),
(4272, 8, 'vacation_requested', '{\"request_id\":\"39\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:41:45'),
(4273, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:43:44'),
(4274, 1, 'vacation_edited', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:44:43'),
(4275, 1, 'vacation_approved', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:45:07'),
(4276, 1, 'vacation_rejected', '{\"request_id\":39,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:45:09'),
(4277, 1, 'vacation_edited', '{\"request_id\":39,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:45:28'),
(4278, 1, 'vacation_rejected', '{\"request_id\":39,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:57:32'),
(4279, 1, 'vacation_edited', '{\"request_id\":39,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:57:38'),
(4280, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:59:18'),
(4281, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 13:59:28'),
(4282, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:00:21'),
(4283, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:00:28'),
(4284, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:00:35'),
(4285, 1, 'vacation_requested', '{\"request_id\":\"40\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:02:01'),
(4286, 1, 'vacation_rejected', '{\"request_id\":40,\"request_owner_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:02:16'),
(4287, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:02:37'),
(4288, 8, 'vacation_edited_by_user', '{\"request_id\":38,\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:03:11'),
(4289, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:03:39'),
(4290, 1, 'vacation_approved', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:03:51'),
(4291, 1, 'vacation_approved', '{\"request_id\":39,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:04:57'),
(4292, 1, 'vacation_edited', '{\"request_id\":39,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:05:31'),
(4293, 1, 'vacation_rejected', '{\"request_id\":39,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 14:05:37'),
(4294, 7, 'wish_requested', '{\"target_user_id\":\"7\",\"date\":\"2025-08-16\",\"ip_address\":\"84.10.5.30\"}', '2025-07-24 16:34:07'),
(4295, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 18:10:06'),
(4296, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 21:22:51'),
(4297, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 21:29:55'),
(4298, 8, 'wish_requested', '{\"target_user_id\":\"8\",\"date\":\"2025-08-05\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 21:30:19'),
(4299, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 21:38:46'),
(4300, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 21:40:19'),
(4301, 4, 'wish_approved', '{\"request_id\":5,\"owner_id\":\"5\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 21:42:13'),
(4302, 4, 'wish_approved', '{\"request_id\":27,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 21:42:28'),
(4303, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 22:12:40'),
(4304, 1, 'wish_requested', '{\"target_user_id\":1,\"date\":\"2025-08-01\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 22:13:02'),
(4305, 1, 'wish_approved', '{\"request_id\":29,\"owner_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 22:13:07'),
(4306, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 22:21:55'),
(4307, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 22:25:01'),
(4308, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 22:28:08'),
(4309, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 23:13:53'),
(4310, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 23:27:19'),
(4311, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 23:28:37'),
(4312, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-24 23:28:56'),
(4313, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 00:44:09'),
(4314, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 00:44:44'),
(4315, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 01:48:07'),
(4316, 1, 'wish_requested', '{\"target_user_id\":1,\"date\":\"2025-08-05\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 01:48:46'),
(4317, 1, 'wish_approved', '{\"request_id\":30,\"owner_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 01:48:52'),
(4318, 1, 'wish_approved', '{\"request_id\":28,\"owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 01:48:54'),
(4319, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 08:37:13'),
(4320, 4, 'wish_approved', '{\"request_id\":4,\"owner_id\":\"5\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 08:40:59'),
(4321, 4, 'wish_approved', '{\"request_id\":6,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 08:41:04'),
(4322, 4, 'wish_approved', '{\"request_id\":7,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 08:41:09'),
(4323, 4, 'wish_approved', '{\"request_id\":23,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 08:41:11'),
(4324, 4, 'wish_approved', '{\"request_id\":24,\"owner_id\":\"7\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 08:41:12'),
(4325, 5, 'wish_requested', '{\"target_user_id\":\"5\",\"date\":\"2025-08-30\",\"ip_address\":\"37.30.56.121\"}', '2025-07-25 09:42:59'),
(4326, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"jakub.jaworowicz@salon.liberty.eu\",\"ip_address\":\"84.10.5.30\"}', '2025-07-25 10:02:53'),
(4327, 4, 'wish_force_approved', '{\"target_user_id\":5,\"date\":\"2025-08-04\",\"ip_address\":\"84.10.5.30\"}', '2025-07-25 10:07:06'),
(4328, 4, 'vacation_edited_by_user', '{\"request_id\":20,\"ip_address\":\"84.10.5.30\"}', '2025-07-25 10:13:18'),
(4329, 4, 'vacation_approved', '{\"request_id\":20,\"request_owner_id\":\"4\",\"ip_address\":\"84.10.5.30\"}', '2025-07-25 10:13:23'),
(4330, 4, 'wish_force_approved', '{\"target_user_id\":7,\"date\":\"2025-08-25\",\"ip_address\":\"84.10.5.30\"}', '2025-07-25 10:26:48'),
(4331, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 20:48:41'),
(4332, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 20:49:33'),
(4333, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:09:52'),
(4334, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:10:09'),
(4335, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:13:00'),
(4336, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:14:30'),
(4337, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:17:20'),
(4338, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:19:43'),
(4339, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:21:26'),
(4340, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:41:30'),
(4341, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 21:59:33'),
(4342, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:10:18'),
(4343, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:14:34'),
(4344, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:18:36'),
(4345, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:26:48'),
(4346, 1, 'wish_force_approved', '{\"target_user_id\":1,\"date\":\"2025-08-06\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:27:28'),
(4347, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:28:13'),
(4348, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:31:24'),
(4349, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:39:57'),
(4350, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-25 22:40:43'),
(4351, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 00:04:19'),
(4352, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 00:05:48'),
(4353, 1, 'vacation_edited', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 09:06:17'),
(4354, 1, 'vacation_rejected', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 09:06:20'),
(4355, 1, 'vacation_edited', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 09:06:24'),
(4356, 1, 'vacation_rejected', '{\"request_id\":38,\"request_owner_id\":\"8\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 09:06:56'),
(4357, 1, 'vacation_requested', '{\"request_id\":\"41\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 09:07:54'),
(4358, 1, 'vacation_approved', '{\"request_id\":41,\"request_owner_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 09:07:57'),
(4359, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"31.0.78.251\"}', '2025-07-26 16:13:19'),
(4360, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 17:00:40'),
(4361, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 17:02:06'),
(4362, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 17:02:22'),
(4363, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-26 17:03:01'),
(4364, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"185.199.103.67\"}', '2025-07-28 13:26:16'),
(4365, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 20:09:00'),
(4366, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 20:09:41'),
(4367, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 20:09:59'),
(4368, 1, 'wish_requested', '{\"target_user_id\":1,\"date\":\"2025-08-06\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 20:10:14'),
(4369, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 20:10:30'),
(4370, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 20:10:49'),
(4371, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 20:10:57'),
(4372, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 20:22:10'),
(4373, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 21:01:42'),
(4374, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 21:24:33'),
(4375, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 21:29:02'),
(4376, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 21:49:40'),
(4377, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:04:02'),
(4378, 1, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"test@test.pl\"},\"database_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:05:15'),
(4379, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:05:33'),
(4380, 1, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"test@test.pl\"},\"database_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:05:43'),
(4381, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:08:02'),
(4382, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:12:46'),
(4383, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:16:51'),
(4384, 1, 'session_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"test@test.pl\"},\"database_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:18:33'),
(4385, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:18:41'),
(4386, 1, 'sfid_url_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"20004014\",\"email\":\"test@test.pl\"},\"database_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"requested_sfid\":\"20004014\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:23:30'),
(4387, 1, 'sfid_url_tampering_detected', '{\"session_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"database_data\":{\"role\":\"admin\",\"sfid_id\":\"29999999\",\"email\":\"test@test.pl\"},\"requested_sfid\":\"20004014\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:23:42'),
(4388, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:24:01'),
(4389, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-28 22:38:32'),
(4390, 4, 'email_dispatch_success', '{\"recipient_user_id\":4,\"type\":\"schedule_monthly_summary\",\"sfid_context\":20004014,\"is_test_mode\":true,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Jakub, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:16:52'),
(4391, 5, 'email_dispatch_success', '{\"recipient_user_id\":5,\"type\":\"schedule_monthly_summary\",\"sfid_context\":20004014,\"is_test_mode\":true,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Martyna, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:16:52'),
(4392, 7, 'email_dispatch_success', '{\"recipient_user_id\":7,\"type\":\"schedule_monthly_summary\",\"sfid_context\":20004014,\"is_test_mode\":true,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Dominik, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:16:52'),
(4393, 7, 'email_dispatch_success', '{\"recipient_user_id\":7,\"type\":\"schedule_monthly_summary\",\"sfid_context\":20004014,\"is_test_mode\":true,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Dominik, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:17:46'),
(4394, 4, 'email_dispatch_success', '{\"recipient_user_id\":4,\"type\":\"schedule_summary_single\",\"sfid_context\":20004014,\"is_test_mode\":true,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Jakub, grafik dla 20004014 został opublikowany dla 07.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:25:04'),
(4395, 4, 'email_dispatch_success', '{\"recipient_user_id\":4,\"type\":\"schedule_monthly_bulk\",\"sfid_context\":20004014,\"is_test_mode\":true,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Jakub, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:25:32'),
(4396, 5, 'email_dispatch_success', '{\"recipient_user_id\":5,\"type\":\"schedule_monthly_bulk\",\"sfid_context\":20004014,\"is_test_mode\":true,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Martyna, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:25:32'),
(4397, 7, 'email_dispatch_success', '{\"recipient_user_id\":7,\"type\":\"schedule_monthly_bulk\",\"sfid_context\":20004014,\"is_test_mode\":true,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Dominik, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:25:33'),
(4398, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:28:07'),
(4399, 1, 'email_dispatch_success', '{\"recipient_user_id\":1,\"type\":\"schedule_summary_single\",\"sfid_context\":29999999,\"is_test_mode\":true,\"recipient_email\":\"pergamin@abc0.pl\",\"subject\":\"AdminTest, grafik dla 29999999 został opublikowany dla 07.2025\",\"triggered_by_user_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:28:45'),
(4400, 1, 'email_dispatch_success', '{\"recipient_user_id\":1,\"type\":\"schedule_monthly_bulk\",\"sfid_context\":29999999,\"is_test_mode\":true,\"recipient_email\":\"pergamin@abc0.pl\",\"subject\":\"AdminTest, grafik dla 29999999 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:29:35'),
(4401, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:30:33'),
(4402, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:36:55'),
(4403, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:37:23'),
(4404, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 00:38:26'),
(4405, 5, 'email_dispatch_success', '{\"recipient_user_id\":5,\"type\":\"schedule_summary_single\",\"sfid_context\":20004014,\"is_test_mode\":false,\"recipient_email\":\"martyna.pietak@gmail.com\",\"subject\":\"Martyna, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.10.5.30\"}', '2025-07-29 09:42:55'),
(4406, 4, 'sfid_create', '{\"new_sfid_id\":20001325,\"data\":{\"name\":\"ASTRA\",\"address\":\"Horbaczewskiego 4\\/6, 54-130 Wrocław\",\"work_hours\":\"{\\\"weekdays\\\":\\\"09:00-20:00\\\",\\\"saturday\\\":\\\"09:00\\\\u201320:00\\\",\\\"sunday\\\":\\\"\\\"}\",\"max_monthly_hours\":200,\"is_active\":1,\"id\":20001325},\"changed_by\":{\"id\":4,\"email\":\"jakub.jaworowicz@salon.liberty.eu\"}}', '2025-07-29 20:47:57'),
(4407, 4, 'invite_code_created', '{\"code\":\"B28EF97C\",\"sfid_id\":\"20001325\",\"role_type\":\"admin\",\"expires_at\":\"2025-08-10\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 20:48:46'),
(4408, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 20:53:46'),
(4409, 4, 'invite_code_created', '{\"code\":\"9661AE05\",\"sfid_id\":\"29999999\",\"role_type\":\"user\",\"expires_at\":\"2025-08-28\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 21:14:00'),
(4410, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 21:14:23'),
(4411, 9, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 21:22:24'),
(4412, 1, 'user_suspend', '{\"target_user_id\":9,\"changed_by\":{\"id\":1,\"email\":\"test@test.pl\"}}', '2025-07-29 21:22:55'),
(4413, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 21:27:04'),
(4414, 4, 'invite_code_status_changed', '{\"code_id\":7,\"code\":\"9661AE05\",\"new_status\":\"dezaktywowano\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 21:43:22'),
(4415, 4, 'invite_code_status_changed', '{\"code_id\":4,\"code\":\"0A5C8E93\",\"new_status\":\"dezaktywowano\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 21:43:29'),
(4416, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 23:24:46'),
(4417, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 23:42:52'),
(4418, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 23:43:02'),
(4419, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 23:44:29'),
(4420, 4, 'email_dispatch_success', '{\"recipient_user_id\":4,\"type\":\"schedule_monthly_bulk\",\"sfid_context\":20004014,\"is_test_mode\":false,\"recipient_email\":\"kuba@jaworowi.cz\",\"subject\":\"Jakub, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 23:51:24'),
(4421, 5, 'email_dispatch_success', '{\"recipient_user_id\":5,\"type\":\"schedule_monthly_bulk\",\"sfid_context\":20004014,\"is_test_mode\":false,\"recipient_email\":\"martyna.pietak@gmail.com\",\"subject\":\"Martyna, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 23:51:24'),
(4422, 7, 'email_dispatch_success', '{\"recipient_user_id\":7,\"type\":\"schedule_monthly_bulk\",\"sfid_context\":20004014,\"is_test_mode\":false,\"recipient_email\":\"dechnik.dominik@gmail.com\",\"subject\":\"Dominik, grafik dla 20004014 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"4\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 23:51:25'),
(4423, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-29 23:58:51'),
(4424, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-30 00:07:16'),
(4425, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-30 00:20:56'),
(4426, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-07-30 07:07:58'),
(4427, 1, 'vacation_requested', '{\"request_id\":\"42\",\"ip_address\":\"84.39.161.87\"}', '2025-07-30 07:08:44'),
(4428, 1, 'vacation_approved', '{\"request_id\":42,\"request_owner_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-30 07:08:51'),
(4429, 1, 'wish_force_approved', '{\"target_user_id\":1,\"date\":\"2025-08-08\",\"ip_address\":\"84.39.161.87\"}', '2025-07-30 07:21:06'),
(4430, 1, 'wish_approved', '{\"request_id\":35,\"owner_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-30 07:24:57'),
(4431, 1, 'email_dispatch_success', '{\"recipient_user_id\":1,\"type\":\"schedule_monthly_bulk\",\"sfid_context\":29999999,\"is_test_mode\":false,\"recipient_email\":\"pergamin@abc0.pl\",\"subject\":\"AdminTest, grafik dla 29999999 został opublikowany dla 08.2025\",\"triggered_by_user_id\":\"1\",\"ip_address\":\"84.39.161.87\"}', '2025-07-30 07:25:32'),
(4432, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.10.5.30\"}', '2025-07-31 17:03:25'),
(4433, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 07:56:56'),
(4434, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 07:57:25'),
(4435, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 08:04:27'),
(4436, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 08:04:45'),
(4437, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 08:04:57'),
(4438, 8, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 08:06:08'),
(4439, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 08:10:39'),
(4440, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"dominik.dechnik@salon.liberty.eu\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 08:11:02'),
(4441, NULL, 'login_failed', '{\"reason\":\"invalid_credentials\",\"email\":\"dominik.dechnik@salon.liberty.eu\",\"ip_address\":\"84.39.161.87\"}', '2025-08-01 08:11:12'),
(4442, 4, 'kpi_goal_updated', '{\"goal_id\":2,\"action\":\"updated\",\"old_data\":{\"id\":\"2\",\"sfid_id\":\"20004014\",\"name\":\"Aktywno\\u015b\\u0107 telefoniczna\",\"total_goal\":\"400\",\"is_active\":\"1\",\"created_at\":\"2025-08-03 03:57:10\",\"old_linked_counters\":\"4,7,8\"},\"new_data\":{\"name\":\"BAZA\",\"total_goal\":1000,\"linked_counters\":[7,8],\"sfid_id\":\"20004014\"}}', '2025-08-03 02:10:47'),
(4443, 4, 'kpi_goal_updated', '{\"goal_id\":2,\"action\":\"updated\",\"old_data\":{\"id\":\"2\",\"sfid_id\":\"20004014\",\"name\":\"BAZA\",\"total_goal\":\"1000\",\"is_active\":\"1\",\"created_at\":\"2025-08-03 03:57:10\",\"old_linked_counters\":\"7,8\"},\"new_data\":{\"name\":\"Baza TOTAL\",\"total_goal\":1000,\"linked_counters\":[7,8],\"sfid_id\":\"20004014\"}}', '2025-08-03 02:11:45'),
(4444, 4, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-03 13:34:50'),
(4445, 1, 'logout', '{\"result\":\"success\",\"ip_address\":\"84.39.161.87\"}', '2025-08-03 13:35:20');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `dashboard_announcements`
--

CREATE TABLE `dashboard_announcements` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `type` enum('info','success','warning','danger') DEFAULT 'info',
  `sfid_id` int(11) DEFAULT 0,
  `roles` varchar(255) DEFAULT 'user,admin,superadmin',
  `start_date` date DEFAULT curdate(),
  `end_date` date DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_renewed` tinyint(1) DEFAULT 0,
  `original_id` int(11) DEFAULT NULL,
  `priority` int(11) DEFAULT 10
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `dashboard_announcements`
--

INSERT INTO `dashboard_announcements` (`id`, `title`, `content`, `type`, `sfid_id`, `roles`, `start_date`, `end_date`, `active`, `created_at`, `is_renewed`, `original_id`, `priority`) VALUES
(1, 'Testowe ogloszenie ALL', 'to taki tam test', 'warning', NULL, 'user,superadmin', '2025-04-09', '2025-10-31', 0, '2025-04-11 09:56:26', 0, NULL, 10),
(6, 'test', 'test', 'info', NULL, 'user,admin,superadmin', '2025-07-20', NULL, 0, '2025-07-20 08:25:19', 0, NULL, 10),
(8, 'ℹ️ Informacja Administratora', 'Zmiana designu, pewne funkcje mogą być niedostępne.', 'warning', NULL, 'user,admin,superadmin', '2025-07-20', NULL, 0, '2025-07-20 10:01:38', 0, NULL, 10),
(9, '❓ Testy wiedzy - Zbliża się koniec terminu!!!!', 'Termin testów wiedzy jest do: 2025-07-29 23:59	', 'danger', 20000000, 'user,admin,superadmin', '2025-07-20', '2025-07-30', 0, '2025-07-21 09:43:26', 0, NULL, 10),
(10, 'Testowe ogloszenie ALL', 'to taki tam test', 'warning', 29999999, 'user,superadmin', '2025-04-09', '2025-10-31', 0, '2025-07-21 23:32:14', 0, NULL, 10),
(11, '❓ Testy wiedzy - Zbliża się koniec terminu!!!!', 'Termin testów wiedzy jest do: 2025-07-29 23:59	', 'danger', 20004014, 'user,admin,superadmin', '2025-07-20', '2025-07-30', 0, '2025-07-21 23:38:39', 0, NULL, 10),
(12, '📌 WAŻNE! Organizacyjne', 'ttlko testowy sfid', 'danger', 29999999, 'user,admin,superadmin', '2025-07-22', NULL, 0, '2025-07-22 02:11:26', 0, NULL, 10),
(13, '🖍️ Wprowadź proponowane dni wolne!', 'Do 25 lipca odblokowane jest dodawanie próśb grafikowych [dni wolnych]. ', 'warning', NULL, 'user,admin,superadmin', '2025-07-24', NULL, 0, '2025-07-23 23:21:58', 0, NULL, 10),
(14, 'ℹ️ Informacja Administratora', 'Witaj w teście. Poziom uprawnień: ASTRA. W razie problemów napisz maila na kuba@jaworowi.cz lub napisz na WAP. Możesz ukryć to ogłoszenie klikając przycisk X po prawej stronie. ', 'success', 20001325, 'user,admin,superadmin', '2025-07-30', '2025-08-31', 1, '2025-07-30 00:04:52', 0, NULL, 10),
(15, '📢 UWAGA! Zmiana Grafiku', 'test ogłoszenia', 'info', 29999999, 'user,admin,superadmin', '2025-07-30', NULL, 1, '2025-07-30 00:06:10', 0, NULL, 10),
(16, '📢 UWAGA! Zmiana Grafiku', 'Uwaga, Kinga nie zaakceptowała grafiku. Wprowadzono niezbędne poprawki - szczegóły na mailu.', 'danger', 20004014, 'user,admin,superadmin', '2025-07-30', '2025-08-01', 0, '2025-07-30 00:06:56', 0, NULL, 10);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `dashboard_cards`
--

CREATE TABLE `dashboard_cards` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `icon` varchar(50) DEFAULT '?',
  `link` varchar(255) NOT NULL,
  `order_position` int(11) DEFAULT 0,
  `is_global` tinyint(1) DEFAULT 0,
  `sfid_id` int(11) DEFAULT 0,
  `roles` varchar(255) DEFAULT 'user,admin,superadmin',
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Zrzut danych tabeli `dashboard_cards`
--

INSERT INTO `dashboard_cards` (`id`, `title`, `description`, `icon`, `link`, `order_position`, `is_global`, `sfid_id`, `roles`, `active`, `created_at`) VALUES
(1, 'Grafik v5', 'Nowa wersja Grafiku!\r\nNowość: prośby grafikowe prosto z grafiku.\r\nUlepszony wygląd i wiele więcej.', '📆', '/modules/schedules/grafik-5.php', 1, 1, NULL, 'user,admin,superadmin', 1, '2025-04-11 09:23:40'),
(2, 'Grafik OLD', 'Stara wersja grafiku', '📅', '/modules/schedules/schedules-test.php', 2, 1, NULL, 'user,admin,superadmin', 0, '2025-04-11 09:23:40'),
(17, 'Wnioski URLOP', 'Tu dodajemy kiedy leni nie ma w pracy.', '🌴', '/modules/vacations/request.php', 4, 1, NULL, 'user,admin,superadmin', 1, '2025-04-11 09:23:40'),
(18, 'Prośby grafikowe', 'Tylko Pomiędzy 19 a 25 dniem miesiąca!', '🖍️', '/modules/wishes/index.php', 2, 1, NULL, 'user,admin,superadmin', 1, '2025-07-23 23:20:40');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `global_working_hours`
--

CREATE TABLE `global_working_hours` (
  `id` int(11) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `year` year(4) NOT NULL,
  `month` tinyint(4) NOT NULL CHECK (`month` between 1 and 12),
  `hours` decimal(5,2) DEFAULT 160.00,
  `working_days` smallint(5) UNSIGNED DEFAULT NULL CHECK (`working_days` between 0 and 31)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `global_working_hours`
--

INSERT INTO `global_working_hours` (`id`, `sfid_id`, `year`, `month`, `hours`, `working_days`) VALUES
(16, 20004014, '2025', 4, 168.00, NULL),
(17, 20004014, '2025', 5, 160.00, NULL),
(18, 20004014, '2025', 3, 168.00, NULL),
(19, 20004014, '2025', 2, 160.00, NULL),
(20, 20004014, '2025', 6, 168.00, NULL),
(21, 20004014, '2025', 7, 184.00, NULL),
(22, 20004014, '2025', 8, 160.00, 26),
(23, 20004014, '2025', 10, 184.00, 27),
(24, 20004014, '2025', 11, 144.00, 23),
(25, 20004014, '2025', 12, 160.00, 27),
(26, 20004014, '2025', 9, 176.00, 26);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `invitation_codes`
--

CREATE TABLE `invitation_codes` (
  `id` int(11) NOT NULL,
  `code` varchar(16) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `role_type` enum('user','admin') NOT NULL DEFAULT 'user',
  `created_by` int(11) NOT NULL,
  `max_uses` int(11) DEFAULT 1,
  `used_count` int(11) DEFAULT 0,
  `expires_at` datetime NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `invitation_codes`
--

INSERT INTO `invitation_codes` (`id`, `code`, `sfid_id`, `role_type`, `created_by`, `max_uses`, `used_count`, `expires_at`, `is_active`, `created_at`) VALUES
(1, 'SUPER2025', 20000000, 'user', 1, 1, 0, '2025-12-31 00:00:00', 0, '2025-04-07 00:54:45'),
(2, 'TEST555', 20000000, 'user', 4, 1, 0, '2025-12-31 23:59:00', 0, '2025-04-07 02:32:49'),
(3, '6J9F2IPS', 20000000, 'user', 4, 1, 0, '2025-05-11 04:33:00', 0, '2025-04-07 02:33:23'),
(5, '2EBBFCB7', 20004014, 'user', 4, 1, 0, '2025-12-31 23:59:00', 0, '2025-07-21 23:38:39'),
(6, 'B28EF97C', 20001325, 'admin', 4, 1, 0, '2025-09-09 00:00:00', 1, '2025-07-29 20:48:46'),
(7, '9661AE05', 29999999, 'user', 4, 1, 1, '2025-08-28 00:00:00', 0, '2025-07-29 21:14:00'),
(8, 'CB72A2DC', 29999999, 'user', 4, 1, 0, '2025-07-28 00:00:00', 0, '2025-07-29 21:58:51'),
(9, '7EE6292B', 20001325, 'user', 4, 1, 0, '2025-08-28 00:00:00', 1, '2025-07-29 23:09:42'),
(10, '4C135AE8', 20001325, 'user', 4, 1, 0, '2025-08-28 00:00:00', 1, '2025-07-29 23:09:51'),
(11, '48FEDE0C', 20001325, 'user', 4, 1, 0, '2025-08-28 00:00:00', 1, '2025-07-29 23:09:57');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `kpi_goals`
--

CREATE TABLE `kpi_goals` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `counter_id` int(11) DEFAULT NULL,
  `stat_category_id` int(11) DEFAULT NULL,
  `target_daily_value` decimal(10,2) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `status` enum('active','archived') DEFAULT 'active',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `kpi_goals`
--

INSERT INTO `kpi_goals` (`id`, `name`, `description`, `counter_id`, `stat_category_id`, `target_daily_value`, `sfid_id`, `status`, `created_by`, `created_at`) VALUES
(1, 'Pozyskanie', '', 1, NULL, 6.00, 20004014, 'active', 4, '2025-08-01 15:36:00');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `licznik_categories`
--

CREATE TABLE `licznik_categories` (
  `id` int(11) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `color` varchar(7) DEFAULT '#374151',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `licznik_categories`
--

INSERT INTO `licznik_categories` (`id`, `sfid_id`, `name`, `color`, `is_active`, `created_at`) VALUES
(1, 20004014, 'Sprzedaż', '#22c55e', 1, '2025-08-03 01:57:10'),
(2, 20004014, 'Obsługa klienta', '#3b82f6', 1, '2025-08-03 01:57:10'),
(3, 20004014, 'BAZA', '#f59e0b', 1, '2025-08-03 01:57:10'),
(4, 20004014, 'Inne', '#6b7280', 1, '2025-08-03 01:57:10');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `licznik_counters`
--

CREATE TABLE `licznik_counters` (
  `id` int(11) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `increment` int(11) NOT NULL DEFAULT 1,
  `type` enum('number','currency') NOT NULL DEFAULT 'number',
  `symbol` varchar(10) DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `color` varchar(7) DEFAULT '#374151',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `licznik_counters`
--

INSERT INTO `licznik_counters` (`id`, `sfid_id`, `title`, `increment`, `type`, `symbol`, `category_id`, `color`, `is_active`, `is_default`, `sort_order`, `created_at`) VALUES
(1, 20004014, 'Pozyskanie TOTAL', 1, 'number', NULL, 1, '#22c55e', 0, 1, 1, '2025-08-03 01:57:10'),
(2, 20004014, 'Pozyskanie FTTH', 1, 'number', NULL, 1, '#16a34a', 0, 1, 2, '2025-08-03 01:57:10'),
(3, 20004014, 'Zatrzymanie', 1, 'number', NULL, 1, '#15803d', 0, 1, 3, '2025-08-03 01:57:10'),
(4, 20004014, 'Telefony', 1, 'number', NULL, 2, '#3b82f6', 0, 1, 4, '2025-08-03 01:57:10'),
(5, 20004014, 'NKS / Akcesoria', 1, 'number', NULL, 2, '#2563eb', 0, 1, 5, '2025-08-03 01:57:10'),
(6, 20004014, 'VAS', 1, 'number', NULL, 2, '#1d4ed8', 0, 1, 6, '2025-08-03 01:57:10'),
(7, 20004014, 'Odebrane', 1, 'number', NULL, 2, '#1e40af', 0, 1, 7, '2025-08-03 01:57:10'),
(8, 20004014, 'Nieodebrane', 1, 'number', NULL, 2, '#1e3a8a', 0, 1, 8, '2025-08-03 01:57:10'),
(9, 20004014, 'Pozyskanie FTTH', 1, 'number', NULL, 1, '#374151', 1, 0, 9, '2025-08-03 12:14:54'),
(10, 20004014, 'Pozyskanie INNE', 1, 'number', NULL, 1, '#374151', 1, 0, 10, '2025-08-03 12:15:12'),
(11, 20004014, 'Zatrzymanie', 1, 'number', NULL, 2, '#374151', 1, 0, 11, '2025-08-03 12:15:23'),
(12, 20004014, 'VAS SU', 1, 'number', NULL, 4, '#374151', 1, 0, 12, '2025-08-03 12:16:38'),
(13, 20004014, 'VAS INNE', 1, 'number', NULL, 4, '#374151', 1, 0, 13, '2025-08-03 12:16:45'),
(14, 20004014, 'DELTA', 5, 'number', NULL, 1, '#374151', 1, 0, 14, '2025-08-03 12:21:00'),
(15, 20004014, 'Telefony', 1, 'number', NULL, 1, '#374151', 1, 0, 15, '2025-08-03 12:23:53'),
(16, 20004014, 'NKS', 1, 'number', NULL, 1, '#374151', 1, 0, 16, '2025-08-03 12:24:00'),
(17, 20004014, 'Akcesoria', 1, 'number', NULL, 1, '#374151', 1, 0, 17, '2025-08-03 12:24:08'),
(18, 20004014, 'ODEBRANE', 1, 'number', NULL, 3, '#374151', 1, 0, 18, '2025-08-03 12:34:55'),
(19, 20004014, 'ND/OD', 1, 'number', NULL, 3, '#374151', 1, 0, 19, '2025-08-03 12:35:05');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `licznik_daily_values`
--

CREATE TABLE `licznik_daily_values` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `user_id` int(11) NOT NULL,
  `counter_id` int(11) NOT NULL,
  `value` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `licznik_daily_values`
--

INSERT INTO `licznik_daily_values` (`id`, `date`, `user_id`, `counter_id`, `value`, `created_at`, `updated_at`) VALUES
(1, '2025-08-03', 4, 4, 4, '2025-08-03 02:06:46', '2025-08-03 02:12:23'),
(2, '2025-08-03', 4, 1, 30, '2025-08-03 02:06:54', '2025-08-03 12:08:06'),
(3, '2025-08-03', 4, 7, 5, '2025-08-03 02:10:54', '2025-08-03 03:20:10'),
(22, '2025-08-03', 5, 1, 0, '2025-08-03 03:18:03', '2025-08-03 03:19:35'),
(53, '2025-08-03', 4, 8, 4, '2025-08-03 03:20:12', '2025-08-03 03:20:13'),
(59, '2025-08-03', 4, 9, 5, '2025-08-03 12:17:05', '2025-08-03 12:30:11'),
(61, '2025-08-03', 4, 14, 220, '2025-08-03 12:21:07', '2025-08-03 12:33:15'),
(63, '2025-08-03', 4, 11, 39, '2025-08-03 12:28:48', '2025-08-03 12:31:31'),
(70, '2025-08-03', 4, 10, 16, '2025-08-03 12:30:37', '2025-08-03 12:30:43'),
(127, '2025-08-03', 4, 12, 2, '2025-08-03 12:32:34', '2025-08-03 12:32:34'),
(129, '2025-08-03', 4, 13, 4, '2025-08-03 12:32:42', '2025-08-03 12:32:43'),
(192, '2025-08-03', 4, 15, 5, '2025-08-03 12:34:00', '2025-08-03 12:34:01'),
(197, '2025-08-03', 4, 17, 2, '2025-08-03 12:34:03', '2025-08-03 12:34:05');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `licznik_kpi_adjustments`
--

CREATE TABLE `licznik_kpi_adjustments` (
  `id` int(11) NOT NULL,
  `kpi_goal_id` int(11) NOT NULL,
  `month` varchar(7) NOT NULL COMMENT 'Format: YYYY-MM',
  `value` int(11) NOT NULL,
  `reason` text DEFAULT NULL,
  `admin_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `licznik_kpi_goals`
--

CREATE TABLE `licznik_kpi_goals` (
  `id` int(11) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_goal` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `licznik_kpi_goals`
--

INSERT INTO `licznik_kpi_goals` (`id`, `sfid_id`, `name`, `total_goal`, `is_active`, `created_at`) VALUES
(1, 20004014, 'Pozyskanie miesięczne', 157, 0, '2025-08-03 01:57:10'),
(2, 20004014, 'Baza TOTAL', 1000, 0, '2025-08-03 01:57:10'),
(3, 20004014, 'telefony', 10, 0, '2025-08-03 02:54:12'),
(4, 20004014, 'Pozyskanie TOTAL', 157, 1, '2025-08-03 12:17:04'),
(5, 20004014, 'VAS (SU)', 38, 1, '2025-08-03 12:20:27'),
(6, 20004014, 'DELTA', 8000, 1, '2025-08-03 12:21:31'),
(7, 20004014, 'FTTH', 38, 1, '2025-08-03 12:23:05'),
(8, 20004014, 'VAS (INNE)', 78, 1, '2025-08-03 12:24:50'),
(9, 20004014, 'Telefony', 71, 1, '2025-08-03 12:27:28'),
(10, 20004014, 'Akcesoria', 36, 1, '2025-08-03 12:28:10'),
(11, 20004014, 'NKS', 23, 1, '2025-08-03 12:28:26'),
(12, 20004014, 'Zatrzymanie', 400, 1, '2025-08-03 12:31:32'),
(13, 20004014, 'Odebrane', 910, 0, '2025-08-03 12:35:30'),
(14, 20004014, 'BAZA TOTAL', 1560, 1, '2025-08-03 12:35:53'),
(15, 20004014, 'Odebrane', 910, 1, '2025-08-03 12:36:43');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `licznik_kpi_linked_counters`
--

CREATE TABLE `licznik_kpi_linked_counters` (
  `kpi_goal_id` int(11) NOT NULL,
  `counter_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `licznik_kpi_linked_counters`
--

INSERT INTO `licznik_kpi_linked_counters` (`kpi_goal_id`, `counter_id`) VALUES
(1, 1),
(1, 2),
(2, 7),
(2, 8),
(4, 9),
(4, 10),
(5, 12),
(6, 14),
(7, 9),
(8, 13),
(9, 15),
(10, 17),
(11, 16),
(12, 11),
(13, 18),
(14, 18),
(14, 19),
(15, 18);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` enum('vacation_pending','vacation_approved','vacation_rejected','shift_change') NOT NULL,
  `reference_id` int(11) NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `type`, `reference_id`, `is_read`, `created_at`) VALUES
(1, 4, 'vacation_pending', 36, 0, '2025-07-12 13:15:39'),
(2, 4, 'vacation_pending', 37, 0, '2025-07-12 13:27:38');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `password_resets`
--

CREATE TABLE `password_resets` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `pomidor_corrections`
--

CREATE TABLE `pomidor_corrections` (
  `id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `correction_date` date NOT NULL,
  `hours_adjustment` decimal(5,2) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `status` enum('oczekujący','zaakceptowany','odrzucony') NOT NULL DEFAULT 'zaakceptowany',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_polish_ci COMMENT='Korekty godzin pracy (moduł Pomidor)';

--
-- Zrzut danych tabeli `pomidor_corrections`
--

INSERT INTO `pomidor_corrections` (`id`, `employee_id`, `correction_date`, `hours_adjustment`, `reason`, `status`, `approved_by`, `approved_at`, `created_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(2, 7, '2025-07-04', -1.00, 'kino ?!', 'zaakceptowany', NULL, NULL, 4, '2025-07-04 14:45:33', '2025-07-06 15:08:43', NULL),
(3, 4, '2025-07-04', -2.50, 'Sprawy osobiste', 'zaakceptowany', NULL, NULL, 4, '2025-07-04 15:00:46', '2025-07-05 08:34:57', NULL),
(5, 4, '2025-07-05', 2.00, 'Zmiana D27 - nadrobienie', 'zaakceptowany', NULL, NULL, 4, '2025-07-05 08:34:40', NULL, NULL),
(6, 5, '2025-07-05', -4.00, 'SPP', 'zaakceptowany', NULL, NULL, 4, '2025-07-05 12:13:07', NULL, NULL),
(7, 4, '2025-07-07', -0.50, 'SPP', 'zaakceptowany', NULL, NULL, 4, '2025-07-07 15:43:19', '2025-07-07 15:43:28', NULL),
(8, 5, '2025-07-08', -0.50, 'Anty-L4', 'zaakceptowany', NULL, NULL, 4, '2025-07-08 16:22:12', '2025-07-08 16:22:17', NULL),
(9, 5, '2025-07-09', -3.00, 'spp', 'zaakceptowany', NULL, NULL, 4, '2025-07-09 15:32:20', NULL, NULL),
(10, 7, '2025-07-10', 0.50, 'nadr', 'zaakceptowany', NULL, NULL, 4, '2025-07-09 15:33:34', NULL, NULL),
(11, 7, '2025-07-12', 0.50, 'bo tak xD', 'zaakceptowany', NULL, NULL, 4, '2025-07-12 13:08:57', NULL, NULL),
(12, 4, '2025-07-15', -0.50, 'spoz', 'zaakceptowany', NULL, NULL, 4, '2025-07-15 13:52:35', NULL, NULL),
(13, 7, '2025-07-16', 1.00, '2 poz', 'zaakceptowany', NULL, NULL, 4, '2025-07-16 17:31:06', NULL, NULL),
(26, 4, '2025-07-21', 0.50, 'test ostateczny button', 'zaakceptowany', 4, '2025-07-21 02:48:08', 5, '2025-07-21 00:46:01', '2025-07-21 00:48:34', '2025-07-21 00:48:34'),
(27, 4, '2025-07-21', 0.50, 'test', 'zaakceptowany', 4, '2025-07-21 02:49:25', 4, '2025-07-21 00:49:25', '2025-07-21 00:49:50', '2025-07-21 00:49:50'),
(28, 4, '2025-07-21', 0.50, 'test', 'zaakceptowany', 4, '2025-07-21 02:52:04', 5, '2025-07-21 00:50:57', '2025-07-21 01:04:05', '2025-07-21 01:04:05'),
(29, 4, '2025-07-21', 0.50, 'test', 'zaakceptowany', 4, '2025-07-21 03:04:41', 4, '2025-07-21 01:02:21', '2025-07-21 01:05:13', '2025-07-21 01:05:13'),
(30, 5, '2025-07-21', 0.50, 'Test mobile', 'odrzucony', 4, '2025-07-21 03:35:19', 5, '2025-07-21 01:33:59', '2025-07-21 01:35:19', NULL),
(31, 5, '2025-07-21', 1.50, 'HO', 'zaakceptowany', 4, '2025-07-21 12:31:52', 4, '2025-07-21 10:31:52', NULL, NULL),
(32, 5, '2025-07-21', 1.00, 'jestem leniwa', 'zaakceptowany', 4, '2025-07-21 17:50:14', 5, '2025-07-21 15:48:44', '2025-07-21 15:50:14', NULL),
(33, 5, '2025-07-23', 1.00, 'SPRZATENE PRZED PRACĄ + WYJSCIE POZNIEJ 22/07', 'zaakceptowany', 4, '2025-07-23 19:27:21', 5, '2025-07-23 16:13:05', '2025-07-23 17:27:21', NULL),
(34, 4, '2025-07-23', 0.50, 'administracja', 'zaakceptowany', 4, '2025-07-23 19:27:46', 4, '2025-07-23 17:27:46', NULL, NULL),
(35, 8, '2025-07-24', -0.50, 'wyjscie do lekarza', 'zaakceptowany', 1, '2025-07-24 14:52:29', 8, '2025-07-24 12:49:31', '2025-07-24 12:56:59', '2025-07-24 12:56:59'),
(36, 8, '2025-07-24', 0.50, 'odrobienie', 'zaakceptowany', 1, '2025-07-24 14:53:50', 1, '2025-07-24 12:53:50', '2025-07-24 12:54:17', '2025-07-24 12:54:17'),
(37, 8, '2025-07-24', 0.50, 'wniodsek', 'zaakceptowany', 1, '2025-07-24 14:55:24', 8, '2025-07-24 12:54:43', '2025-07-24 12:56:56', '2025-07-24 12:56:56'),
(38, 8, '2025-07-24', -0.50, 'lekarz', 'zaakceptowany', 1, '2025-07-24 14:56:40', 1, '2025-07-24 12:56:40', '2025-07-24 12:56:53', '2025-07-24 12:56:53'),
(39, 8, '2025-07-24', -0.50, 'wyjscie', 'zaakceptowany', 1, '2025-07-24 14:59:59', 8, '2025-07-24 12:57:18', '2025-07-24 12:59:59', NULL),
(41, 8, '2025-07-24', 0.50, 'odrobienie', 'zaakceptowany', 1, '2025-07-24 15:01:05', 1, '2025-07-24 13:01:05', NULL, NULL),
(42, 7, '2025-07-25', 0.50, 'byłem o 8,30', 'zaakceptowany', 4, '2025-07-25 10:50:19', 7, '2025-07-25 06:51:15', '2025-07-25 08:50:19', NULL),
(43, 5, '2025-07-29', -3.00, 'urodziny Tymka', 'zaakceptowany', 4, '2025-07-29 19:37:35', 5, '2025-07-29 15:23:36', '2025-07-29 17:37:51', NULL),
(44, 4, '2025-07-30', 1.00, 'Sprzątanie', 'zaakceptowany', 4, '2025-07-30 21:52:15', 4, '2025-07-30 19:52:15', NULL, NULL),
(45, 5, '2025-07-31', 5.50, 'odr', 'zaakceptowany', 4, '2025-07-31 13:45:33', 4, '2025-07-31 11:45:33', NULL, NULL),
(46, 4, '2025-07-31', 3.00, 'sniadanie', 'zaakceptowany', 4, '2025-07-31 13:46:37', 4, '2025-07-31 11:46:37', NULL, NULL),
(47, 4, '2025-08-01', -1.00, 'wyrownanie', 'zaakceptowany', 4, '2025-08-01 12:11:03', 4, '2025-08-01 10:11:03', NULL, NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `schedules`
--

CREATE TABLE `schedules` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `shift_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `schedules`
--

INSERT INTO `schedules` (`id`, `user_id`, `shift_id`, `date`, `sfid_id`, `created_at`) VALUES
(17, 5, 772, '2025-04-26', 20004014, '2025-04-09 09:19:35'),
(33, 8, 818, '2025-04-02', 20004014, '2025-04-13 11:45:55'),
(35, 8, 772, '2025-04-04', 20004014, '2025-04-13 11:46:05'),
(36, 8, 751, '2025-04-07', 20004014, '2025-04-13 11:46:42'),
(37, 8, 766, '2025-04-08', 20004014, '2025-04-13 11:46:48'),
(38, 8, 766, '2025-04-09', 20004014, '2025-04-13 11:46:56'),
(41, 8, 798, '2025-04-13', 20004014, '2025-04-13 11:48:37'),
(44, 8, 772, '2025-04-16', 20004014, '2025-04-13 11:49:23'),
(53, 8, 772, '2025-04-30', 20004014, '2025-04-13 11:50:40'),
(55, 7, 772, '2025-04-01', 20004014, '2025-04-13 11:51:30'),
(56, 4, 768, '2025-04-02', 20004014, '2025-04-13 11:52:51'),
(57, 4, 808, '2025-04-03', 20004014, '2025-04-13 11:52:57'),
(58, 4, 808, '2025-04-04', 20004014, '2025-04-13 11:52:59'),
(59, 4, 772, '2025-04-05', 20004014, '2025-04-13 11:53:02'),
(60, 4, 827, '2025-04-07', 20004014, '2025-04-13 11:53:11'),
(61, 4, 810, '2025-04-08', 20004014, '2025-04-13 11:53:15'),
(62, 4, 841, '2025-04-09', 20004014, '2025-04-13 11:53:23'),
(63, 4, 772, '2025-04-10', 20004014, '2025-04-13 11:53:26'),
(64, 4, 841, '2025-04-11', 20004014, '2025-04-13 11:53:30'),
(65, 4, 772, '2025-04-12', 20004014, '2025-04-13 11:53:38'),
(66, 4, 827, '2025-04-14', 20004014, '2025-04-13 11:53:52'),
(67, 4, 827, '2025-04-15', 20004014, '2025-04-13 11:53:54'),
(70, 4, 761, '2025-04-19', 20004014, '2025-04-13 11:54:18'),
(75, 4, 762, '2025-04-28', 20004014, '2025-04-13 11:55:06'),
(76, 4, 762, '2025-04-29', 20004014, '2025-04-13 11:55:09'),
(78, 7, 771, '2025-04-02', 20004014, '2025-04-13 11:56:57'),
(79, 7, 771, '2025-04-03', 20004014, '2025-04-13 11:57:01'),
(80, 7, 810, '2025-04-04', 20004014, '2025-04-13 11:57:09'),
(81, 7, 768, '2025-04-07', 20004014, '2025-04-13 11:57:22'),
(85, 7, 772, '2025-04-25', 20004014, '2025-04-13 12:04:21'),
(86, 7, 772, '2025-04-26', 20004014, '2025-04-13 12:04:25'),
(87, 7, 798, '2025-04-27', 20004014, '2025-04-13 12:04:30'),
(90, 7, 766, '2025-04-14', 20004014, '2025-04-13 12:05:22'),
(91, 7, 766, '2025-04-15', 20004014, '2025-04-13 12:05:30'),
(96, 7, 810, '2025-04-28', 20004014, '2025-04-13 12:08:04'),
(98, 7, 772, '2025-04-17', 20004014, '2025-04-13 12:28:11'),
(101, 5, 762, '2025-04-14', 20004014, '2025-04-13 12:32:55'),
(102, 5, 772, '2025-04-15', 20004014, '2025-04-13 12:33:03'),
(103, 8, 772, '2025-04-18', 20004014, '2025-04-13 12:36:06'),
(104, 8, 772, '2025-04-22', 20004014, '2025-04-13 12:36:45'),
(106, 8, 772, '2025-04-26', 20004014, '2025-04-13 12:37:21'),
(108, 8, 827, '2025-04-03', 20004014, '2025-04-13 12:39:52'),
(109, 8, 772, '2025-04-29', 20004014, '2025-04-13 12:48:52'),
(110, 8, 772, '2025-04-11', 20004014, '2025-04-13 12:49:54'),
(112, 8, 768, '2025-04-10', 20004014, '2025-04-13 12:50:42'),
(114, 7, 827, '2025-04-16', 20004014, '2025-04-13 16:43:00'),
(118, 8, 772, '2025-04-17', 20004014, '2025-04-14 12:49:42'),
(120, 5, 766, '2025-04-17', 20004014, '2025-04-14 12:52:58'),
(121, 4, 762, '2025-04-25', 20004014, '2025-04-14 12:54:25'),
(123, 5, 766, '2025-04-16', 20004014, '2025-04-14 12:55:46'),
(124, 7, 772, '2025-04-12', 20004014, '2025-04-14 14:05:45'),
(127, 8, 878, '2025-04-01', 20004014, '2025-04-15 09:50:22'),
(128, 4, 878, '2025-04-01', 20004014, '2025-04-15 10:02:27'),
(129, 4, 880, '2025-04-06', 20004014, '2025-04-15 10:02:34'),
(130, 5, 880, '2025-04-06', 20004014, '2025-04-15 10:02:41'),
(131, 8, 880, '2025-04-06', 20004014, '2025-04-15 10:02:47'),
(132, 7, 880, '2025-04-06', 20004014, '2025-04-15 10:02:52'),
(133, 5, 879, '2025-04-05', 20004014, '2025-04-15 10:02:56'),
(134, 8, 879, '2025-04-05', 20004014, '2025-04-15 10:03:01'),
(135, 7, 879, '2025-04-05', 20004014, '2025-04-15 10:03:05'),
(136, 4, 880, '2025-04-13', 20004014, '2025-04-15 10:03:19'),
(137, 5, 880, '2025-04-13', 20004014, '2025-04-15 10:03:25'),
(138, 7, 880, '2025-04-13', 20004014, '2025-04-15 10:03:31'),
(139, 5, 879, '2025-04-12', 20004014, '2025-04-15 10:03:36'),
(140, 8, 879, '2025-04-12', 20004014, '2025-04-15 10:03:39'),
(141, 7, 879, '2025-04-11', 20004014, '2025-04-15 10:03:47'),
(142, 7, 878, '2025-04-10', 20004014, '2025-04-15 10:03:52'),
(143, 7, 878, '2025-04-09', 20004014, '2025-04-15 10:03:56'),
(144, 7, 878, '2025-04-08', 20004014, '2025-04-15 10:04:03'),
(145, 4, 880, '2025-04-20', 20004014, '2025-04-15 10:04:21'),
(146, 5, 880, '2025-04-20', 20004014, '2025-04-15 10:04:25'),
(147, 8, 880, '2025-04-20', 20004014, '2025-04-15 10:04:29'),
(148, 7, 880, '2025-04-20', 20004014, '2025-04-15 10:04:34'),
(149, 5, 879, '2025-04-19', 20004014, '2025-04-15 10:04:38'),
(150, 8, 879, '2025-04-19', 20004014, '2025-04-15 10:04:42'),
(151, 7, 879, '2025-04-19', 20004014, '2025-04-15 10:04:45'),
(152, 5, 878, '2025-04-18', 20004014, '2025-04-15 10:04:54'),
(153, 4, 879, '2025-04-16', 20004014, '2025-04-15 10:05:01'),
(154, 4, 878, '2025-04-17', 20004014, '2025-04-15 10:05:05'),
(155, 8, 878, '2025-04-14', 20004014, '2025-04-15 10:05:12'),
(156, 8, 878, '2025-04-15', 20004014, '2025-04-15 10:05:15'),
(159, 8, 879, '2025-04-23', 20004014, '2025-04-15 10:06:46'),
(160, 7, 879, '2025-04-23', 20004014, '2025-04-15 10:06:50'),
(161, 8, 878, '2025-04-24', 20004014, '2025-04-15 10:06:54'),
(163, 8, 878, '2025-04-25', 20004014, '2025-04-15 10:07:01'),
(164, 4, 879, '2025-04-26', 20004014, '2025-04-15 10:07:05'),
(165, 4, 880, '2025-04-27', 20004014, '2025-04-15 10:07:09'),
(166, 5, 880, '2025-04-27', 20004014, '2025-04-15 10:07:13'),
(168, 8, 880, '2025-04-27', 20004014, '2025-04-15 10:07:27'),
(170, 8, 878, '2025-04-28', 20004014, '2025-04-15 10:07:44'),
(174, 8, 876, '2025-06-14', 20004014, '2025-04-15 12:10:57'),
(178, 4, 880, '2025-05-01', 20004014, '2025-04-15 17:10:23'),
(179, 5, 880, '2025-05-01', 20004014, '2025-04-15 17:10:27'),
(180, 8, 880, '2025-05-01', 20004014, '2025-04-15 17:10:30'),
(181, 7, 880, '2025-05-01', 20004014, '2025-04-15 17:10:33'),
(182, 4, 880, '2025-05-03', 20004014, '2025-04-15 17:10:37'),
(185, 8, 880, '2025-05-03', 20004014, '2025-04-15 17:10:49'),
(186, 5, 772, '2025-05-02', 20004014, '2025-04-15 17:11:01'),
(189, 7, 766, '2025-04-18', 20004014, '2025-04-18 13:06:00'),
(190, 4, 827, '2025-04-18', 20004014, '2025-04-18 13:06:12'),
(197, 5, 772, '2025-05-05', 20004014, '2025-04-18 15:44:17'),
(198, 4, 808, '2025-05-05', 20004014, '2025-04-18 15:44:25'),
(200, 4, 772, '2025-05-06', 20004014, '2025-04-18 15:46:04'),
(211, 4, 881, '2025-05-02', 20004014, '2025-04-18 15:52:29'),
(212, 4, 880, '2025-05-04', 20004014, '2025-04-18 15:52:38'),
(213, 5, 880, '2025-05-04', 20004014, '2025-04-18 15:52:41'),
(214, 7, 880, '2025-05-04', 20004014, '2025-04-18 15:52:45'),
(215, 8, 880, '2025-05-04', 20004014, '2025-04-18 15:52:48'),
(216, 5, 772, '2025-04-22', 20004014, '2025-04-21 20:29:01'),
(217, 4, 827, '2025-04-22', 20004014, '2025-04-21 20:29:22'),
(219, 7, 878, '2025-04-22', 20004014, '2025-04-21 20:29:42'),
(221, 5, 765, '2025-04-23', 20004014, '2025-04-21 20:30:35'),
(222, 4, 827, '2025-04-23', 20004014, '2025-04-21 20:30:52'),
(226, 5, 879, '2025-04-24', 20004014, '2025-04-21 20:32:56'),
(227, 4, 879, '2025-02-01', 20004014, '2025-04-23 12:27:00'),
(228, 4, 880, '2025-02-02', 20004014, '2025-04-23 12:27:08'),
(229, 8, 772, '2025-02-01', 20004014, '2025-04-23 12:27:35'),
(230, 8, 880, '2025-02-02', 20004014, '2025-04-23 12:27:39'),
(231, 4, 772, '2025-02-03', 20004014, '2025-04-23 12:30:45'),
(232, 4, 772, '2025-02-04', 20004014, '2025-04-23 12:30:49'),
(233, 4, 879, '2025-02-05', 20004014, '2025-04-23 12:30:56'),
(234, 4, 827, '2025-02-06', 20004014, '2025-04-23 12:31:07'),
(235, 4, 766, '2025-02-07', 20004014, '2025-04-23 12:31:14'),
(236, 4, 808, '2025-02-08', 20004014, '2025-04-23 12:31:28'),
(237, 4, 880, '2025-02-09', 20004014, '2025-04-23 12:31:32'),
(238, 4, 827, '2025-02-10', 20004014, '2025-04-23 12:32:17'),
(239, 4, 766, '2025-02-11', 20004014, '2025-04-23 12:32:24'),
(240, 4, 772, '2025-02-12', 20004014, '2025-04-23 12:32:31'),
(241, 4, 879, '2025-02-13', 20004014, '2025-04-23 12:32:42'),
(242, 4, 762, '2025-02-14', 20004014, '2025-04-23 12:32:55'),
(243, 4, 772, '2025-02-15', 20004014, '2025-04-23 12:33:04'),
(244, 4, 880, '2025-02-16', 20004014, '2025-04-23 12:33:16'),
(245, 4, 879, '2025-02-17', 20004014, '2025-04-23 12:33:39'),
(246, 4, 841, '2025-02-18', 20004014, '2025-04-23 12:33:53'),
(247, 4, 762, '2025-02-19', 20004014, '2025-04-23 12:34:06'),
(248, 4, 805, '2025-02-20', 20004014, '2025-04-23 12:34:14'),
(249, 4, 879, '2025-02-22', 20004014, '2025-04-23 12:35:27'),
(250, 4, 880, '2025-02-23', 20004014, '2025-04-23 12:35:31'),
(251, 4, 879, '2025-03-01', 20004014, '2025-04-23 12:36:08'),
(252, 4, 880, '2025-03-02', 20004014, '2025-04-23 12:36:11'),
(253, 4, 879, '2025-03-08', 20004014, '2025-04-23 12:49:03'),
(254, 4, 880, '2025-03-09', 20004014, '2025-04-23 12:49:06'),
(255, 4, 841, '2025-03-10', 20004014, '2025-04-23 12:49:18'),
(256, 4, 772, '2025-03-11', 20004014, '2025-04-23 12:49:26'),
(257, 4, 772, '2025-03-12', 20004014, '2025-04-23 12:49:33'),
(258, 4, 772, '2025-03-13', 20004014, '2025-04-23 12:49:36'),
(259, 4, 772, '2025-03-14', 20004014, '2025-04-23 12:49:42'),
(260, 4, 879, '2025-03-15', 20004014, '2025-04-23 12:49:49'),
(261, 4, 880, '2025-03-16', 20004014, '2025-04-23 12:49:52'),
(262, 4, 879, '2025-03-17', 20004014, '2025-04-23 12:50:14'),
(263, 4, 768, '2025-03-21', 20004014, '2025-04-23 12:50:23'),
(264, 4, 768, '2025-03-26', 20004014, '2025-04-23 12:50:42'),
(265, 4, 772, '2025-03-28', 20004014, '2025-04-23 12:50:56'),
(266, 4, 766, '2025-03-29', 20004014, '2025-04-23 12:51:04'),
(267, 4, 772, '2025-03-31', 20004014, '2025-04-23 12:51:18'),
(268, 4, 878, '2025-03-18', 20004014, '2025-04-23 12:52:10'),
(269, 4, 878, '2025-03-19', 20004014, '2025-04-23 12:52:14'),
(270, 4, 878, '2025-03-20', 20004014, '2025-04-23 12:52:17'),
(271, 4, 879, '2025-03-22', 20004014, '2025-04-23 12:52:19'),
(272, 4, 879, '2025-03-23', 20004014, '2025-04-23 12:52:22'),
(273, 4, 879, '2025-03-24', 20004014, '2025-04-23 12:52:27'),
(274, 4, 878, '2025-03-25', 20004014, '2025-04-23 12:52:32'),
(275, 4, 878, '2025-03-27', 20004014, '2025-04-23 12:52:55'),
(276, 8, 772, '2025-02-05', 20004014, '2025-04-23 13:20:15'),
(277, 8, 762, '2025-02-06', 20004014, '2025-04-23 13:20:26'),
(278, 8, 827, '2025-02-07', 20004014, '2025-04-23 13:20:35'),
(279, 8, 772, '2025-02-08', 20004014, '2025-04-23 13:20:43'),
(280, 8, 880, '2025-02-09', 20004014, '2025-04-23 13:20:48'),
(281, 8, 766, '2025-02-10', 20004014, '2025-04-23 13:21:23'),
(282, 8, 841, '2025-02-11', 20004014, '2025-04-23 13:21:34'),
(283, 8, 879, '2025-02-12', 20004014, '2025-04-23 13:21:42'),
(284, 8, 772, '2025-02-13', 20004014, '2025-04-23 13:22:31'),
(285, 8, 827, '2025-02-14', 20004014, '2025-04-23 13:22:42'),
(286, 8, 879, '2025-02-15', 20004014, '2025-04-23 13:22:49'),
(287, 8, 880, '2025-02-16', 20004014, '2025-04-23 13:22:52'),
(288, 8, 772, '2025-02-17', 20004014, '2025-04-23 13:23:21'),
(289, 8, 879, '2025-02-18', 20004014, '2025-04-23 13:23:40'),
(290, 8, 841, '2025-02-19', 20004014, '2025-04-23 13:23:50'),
(291, 8, 878, '2025-02-20', 20004014, '2025-04-23 13:24:01'),
(292, 8, 805, '2025-02-21', 20004014, '2025-04-23 13:24:26'),
(293, 8, 762, '2025-02-22', 20004014, '2025-04-23 13:25:32'),
(294, 8, 880, '2025-02-23', 20004014, '2025-04-23 13:25:38'),
(295, 8, 879, '2025-02-24', 20004014, '2025-04-23 13:25:50'),
(296, 8, 772, '2025-02-25', 20004014, '2025-04-23 13:26:12'),
(297, 8, 762, '2025-02-26', 20004014, '2025-04-23 13:27:03'),
(298, 8, 762, '2025-02-27', 20004014, '2025-04-23 13:27:10'),
(299, 8, 762, '2025-02-28', 20004014, '2025-04-23 13:27:14'),
(301, 8, 880, '2025-03-02', 20004014, '2025-04-23 13:27:21'),
(302, 8, 772, '2025-03-01', 20004014, '2025-04-23 13:53:46'),
(303, 8, 772, '2025-03-03', 20004014, '2025-04-23 13:54:03'),
(304, 8, 879, '2025-03-04', 20004014, '2025-04-23 13:54:11'),
(305, 8, 827, '2025-03-05', 20004014, '2025-04-23 13:54:25'),
(306, 8, 827, '2025-03-06', 20004014, '2025-04-23 13:55:00'),
(307, 8, 827, '2025-03-07', 20004014, '2025-04-23 13:55:05'),
(309, 8, 879, '2025-03-08', 20004014, '2025-04-23 13:55:17'),
(311, 8, 880, '2025-03-09', 20004014, '2025-04-23 13:59:01'),
(312, 8, 772, '2025-03-10', 20004014, '2025-04-23 13:59:12'),
(313, 8, 772, '2025-03-11', 20004014, '2025-04-23 13:59:17'),
(314, 8, 772, '2025-03-12', 20004014, '2025-04-23 13:59:21'),
(315, 8, 772, '2025-03-13', 20004014, '2025-04-23 13:59:27'),
(316, 8, 766, '2025-03-14', 20004014, '2025-04-23 13:59:36'),
(317, 8, 879, '2025-03-15', 20004014, '2025-04-23 13:59:41'),
(318, 8, 880, '2025-03-16', 20004014, '2025-04-23 13:59:45'),
(319, 8, 878, '2025-03-17', 20004014, '2025-04-23 14:00:02'),
(320, 8, 878, '2025-03-18', 20004014, '2025-04-23 14:00:06'),
(321, 8, 766, '2025-03-19', 20004014, '2025-04-23 14:03:21'),
(322, 8, 766, '2025-03-20', 20004014, '2025-04-23 14:03:27'),
(323, 8, 766, '2025-03-21', 20004014, '2025-04-23 14:03:33'),
(324, 8, 879, '2025-03-22', 20004014, '2025-04-23 14:03:36'),
(325, 8, 879, '2025-03-23', 20004014, '2025-04-23 14:03:39'),
(326, 8, 878, '2025-03-24', 20004014, '2025-04-23 14:03:48'),
(327, 8, 766, '2025-03-25', 20004014, '2025-04-23 14:03:57'),
(328, 8, 879, '2025-03-26', 20004014, '2025-04-23 14:04:01'),
(329, 8, 878, '2025-03-27', 20004014, '2025-04-23 14:04:10'),
(330, 8, 772, '2025-03-28', 20004014, '2025-04-23 14:04:16'),
(331, 8, 766, '2025-03-29', 20004014, '2025-04-23 14:04:24'),
(332, 8, 880, '2025-03-30', 20004014, '2025-04-23 14:04:31'),
(333, 4, 880, '2025-03-30', 20004014, '2025-04-23 14:04:34'),
(334, 8, 772, '2025-03-31', 20004014, '2025-04-23 14:04:46'),
(336, 7, 764, '2025-04-24', 20004014, '2025-04-24 10:49:42'),
(337, 5, 841, '2025-04-25', 20004014, '2025-04-24 13:19:06'),
(341, 5, 879, '2025-04-28', 20004014, '2025-04-24 13:21:34'),
(343, 4, 841, '2025-04-30', 20004014, '2025-04-24 13:23:52'),
(344, 7, 879, '2025-03-01', 20004014, '2025-04-24 13:32:51'),
(345, 7, 880, '2025-03-02', 20004014, '2025-04-24 13:32:55'),
(346, 7, 878, '2025-03-03', 20004014, '2025-04-24 13:33:01'),
(347, 7, 772, '2025-03-04', 20004014, '2025-04-24 13:33:05'),
(348, 7, 770, '2025-03-05', 20004014, '2025-04-24 13:33:17'),
(349, 7, 770, '2025-03-06', 20004014, '2025-04-24 13:33:21'),
(350, 7, 770, '2025-03-07', 20004014, '2025-04-24 13:33:24'),
(351, 7, 880, '2025-03-09', 20004014, '2025-04-24 13:33:32'),
(352, 7, 772, '2025-03-08', 20004014, '2025-04-24 13:33:35'),
(353, 7, 878, '2025-03-10', 20004014, '2025-04-24 13:33:47'),
(354, 7, 772, '2025-03-11', 20004014, '2025-04-24 13:33:54'),
(355, 7, 772, '2025-03-12', 20004014, '2025-04-24 13:34:00'),
(356, 7, 772, '2025-03-13', 20004014, '2025-04-24 13:34:14'),
(357, 7, 772, '2025-03-14', 20004014, '2025-04-24 13:34:18'),
(358, 7, 879, '2025-03-15', 20004014, '2025-04-24 13:34:28'),
(359, 7, 880, '2025-03-16', 20004014, '2025-04-24 13:34:31'),
(360, 7, 879, '2025-03-17', 20004014, '2025-04-24 13:34:41'),
(361, 7, 879, '2025-03-18', 20004014, '2025-04-24 13:34:44'),
(363, 7, 878, '2025-03-20', 20004014, '2025-04-24 13:35:18'),
(364, 7, 879, '2025-03-22', 20004014, '2025-04-24 13:35:23'),
(365, 7, 879, '2025-03-23', 20004014, '2025-04-24 13:35:26'),
(366, 7, 766, '2025-03-29', 20004014, '2025-04-24 13:36:07'),
(367, 7, 772, '2025-03-31', 20004014, '2025-04-24 13:36:46'),
(368, 7, 878, '2025-03-26', 20004014, '2025-04-24 13:37:17'),
(369, 7, 878, '2025-03-24', 20004014, '2025-04-24 13:37:20'),
(370, 4, 827, '2025-04-24', 20004014, '2025-04-24 20:10:55'),
(371, 5, 772, '2025-05-08', 20004014, '2025-04-24 20:12:20'),
(372, 4, 772, '2025-05-07', 20004014, '2025-04-24 20:12:29'),
(374, 7, 770, '2025-05-06', 20004014, '2025-04-24 20:13:28'),
(375, 7, 770, '2025-05-07', 20004014, '2025-04-24 20:13:35'),
(376, 5, 766, '2025-05-09', 20004014, '2025-04-24 20:14:46'),
(377, 4, 827, '2025-05-09', 20004014, '2025-04-24 20:15:01'),
(379, 5, 766, '2025-05-30', 20004014, '2025-04-24 20:15:49'),
(384, 7, 798, '2025-05-10', 20004014, '2025-04-24 20:18:40'),
(385, 4, 879, '2025-05-08', 20004014, '2025-04-24 20:19:02'),
(386, 5, 879, '2025-05-07', 20004014, '2025-04-24 20:19:10'),
(388, 7, 879, '2025-05-05', 20004014, '2025-04-24 20:19:39'),
(389, 5, 880, '2025-05-03', 20004014, '2025-04-24 20:20:03'),
(390, 7, 880, '2025-05-03', 20004014, '2025-04-24 20:20:15'),
(391, 7, 881, '2025-05-02', 20004014, '2025-04-24 20:20:36'),
(392, 7, 878, '2025-05-09', 20004014, '2025-04-24 20:23:03'),
(394, 4, 772, '2025-05-17', 20004014, '2025-04-24 20:24:11'),
(396, 7, 772, '2025-05-13', 20004014, '2025-04-24 20:24:43'),
(397, 7, 772, '2025-05-14', 20004014, '2025-04-24 20:24:49'),
(399, 4, 880, '2025-05-18', 20004014, '2025-04-24 20:25:16'),
(400, 5, 880, '2025-05-18', 20004014, '2025-04-24 20:25:24'),
(401, 5, 881, '2025-05-06', 20004014, '2025-04-24 20:25:45'),
(402, 4, 880, '2025-05-11', 20004014, '2025-04-24 20:26:03'),
(403, 5, 880, '2025-05-11', 20004014, '2025-04-24 20:26:09'),
(404, 7, 880, '2025-05-11', 20004014, '2025-04-24 20:26:15'),
(405, 4, 772, '2025-05-15', 20004014, '2025-04-24 20:26:44'),
(410, 4, 879, '2025-05-13', 20004014, '2025-04-24 20:28:22'),
(411, 4, 878, '2025-05-14', 20004014, '2025-04-24 20:28:32'),
(415, 5, 766, '2025-05-14', 20004014, '2025-04-24 20:29:51'),
(416, 5, 766, '2025-05-16', 20004014, '2025-04-24 20:29:58'),
(417, 7, 880, '2025-05-18', 20004014, '2025-04-24 20:30:24'),
(418, 7, 879, '2025-05-17', 20004014, '2025-04-24 20:30:33'),
(420, 5, 772, '2025-05-19', 20004014, '2025-04-24 20:31:35'),
(425, 4, 878, '2025-05-20', 20004014, '2025-04-24 20:32:24'),
(429, 4, 762, '2025-05-22', 20004014, '2025-04-24 20:35:24'),
(430, 4, 762, '2025-05-23', 20004014, '2025-04-24 20:35:33'),
(431, 4, 762, '2025-05-24', 20004014, '2025-04-24 20:35:41'),
(432, 4, 880, '2025-05-25', 20004014, '2025-04-24 20:35:49'),
(433, 5, 880, '2025-05-25', 20004014, '2025-04-24 20:35:54'),
(434, 7, 880, '2025-05-25', 20004014, '2025-04-24 20:36:02'),
(435, 4, 772, '2025-05-21', 20004014, '2025-04-24 20:36:28'),
(439, 5, 879, '2025-05-23', 20004014, '2025-04-24 20:37:19'),
(442, 7, 878, '2025-05-22', 20004014, '2025-04-24 20:37:45'),
(443, 7, 879, '2025-05-24', 20004014, '2025-04-24 20:37:50'),
(444, 4, 772, '2025-05-31', 20004014, '2025-04-24 20:38:27'),
(445, 5, 879, '2025-05-31', 20004014, '2025-04-24 20:38:46'),
(446, 7, 798, '2025-05-31', 20004014, '2025-04-24 20:38:55'),
(447, 7, 810, '2025-05-30', 20004014, '2025-04-24 20:39:12'),
(448, 4, 879, '2025-05-30', 20004014, '2025-04-24 20:39:20'),
(449, 4, 880, '2025-06-01', 20004014, '2025-04-24 20:39:35'),
(450, 5, 880, '2025-06-01', 20004014, '2025-04-24 20:39:40'),
(451, 7, 880, '2025-06-01', 20004014, '2025-04-24 20:39:46'),
(454, 4, 762, '2025-05-27', 20004014, '2025-04-24 20:40:57'),
(456, 4, 878, '2025-05-28', 20004014, '2025-04-24 20:41:28'),
(459, 7, 772, '2025-05-28', 20004014, '2025-04-24 20:42:27'),
(460, 7, 772, '2025-05-26', 20004014, '2025-04-24 20:42:39'),
(461, 7, 810, '2025-05-27', 20004014, '2025-04-24 20:43:03'),
(462, 7, 879, '2025-05-29', 20004014, '2025-04-24 20:43:13'),
(465, 5, 878, '2025-05-26', 20004014, '2025-04-24 20:44:34'),
(466, 5, 878, '2025-05-27', 20004014, '2025-04-24 20:44:40'),
(467, 7, 766, '2025-05-08', 20004014, '2025-04-24 20:45:16'),
(468, 4, 770, '2025-05-26', 20004014, '2025-04-24 20:45:58'),
(469, 5, 879, '2025-05-17', 20004014, '2025-04-24 21:20:42'),
(471, 5, 798, '2025-05-21', 20004014, '2025-04-24 21:21:24'),
(472, 4, 827, '2025-05-10', 20004014, '2025-04-24 21:35:11'),
(473, 5, 810, '2025-05-22', 20004014, '2025-04-24 21:35:53'),
(476, 7, 772, '2025-05-16', 20004014, '2025-04-24 21:38:13'),
(477, 4, 772, '2025-05-19', 20004014, '2025-04-24 21:38:38'),
(478, 4, 878, '2025-05-16', 20004014, '2025-04-24 21:38:55'),
(479, 7, 827, '2025-05-23', 20004014, '2025-04-24 21:39:47'),
(480, 7, 878, '2025-05-19', 20004014, '2025-04-24 21:41:20'),
(481, 7, 772, '2025-05-12', 20004014, '2025-04-25 12:58:50'),
(482, 5, 798, '2025-05-13', 20004014, '2025-04-25 12:59:11'),
(483, 4, 798, '2025-05-12', 20004014, '2025-04-25 12:59:27'),
(484, 5, 766, '2025-05-15', 20004014, '2025-04-25 12:59:44'),
(485, 5, 878, '2025-05-12', 20004014, '2025-04-25 12:59:52'),
(486, 7, 878, '2025-05-15', 20004014, '2025-04-25 12:59:57'),
(487, 4, 766, '2025-05-29', 20004014, '2025-04-25 13:00:40'),
(489, 5, 762, '2025-05-10', 20004014, '2025-04-25 13:01:31'),
(493, 7, 882, '2025-04-30', 20004014, '2025-04-30 10:03:30'),
(494, 7, 762, '2025-04-29', 20004014, '2025-04-30 10:03:55'),
(495, 5, 810, '2025-04-30', 20004014, '2025-04-30 10:58:11'),
(496, 5, 772, '2025-04-29', 20004014, '2025-04-30 10:58:22'),
(504, 4, 772, '2025-06-14', 20004014, '2025-05-09 13:07:34'),
(506, 5, 810, '2025-05-20', 20004014, '2025-05-19 17:08:52'),
(507, 7, 766, '2025-05-20', 20004014, '2025-05-19 17:30:13'),
(509, 5, 834, '2025-05-24', 20004014, '2025-05-19 17:33:35'),
(512, 5, 810, '2025-05-28', 20004014, '2025-05-19 17:34:23'),
(513, 5, 818, '2025-05-29', 20004014, '2025-05-19 17:34:36'),
(514, 7, 820, '2025-05-21', 20004014, '2025-05-19 17:48:08'),
(515, 4, 878, '2025-06-19', 20004014, '2025-05-23 10:04:55'),
(516, 5, 878, '2025-06-19', 20004014, '2025-05-23 10:05:00'),
(517, 7, 878, '2025-06-19', 20004014, '2025-05-23 10:05:04'),
(518, 4, 798, '2025-06-29', 20004014, '2025-05-23 10:05:46'),
(519, 5, 880, '2025-06-29', 20004014, '2025-05-23 10:05:51'),
(520, 7, 880, '2025-06-29', 20004014, '2025-05-23 10:05:54'),
(521, 4, 880, '2025-06-22', 20004014, '2025-05-23 10:06:02'),
(522, 5, 880, '2025-06-22', 20004014, '2025-05-23 10:06:05'),
(523, 7, 880, '2025-06-22', 20004014, '2025-05-23 10:06:18'),
(524, 4, 880, '2025-06-15', 20004014, '2025-05-23 10:06:25'),
(525, 5, 880, '2025-06-15', 20004014, '2025-05-23 10:06:37'),
(526, 7, 880, '2025-06-15', 20004014, '2025-05-23 10:06:41'),
(527, 4, 880, '2025-06-08', 20004014, '2025-05-23 10:06:45'),
(528, 5, 880, '2025-06-08', 20004014, '2025-05-23 10:06:49'),
(529, 7, 880, '2025-06-08', 20004014, '2025-05-23 10:06:52'),
(530, 5, 772, '2025-06-02', 20004014, '2025-05-23 10:08:31'),
(531, 4, 827, '2025-06-02', 20004014, '2025-05-23 10:08:52'),
(532, 4, 827, '2025-06-03', 20004014, '2025-05-23 10:08:56'),
(533, 4, 827, '2025-06-04', 20004014, '2025-05-23 10:08:59'),
(534, 4, 827, '2025-06-05', 20004014, '2025-05-23 10:09:02'),
(536, 4, 879, '2025-06-06', 20004014, '2025-05-23 10:09:10'),
(542, 4, 879, '2025-06-12', 20004014, '2025-05-23 10:21:18'),
(546, 4, 827, '2025-06-18', 20004014, '2025-05-23 10:21:39'),
(549, 4, 879, '2025-06-21', 20004014, '2025-05-23 10:21:54'),
(550, 7, 772, '2025-06-21', 20004014, '2025-05-23 10:21:58'),
(551, 4, 827, '2025-06-23', 20004014, '2025-05-23 10:22:04'),
(552, 4, 827, '2025-06-24', 20004014, '2025-05-23 10:22:07'),
(553, 4, 827, '2025-06-25', 20004014, '2025-05-23 10:22:09'),
(556, 4, 878, '2025-06-27', 20004014, '2025-05-23 10:22:38'),
(557, 4, 879, '2025-06-28', 20004014, '2025-05-23 10:22:41'),
(565, 5, 772, '2025-06-28', 20004014, '2025-05-23 12:24:10'),
(567, 5, 772, '2025-06-17', 20004014, '2025-05-23 12:27:29'),
(582, 5, 772, '2025-06-03', 20004014, '2025-05-24 13:05:18'),
(584, 5, 772, '2025-06-12', 20004014, '2025-05-24 13:05:52'),
(585, 5, 772, '2025-06-13', 20004014, '2025-05-24 13:06:03'),
(592, 5, 760, '2025-06-05', 20004014, '2025-05-24 13:10:31'),
(593, 5, 772, '2025-06-09', 20004014, '2025-05-24 13:12:10'),
(596, 5, 765, '2025-06-06', 20004014, '2025-05-24 13:32:12'),
(599, 7, 772, '2025-06-27', 20004014, '2025-05-24 13:34:31'),
(602, 7, 772, '2025-06-04', 20004014, '2025-05-24 13:36:47'),
(605, 7, 772, '2025-06-30', 20004014, '2025-05-24 13:38:01'),
(610, 4, 798, '2025-06-09', 20004014, '2025-05-24 17:24:04'),
(611, 4, 798, '2025-06-13', 20004014, '2025-05-24 17:24:20'),
(612, 5, 878, '2025-06-04', 20004014, '2025-05-24 17:26:08'),
(613, 7, 879, '2025-06-03', 20004014, '2025-05-24 17:26:23'),
(614, 5, 878, '2025-06-10', 20004014, '2025-05-24 17:28:06'),
(615, 5, 878, '2025-06-11', 20004014, '2025-05-24 17:28:11'),
(616, 7, 878, '2025-06-09', 20004014, '2025-05-24 17:28:32'),
(618, 7, 879, '2025-06-18', 20004014, '2025-05-24 17:28:56'),
(619, 7, 878, '2025-06-16', 20004014, '2025-05-24 17:29:04'),
(620, 5, 879, '2025-06-14', 20004014, '2025-05-24 17:29:18'),
(621, 7, 879, '2025-06-14', 20004014, '2025-05-24 17:29:25'),
(622, 7, 878, '2025-06-13', 20004014, '2025-05-24 17:29:37'),
(623, 5, 879, '2025-06-23', 20004014, '2025-05-24 17:29:52'),
(624, 5, 878, '2025-06-26', 20004014, '2025-05-24 17:29:59'),
(625, 7, 879, '2025-06-28', 20004014, '2025-05-24 17:30:14'),
(626, 7, 878, '2025-06-24', 20004014, '2025-05-24 17:30:23'),
(627, 5, 879, '2025-06-07', 20004014, '2025-05-24 17:30:51'),
(628, 5, 879, '2025-06-21', 20004014, '2025-05-24 17:31:08'),
(629, 5, 878, '2025-06-20', 20004014, '2025-05-24 17:31:25'),
(630, 7, 878, '2025-06-02', 20004014, '2025-05-31 17:34:55'),
(631, 7, 772, '2025-06-06', 20004014, '2025-06-05 14:15:21'),
(632, 7, 771, '2025-06-05', 20004014, '2025-06-05 14:15:37'),
(634, 4, 825, '2025-06-07', 20004014, '2025-06-05 14:16:04'),
(635, 7, 772, '2025-06-07', 20004014, '2025-06-05 14:16:13'),
(637, 7, 771, '2025-06-12', 20004014, '2025-06-05 14:16:44'),
(638, 4, 810, '2025-06-10', 20004014, '2025-06-05 14:17:05'),
(639, 4, 810, '2025-06-11', 20004014, '2025-06-05 14:17:16'),
(640, 7, 771, '2025-06-10', 20004014, '2025-06-05 14:17:35'),
(641, 7, 771, '2025-06-11', 20004014, '2025-06-05 14:17:39'),
(642, 7, 771, '2025-06-17', 20004014, '2025-06-05 14:18:09'),
(643, 5, 771, '2025-06-18', 20004014, '2025-06-05 14:18:28'),
(644, 7, 771, '2025-06-20', 20004014, '2025-06-05 14:18:41'),
(646, 4, 827, '2025-06-20', 20004014, '2025-06-05 14:19:17'),
(647, 4, 827, '2025-06-16', 20004014, '2025-06-05 14:19:30'),
(648, 5, 771, '2025-06-16', 20004014, '2025-06-05 14:19:39'),
(649, 7, 771, '2025-06-23', 20004014, '2025-06-05 14:19:55'),
(650, 7, 879, '2025-06-25', 20004014, '2025-06-05 14:20:04'),
(652, 5, 771, '2025-06-27', 20004014, '2025-06-05 14:20:36'),
(653, 5, 771, '2025-06-24', 20004014, '2025-06-05 14:20:47'),
(654, 5, 771, '2025-06-25', 20004014, '2025-06-05 14:20:51'),
(656, 4, 762, '2025-06-17', 20004014, '2025-06-05 14:22:10'),
(657, 5, 768, '2025-06-30', 20004014, '2025-06-05 14:22:38'),
(658, 7, 879, '2025-07-21', 20004014, '2025-06-25 11:31:36'),
(659, 7, 878, '2025-07-22', 20004014, '2025-06-25 11:31:40'),
(660, 7, 878, '2025-07-23', 20004014, '2025-06-25 11:31:43'),
(661, 5, 770, '2025-07-03', 20004014, '2025-06-25 11:32:25'),
(663, 5, 879, '2025-07-19', 20004014, '2025-06-25 11:33:01'),
(666, 5, 879, '2025-07-12', 20004014, '2025-06-25 11:33:19'),
(667, 5, 880, '2025-07-13', 20004014, '2025-06-25 11:33:22'),
(674, 4, 879, '2025-08-09', 20004014, '2025-06-25 11:34:34'),
(675, 7, 879, '2025-08-09', 20004014, '2025-06-25 11:34:37'),
(676, 5, 772, '2025-08-09', 20004014, '2025-06-25 11:34:41'),
(677, 4, 770, '2025-07-10', 20004014, '2025-06-25 11:35:08'),
(678, 7, 810, '2025-07-10', 20004014, '2025-06-25 11:35:24'),
(679, 4, 878, '2025-07-01', 20004014, '2025-06-25 11:38:34'),
(680, 4, 878, '2025-07-02', 20004014, '2025-06-25 11:38:37'),
(683, 5, 770, '2025-07-02', 20004014, '2025-06-25 11:39:26'),
(684, 5, 878, '2025-07-04', 20004014, '2025-06-25 11:39:53'),
(685, 7, 810, '2025-07-02', 20004014, '2025-06-25 11:40:08'),
(686, 4, 810, '2025-07-03', 20004014, '2025-06-25 11:40:26'),
(688, 5, 810, '2025-07-01', 20004014, '2025-06-25 11:42:21'),
(689, 7, 770, '2025-07-01', 20004014, '2025-06-25 11:42:26'),
(690, 4, 810, '2025-07-04', 20004014, '2025-06-25 11:44:29'),
(691, 4, 810, '2025-07-05', 20004014, '2025-06-25 11:44:34'),
(692, 5, 770, '2025-07-05', 20004014, '2025-06-25 11:44:48'),
(694, 7, 770, '2025-07-04', 20004014, '2025-06-25 11:45:08'),
(695, 7, 879, '2025-07-05', 20004014, '2025-06-25 11:47:49'),
(696, 4, 880, '2025-07-06', 20004014, '2025-06-25 11:47:53'),
(697, 5, 880, '2025-07-06', 20004014, '2025-06-25 11:47:56'),
(698, 7, 880, '2025-07-06', 20004014, '2025-06-25 11:47:59'),
(699, 4, 878, '2025-06-30', 20004014, '2025-06-25 11:48:34'),
(700, 4, 810, '2025-07-07', 20004014, '2025-06-25 11:49:17'),
(701, 4, 810, '2025-07-08', 20004014, '2025-06-25 11:49:20'),
(703, 4, 810, '2025-07-12', 20004014, '2025-06-25 11:49:41'),
(704, 7, 770, '2025-07-11', 20004014, '2025-06-25 11:50:01'),
(705, 5, 810, '2025-07-11', 20004014, '2025-06-25 11:50:26'),
(706, 4, 879, '2025-07-11', 20004014, '2025-06-25 11:50:30'),
(707, 4, 879, '2025-07-09', 20004014, '2025-06-25 11:50:38'),
(708, 4, 880, '2025-07-13', 20004014, '2025-06-25 11:50:44'),
(709, 7, 880, '2025-07-13', 20004014, '2025-06-25 11:50:47'),
(710, 7, 770, '2025-07-12', 20004014, '2025-06-25 11:50:53'),
(711, 7, 879, '2025-07-07', 20004014, '2025-06-25 11:51:30'),
(712, 7, 810, '2025-07-09', 20004014, '2025-06-25 11:51:53'),
(713, 5, 770, '2025-07-07', 20004014, '2025-06-25 11:52:02'),
(714, 5, 770, '2025-07-08', 20004014, '2025-06-25 11:52:07'),
(715, 5, 770, '2025-07-09', 20004014, '2025-06-25 11:52:14'),
(717, 5, 879, '2025-07-10', 20004014, '2025-06-25 11:52:36'),
(718, 7, 878, '2025-07-08', 20004014, '2025-06-25 11:52:42'),
(720, 7, 772, '2025-07-24', 20004014, '2025-06-25 11:53:27'),
(721, 7, 770, '2025-07-25', 20004014, '2025-06-25 11:53:36'),
(723, 7, 879, '2025-10-11', 20004014, '2025-06-25 12:07:31'),
(724, 7, 880, '2025-10-12', 20004014, '2025-06-25 12:07:34'),
(726, 7, 878, '2025-10-17', 20004014, '2025-06-25 12:08:14'),
(727, 7, 879, '2025-10-18', 20004014, '2025-06-25 12:08:18'),
(728, 7, 880, '2025-10-19', 20004014, '2025-06-25 12:08:21'),
(735, 4, 878, '2025-07-18', 20004014, '2025-06-25 12:12:30'),
(736, 4, 810, '2025-07-21', 20004014, '2025-06-25 12:13:26'),
(737, 4, 810, '2025-07-23', 20004014, '2025-06-25 12:13:30'),
(738, 4, 810, '2025-07-22', 20004014, '2025-06-25 12:13:33'),
(739, 4, 878, '2025-07-24', 20004014, '2025-06-25 12:13:38'),
(740, 4, 810, '2025-07-25', 20004014, '2025-06-25 12:13:42'),
(745, 4, 827, '2025-07-16', 20004014, '2025-06-25 12:14:29'),
(746, 4, 827, '2025-07-17', 20004014, '2025-06-25 12:14:32'),
(747, 4, 827, '2025-07-14', 20004014, '2025-06-25 12:14:44'),
(748, 4, 827, '2025-07-15', 20004014, '2025-06-25 12:14:46'),
(750, 4, 880, '2025-07-27', 20004014, '2025-06-25 12:14:57'),
(751, 5, 880, '2025-07-27', 20004014, '2025-06-25 12:15:00'),
(752, 7, 880, '2025-07-27', 20004014, '2025-06-25 12:15:03'),
(753, 4, 880, '2025-08-03', 20004014, '2025-06-25 12:15:08'),
(756, 5, 880, '2025-08-03', 20004014, '2025-06-25 12:15:24'),
(757, 7, 880, '2025-08-03', 20004014, '2025-06-25 12:15:28'),
(758, 4, 880, '2025-08-10', 20004014, '2025-06-25 12:15:34'),
(759, 5, 880, '2025-08-10', 20004014, '2025-06-25 12:15:36'),
(760, 7, 880, '2025-08-10', 20004014, '2025-06-25 12:15:40'),
(761, 4, 880, '2025-07-20', 20004014, '2025-06-25 12:15:49'),
(762, 5, 880, '2025-07-20', 20004014, '2025-06-25 12:15:52'),
(763, 7, 880, '2025-07-20', 20004014, '2025-06-25 12:15:55'),
(771, 7, 770, '2025-07-18', 20004014, '2025-06-25 12:21:17'),
(772, 7, 770, '2025-07-17', 20004014, '2025-06-25 12:21:26'),
(774, 5, 810, '2025-07-18', 20004014, '2025-06-25 12:33:02'),
(775, 5, 770, '2025-07-14', 20004014, '2025-06-25 12:33:38'),
(776, 5, 770, '2025-07-15', 20004014, '2025-06-25 12:33:42'),
(777, 7, 770, '2025-07-16', 20004014, '2025-06-25 12:33:58'),
(778, 5, 770, '2025-07-21', 20004014, '2025-06-25 12:34:28'),
(779, 5, 770, '2025-07-22', 20004014, '2025-06-25 12:34:33'),
(780, 5, 770, '2025-07-23', 20004014, '2025-06-25 12:34:38'),
(781, 5, 770, '2025-07-24', 20004014, '2025-06-25 12:34:43'),
(786, 7, 772, '2025-07-28', 20004014, '2025-06-25 12:39:45'),
(787, 7, 770, '2025-07-03', 20004014, '2025-06-25 12:41:14'),
(788, 4, 810, '2025-07-29', 20004014, '2025-06-25 12:41:46'),
(789, 4, 810, '2025-07-30', 20004014, '2025-06-25 12:41:52'),
(790, 4, 810, '2025-07-31', 20004014, '2025-06-25 12:41:59'),
(792, 4, 772, '2025-07-19', 20004014, '2025-06-25 12:44:00'),
(793, 4, 879, '2025-07-26', 20004014, '2025-06-25 12:44:15'),
(794, 5, 879, '2025-07-25', 20004014, '2025-06-25 12:44:37'),
(795, 5, 810, '2025-07-26', 20004014, '2025-06-25 12:44:46'),
(796, 7, 770, '2025-07-26', 20004014, '2025-06-25 12:44:53'),
(797, 7, 770, '2025-07-19', 20004014, '2025-06-25 12:46:10'),
(798, 7, 770, '2025-07-31', 20004014, '2025-06-25 12:46:37'),
(800, 5, 772, '2025-07-28', 20004014, '2025-06-25 12:46:59'),
(801, 5, 772, '2025-07-29', 20004014, '2025-06-25 12:47:04'),
(803, 7, 770, '2025-07-30', 20004014, '2025-06-25 12:47:26'),
(804, 5, 878, '2025-07-16', 20004014, '2025-06-26 12:36:45'),
(805, 5, 878, '2025-07-17', 20004014, '2025-06-26 12:36:47'),
(806, 7, 879, '2025-07-14', 20004014, '2025-06-26 12:36:54'),
(807, 7, 878, '2025-07-15', 20004014, '2025-06-26 12:36:57'),
(808, 4, 878, '2025-07-28', 20004014, '2025-06-26 12:37:11'),
(809, 5, 878, '2025-07-30', 20004014, '2025-06-26 12:37:15'),
(810, 5, 879, '2025-07-31', 20004014, '2025-06-26 12:37:19'),
(811, 7, 879, '2025-07-29', 20004014, '2025-06-26 12:37:47'),
(812, 7, 772, '2025-06-26', 20004014, '2025-06-26 12:44:14'),
(813, 7, 878, '2025-10-10', 20004014, '2025-07-01 13:10:16'),
(814, 7, 770, '2025-10-16', 20004014, '2025-07-01 13:10:42'),
(822, 4, 880, '2025-08-31', 20004014, '2025-07-12 13:12:46'),
(824, 7, 880, '2025-08-31', 20004014, '2025-07-12 13:13:46'),
(826, 5, 798, '2025-08-31', 20004014, '2025-07-12 13:13:56'),
(832, 4, 879, '2025-08-02', 20004014, '2025-07-21 01:05:47'),
(835, 1, 879, '2025-07-27', 29999999, '2025-07-21 21:53:24'),
(837, 1, 729, '2025-07-26', 29999999, '2025-07-22 00:28:11'),
(846, 7, 878, '2025-08-26', 20004014, '2025-07-23 23:37:17'),
(870, 7, 878, '2025-08-27', 20004014, '2025-07-24 09:27:52'),
(876, 8, 710, '2025-07-31', 29999999, '2025-07-24 12:03:57'),
(877, 8, 710, '2025-07-30', 29999999, '2025-07-24 12:07:37'),
(878, 1, 772, '2025-07-24', 29999999, '2025-07-24 12:20:12'),
(895, 8, 880, '2025-08-03', 29999999, '2025-07-24 22:56:09'),
(900, 1, 878, '2025-08-05', 29999999, '2025-07-25 01:48:46'),
(904, 5, 879, '2025-08-02', 20004014, '2025-07-25 08:39:41'),
(905, 7, 772, '2025-08-02', 20004014, '2025-07-25 08:39:57'),
(906, 4, 810, '2025-08-01', 20004014, '2025-07-25 08:40:13'),
(909, 4, 810, '2025-08-06', 20004014, '2025-07-25 08:42:32'),
(918, 5, 879, '2025-08-05', 20004014, '2025-07-25 08:45:31'),
(919, 4, 810, '2025-08-05', 20004014, '2025-07-25 08:45:40'),
(922, 7, 770, '2025-08-05', 20004014, '2025-07-25 08:46:39'),
(923, 5, 878, '2025-08-11', 20004014, '2025-07-25 08:47:47'),
(924, 4, 808, '2025-08-11', 20004014, '2025-07-25 08:48:07'),
(925, 7, 772, '2025-08-11', 20004014, '2025-07-25 08:48:35'),
(926, 4, 808, '2025-08-12', 20004014, '2025-07-25 08:49:01'),
(927, 5, 878, '2025-08-12', 20004014, '2025-07-25 08:49:04'),
(928, 7, 772, '2025-08-12', 20004014, '2025-07-25 08:49:10'),
(929, 7, 878, '2025-08-13', 20004014, '2025-07-25 08:49:15'),
(930, 7, 878, '2025-08-14', 20004014, '2025-07-25 08:49:18'),
(931, 5, 772, '2025-08-13', 20004014, '2025-07-25 08:49:27'),
(932, 5, 772, '2025-08-14', 20004014, '2025-07-25 08:49:29'),
(933, 4, 808, '2025-08-13', 20004014, '2025-07-25 08:49:37'),
(934, 4, 808, '2025-08-14', 20004014, '2025-07-25 08:49:39'),
(939, 5, 879, '2025-08-16', 20004014, '2025-07-25 08:52:28'),
(940, 4, 880, '2025-08-17', 20004014, '2025-07-25 08:52:33'),
(941, 5, 880, '2025-08-17', 20004014, '2025-07-25 08:52:35'),
(942, 7, 880, '2025-08-17', 20004014, '2025-07-25 08:52:37'),
(944, 4, 881, '2025-08-15', 20004014, '2025-07-25 10:04:46'),
(945, 5, 881, '2025-08-15', 20004014, '2025-07-25 10:04:48'),
(946, 7, 881, '2025-08-15', 20004014, '2025-07-25 10:04:50'),
(949, 7, 879, '2025-08-16', 20004014, '2025-07-25 10:06:14'),
(950, 4, 772, '2025-08-16', 20004014, '2025-07-25 10:06:16'),
(957, 5, 810, '2025-08-08', 20004014, '2025-07-25 10:10:52'),
(959, 7, 770, '2025-08-08', 20004014, '2025-07-25 10:11:33'),
(960, 4, 879, '2025-08-18', 20004014, '2025-07-25 10:12:18'),
(967, 4, 810, '2025-08-19', 20004014, '2025-07-25 10:15:22'),
(968, 5, 770, '2025-08-19', 20004014, '2025-07-25 10:16:10'),
(969, 5, 770, '2025-08-18', 20004014, '2025-07-25 10:16:15'),
(971, 4, 810, '2025-08-20', 20004014, '2025-07-25 10:16:30'),
(974, 7, 878, '2025-08-19', 20004014, '2025-07-25 10:17:23'),
(975, 5, 878, '2025-08-20', 20004014, '2025-07-25 10:17:25'),
(976, 5, 879, '2025-08-30', 20004014, '2025-07-25 10:18:36'),
(977, 7, 772, '2025-08-30', 20004014, '2025-07-25 10:18:38'),
(979, 4, 879, '2025-08-30', 20004014, '2025-07-25 10:19:26'),
(991, 4, 880, '2025-08-24', 20004014, '2025-07-25 10:23:53'),
(992, 5, 880, '2025-08-24', 20004014, '2025-07-25 10:23:55'),
(993, 7, 880, '2025-08-24', 20004014, '2025-07-25 10:23:57'),
(994, 7, 878, '2025-08-25', 20004014, '2025-07-25 10:26:48'),
(996, 5, 810, '2025-08-28', 20004014, '2025-07-25 10:27:20'),
(997, 7, 770, '2025-08-28', 20004014, '2025-07-25 10:27:27'),
(1000, 4, 878, '2025-08-28', 20004014, '2025-07-25 10:28:00'),
(1001, 5, 880, '2025-08-29', 20004014, '2025-07-25 10:28:08'),
(1002, 4, 879, '2025-08-23', 20004014, '2025-07-25 10:28:23'),
(1003, 4, 827, '2025-08-29', 20004014, '2025-07-25 10:30:19'),
(1005, 7, 770, '2025-08-29', 20004014, '2025-07-25 10:30:39'),
(1011, 7, 772, '2025-08-23', 20004014, '2025-07-25 10:46:18'),
(1012, 5, 879, '2025-08-23', 20004014, '2025-07-25 10:47:03'),
(1014, 4, 827, '2025-08-26', 20004014, '2025-07-25 10:48:18'),
(1017, 7, 772, '2025-08-07', 20004014, '2025-07-25 11:37:13'),
(1023, 1, 751, '2025-07-22', 29999999, '2025-07-25 21:07:35'),
(1047, 1, 758, '2025-07-28', 29999999, '2025-07-25 23:00:12'),
(1071, 8, 758, '2025-07-27', 29999999, '2025-07-26 08:36:29'),
(1085, 8, 772, '2025-08-01', 29999999, '2025-07-26 09:06:06'),
(1095, 1, 758, '2025-07-31', 29999999, '2025-07-28 13:40:40'),
(1098, 1, 758, '2025-07-30', 29999999, '2025-07-28 13:50:38'),
(1100, 1, 758, '2025-08-02', 29999999, '2025-07-28 19:48:29'),
(1101, 1, 758, '2025-08-01', 29999999, '2025-07-28 19:48:38'),
(1108, 8, 772, '2025-08-05', 29999999, '2025-07-28 19:57:46'),
(1115, 8, 772, '2025-08-09', 29999999, '2025-07-28 20:04:55'),
(1116, 8, 772, '2025-08-08', 29999999, '2025-07-28 20:04:56'),
(1117, 8, 772, '2025-08-06', 29999999, '2025-07-28 20:06:44'),
(1120, 1, 878, '2025-08-06', 29999999, '2025-07-28 20:10:14'),
(1124, 8, 772, '2025-07-25', 29999999, '2025-07-28 20:56:01'),
(1127, 5, 810, '2025-08-07', 20004014, '2025-07-29 23:46:26'),
(1128, 5, 770, '2025-08-25', 20004014, '2025-07-29 23:47:31'),
(1129, 4, 827, '2025-08-25', 20004014, '2025-07-29 23:47:38'),
(1130, 5, 772, '2025-08-27', 20004014, '2025-07-29 23:48:10'),
(1131, 4, 878, '2025-08-27', 20004014, '2025-07-29 23:48:18'),
(1134, 5, 770, '2025-08-26', 20004014, '2025-07-29 23:49:17'),
(1136, 7, 770, '2025-08-20', 20004014, '2025-07-30 06:48:44'),
(1138, 5, 772, '2025-08-21', 20004014, '2025-07-30 06:49:11'),
(1140, 7, 878, '2025-08-21', 20004014, '2025-07-30 06:49:34'),
(1142, 7, 770, '2025-08-22', 20004014, '2025-07-30 06:55:22'),
(1144, 5, 810, '2025-08-22', 20004014, '2025-07-30 06:57:07'),
(1147, 1, 878, '2025-08-08', 29999999, '2025-07-30 07:21:06'),
(1149, 8, 772, '2025-08-07', 29999999, '2025-07-30 07:24:33'),
(1151, 7, 762, '2025-08-01', 20004014, '2025-08-03 13:37:05'),
(1152, 4, 770, '2025-08-04', 20004014, '2025-08-03 13:37:29'),
(1153, 7, 878, '2025-08-04', 20004014, '2025-08-03 13:37:36'),
(1154, 5, 810, '2025-08-04', 20004014, '2025-08-03 13:38:01'),
(1155, 5, 878, '2025-08-06', 20004014, '2025-08-03 13:38:13'),
(1156, 7, 770, '2025-08-06', 20004014, '2025-08-03 13:38:56'),
(1157, 5, 878, '2025-08-01', 20004014, '2025-08-03 13:39:48'),
(1158, 7, 772, '2025-08-18', 20004014, '2025-08-03 13:40:19');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `schedule_locks`
--

CREATE TABLE `schedule_locks` (
  `id` int(11) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `month_date` date NOT NULL COMMENT 'Przechowuje pierwszy dzień miesiąca, np. 2025-07-01',
  `locked_by_user_id` int(11) NOT NULL,
  `locked_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `schedule_locks`
--

INSERT INTO `schedule_locks` (`id`, `sfid_id`, `month_date`, `locked_by_user_id`, `locked_at`) VALUES
(8, 29999999, '2025-07-01', 1, '2025-07-28 21:49:52'),
(15, 29999999, '2025-08-01', 1, '2025-07-30 07:25:16'),
(16, 20004014, '2025-08-01', 4, '2025-08-03 21:15:49'),
(17, 20004014, '2025-07-01', 4, '2025-08-03 21:16:04');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `schedule_requests`
--

CREATE TABLE `schedule_requests` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `request_date` date NOT NULL,
  `comment` text DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `schedule_entry_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `resolved_by` int(11) DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `schedule_requests`
--

INSERT INTO `schedule_requests` (`id`, `user_id`, `request_date`, `comment`, `status`, `rejection_reason`, `schedule_entry_id`, `created_at`, `resolved_by`, `resolved_at`) VALUES
(4, 5, '2025-08-01', '', 'approved', NULL, 843, '2025-07-23 23:04:40', 4, '2025-07-25 10:40:59'),
(5, 5, '2025-08-02', '', 'approved', NULL, 844, '2025-07-23 23:09:35', 4, '2025-07-24 23:42:13'),
(6, 7, '2025-08-06', '', 'approved', NULL, 845, '2025-07-23 23:10:39', 4, '2025-07-25 10:41:04'),
(7, 7, '2025-08-26', '', 'approved', NULL, 846, '2025-07-23 23:37:17', 4, '2025-07-25 10:41:09'),
(18, 8, '2025-08-01', '', 'rejected', 'test', 861, '2025-07-24 00:49:41', 1, '2025-07-24 02:50:33'),
(19, 8, '2025-08-01', '', 'approved', NULL, 863, '2025-07-24 00:51:05', 1, '2025-07-24 02:51:05'),
(20, 1, '2025-08-01', '', 'approved', NULL, 864, '2025-07-24 00:51:52', 1, '2025-07-24 02:51:52'),
(23, 7, '2025-08-27', '', 'approved', NULL, 870, '2025-07-24 09:27:52', 4, '2025-07-25 10:41:11'),
(24, 7, '2025-08-28', '', 'approved', NULL, 871, '2025-07-24 09:28:07', 4, '2025-07-25 10:41:12'),
(25, 8, '2025-08-02', '', 'rejected', 'bo tak', 873, '2025-07-24 10:42:45', 1, '2025-07-24 15:32:29'),
(26, 8, '2025-08-04', '', 'approved', NULL, 880, '2025-07-24 13:25:44', 1, '2025-07-24 15:26:13'),
(27, 7, '2025-08-16', '', 'approved', NULL, 884, '2025-07-24 16:34:07', 4, '2025-07-24 23:42:28'),
(28, 8, '2025-08-05', '', 'approved', NULL, 886, '2025-07-24 21:30:19', 1, '2025-07-25 03:48:54'),
(29, 1, '2025-08-01', '', 'approved', NULL, 892, '2025-07-24 22:13:02', 1, '2025-07-25 00:13:07'),
(30, 1, '2025-08-05', '', 'approved', NULL, 900, '2025-07-25 01:48:46', 1, '2025-07-25 03:48:52'),
(31, 5, '2025-08-30', 'Mogę pracować ale max do 17', 'pending', NULL, 943, '2025-07-25 09:42:59', NULL, NULL),
(32, 5, '2025-08-04', '', 'approved', NULL, 952, '2025-07-25 10:07:06', 4, '2025-07-25 12:07:06'),
(33, 7, '2025-08-25', '', 'approved', NULL, 994, '2025-07-25 10:26:48', 4, '2025-07-25 12:26:48'),
(34, 1, '2025-08-06', '', 'approved', NULL, 1032, '2025-07-25 22:27:28', 1, '2025-07-26 00:27:28'),
(35, 1, '2025-08-06', '', 'approved', NULL, 1120, '2025-07-28 20:10:14', 1, '2025-07-30 09:24:57'),
(36, 1, '2025-08-08', '', 'approved', NULL, 1147, '2025-07-30 07:21:06', 1, '2025-07-30 09:21:06');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `sfid_locations`
--

CREATE TABLE `sfid_locations` (
  `id` int(11) NOT NULL CHECK (`id` between 10000000 and 29999999),
  `name` varchar(100) NOT NULL,
  `location_category_id` int(11) DEFAULT NULL,
  `address` text NOT NULL,
  `work_hours` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`work_hours`)),
  `max_monthly_hours` decimal(5,2) DEFAULT 168.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `sfid_locations`
--

INSERT INTO `sfid_locations` (`id`, `name`, `location_category_id`, `address`, `work_hours`, `max_monthly_hours`, `created_at`, `is_active`) VALUES
(20000000, 'Zaarchiwizowany PG', 1, 'Pl. Grunwaldzki 22, 50-363 Wrocław', '{\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"10:00-20:00\"}', 168.00, '2025-04-07 00:54:45', 0),
(20001325, 'ASTRA', 1, 'Horbaczewskiego 4/6, 54-130 Wrocław', '{\"weekdays\":\"09:00-20:00\",\"saturday\":\"09:00\\u201320:00\",\"sunday\":\"\"}', 200.00, '2025-07-29 20:47:57', 1),
(20004014, 'Pasaż Grunwaldzki', 1, 'Pl. Grunwaldzki 22, 50-363 Wrocław', '{\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"10:00-20:00\"}', 168.00, '2025-07-21 23:38:39', 1),
(29999999, 'Testowa', 1, 'ul. Centralna 1', '{\"weekdays\":\"09:00-21:00\",\"saturday\":\"09:00-21:00\",\"sunday\":\"\"}', 168.00, '2025-07-21 23:32:14', 1);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `sfid_location_categories`
--

CREATE TABLE `sfid_location_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `sfid_location_categories`
--

INSERT INTO `sfid_location_categories` (`id`, `name`) VALUES
(1, 'LIBERTY POLAND S.A.');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `shifts`
--

CREATE TABLE `shifts` (
  `id` int(11) NOT NULL,
  `symbol` varchar(10) NOT NULL,
  `hours` decimal(4,2) NOT NULL,
  `time_interval` varchar(20) NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `color` varchar(20) DEFAULT '--bs-primary-rgb',
  `fav_by` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `shifts`
--

INSERT INTO `shifts` (`id`, `symbol`, `hours`, `time_interval`, `start_time`, `end_time`, `color`, `fav_by`) VALUES
(1, 'TEST', 8.00, '08:00-16:00', '08:00:00', '16:00:00', '--bs-primary-rgb', NULL),
(2, 'TEST2', 12.00, '20:00-08:00', '20:00:00', '08:00:00', '--bs-primary-rgb', NULL),
(707, 'A1', 4.00, '06:00-10:00', '06:00:00', '10:00:00', '--bs-primary-rgb', ''),
(708, 'A3', 6.00, '06:00-12:00', '06:00:00', '12:00:00', '--bs-primary-rgb', NULL),
(709, 'A4', 7.00, '06:00-13:00', '06:00:00', '13:00:00', '--bs-primary-rgb', NULL),
(710, 'A', 8.00, '06:00-14:00', '06:00:00', '14:00:00', '--bs-primary-rgb', NULL),
(711, 'A5', 9.00, '06:00-15:00', '06:00:00', '15:00:00', '--bs-primary-rgb', NULL),
(712, 'A6', 10.00, '06:00-16:00', '06:00:00', '16:00:00', '--bs-primary-rgb', NULL),
(713, 'A2', 12.00, '06:00-18:00', '06:00:00', '18:00:00', '--bs-primary-rgb', NULL),
(714, 'AA', 8.00, '06:30-14:30', '06:30:00', '14:30:00', '--bs-primary-rgb', NULL),
(715, 'AB', 8.50, '06:30-15:00', '06:30:00', '15:00:00', '--bs-primary-rgb', NULL),
(716, 'B9', 4.00, '07:00-11:00', '07:00:00', '11:00:00', '--bs-primary-rgb', NULL),
(717, 'B10', 6.00, '07:00-13:00', '07:00:00', '13:00:00', '--bs-primary-rgb', NULL),
(718, 'B5', 7.00, '07:00-14:00', '07:00:00', '14:00:00', '--bs-primary-rgb', NULL),
(719, 'B', 8.00, '07:00-15:00', '07:00:00', '15:00:00', '--bs-primary-rgb', NULL),
(720, 'MIGR', 8.00, '07:00-15:00', '07:00:00', '15:00:00', '--bs-primary-rgb', NULL),
(721, 'B1', 8.50, '07:00-15:30', '07:00:00', '15:30:00', '--bs-primary-rgb', NULL),
(722, 'B4', 9.00, '07:00-16:00', '07:00:00', '16:00:00', '--bs-primary-rgb', NULL),
(723, 'B6', 10.00, '07:00-17:00', '07:00:00', '17:00:00', '--bs-primary-rgb', NULL),
(724, 'B11', 11.00, '07:00-18:00', '07:00:00', '18:00:00', '--bs-primary-rgb', NULL),
(725, 'B3', 12.00, '07:00-19:00', '07:00:00', '19:00:00', '--bs-primary-rgb', NULL),
(726, 'BB', 8.00, '07:30-15:30', '07:30:00', '15:30:00', '--bs-primary-rgb', NULL),
(727, 'B7', 9.00, '07:30-16:30', '07:30:00', '16:30:00', '--bs-primary-rgb', NULL),
(728, 'C17', 2.00, '08:00-10:00', '08:00:00', '10:00:00', '--bs-primary-rgb', NULL),
(729, 'C18', 3.00, '08:00-11:00', '08:00:00', '11:00:00', '--bs-primary-rgb', NULL),
(730, 'C6', 4.00, '08:00-12:00', '08:00:00', '12:00:00', '--bs-primary-rgb', NULL),
(731, 'C11', 5.00, '08:00-13:00', '08:00:00', '13:00:00', '--bs-primary-rgb', NULL),
(732, 'C5', 6.00, '08:00-14:00', '08:00:00', '14:00:00', '--bs-primary-rgb', NULL),
(733, 'C14', 6.50, '08:00-14:30', '08:00:00', '14:30:00', '--bs-primary-rgb', NULL),
(734, 'C9', 7.00, '08:00-15:00', '08:00:00', '15:00:00', '--bs-primary-rgb', NULL),
(735, 'C25', 7.50, '08:00-15:30', '08:00:00', '15:30:00', '--bs-primary-rgb', NULL),
(736, 'C', 8.00, '08:00-16:00', '08:00:00', '16:00:00', '--bs-primary-rgb', NULL),
(737, 'NOR1', 8.00, '08:00-16:00', '08:00:00', '16:00:00', '--bs-primary-rgb', NULL),
(738, 'C23', 8.50, '08:00-16:30', '08:00:00', '16:30:00', '--bs-primary-rgb', NULL),
(739, 'C10', 9.00, '08:00-17:00', '08:00:00', '17:00:00', '--bs-primary-rgb', NULL),
(740, 'C26', 9.50, '08:00-17:30', '08:00:00', '17:30:00', '--bs-primary-rgb', NULL),
(741, 'C12', 10.00, '08:00-18:00', '08:00:00', '18:00:00', '--bs-primary-rgb', NULL),
(742, 'C21', 10.50, '08:00-18:30', '08:00:00', '18:30:00', '--bs-primary-rgb', NULL),
(743, 'C16', 11.00, '08:00-19:00', '08:00:00', '19:00:00', '--bs-primary-rgb', NULL),
(744, 'C15', 12.00, '08:00-20:00', '08:00:00', '20:00:00', '--bs-primary-rgb', NULL),
(745, 'C7', 4.00, '08:30-12:30', '08:30:00', '12:30:00', '--bs-primary-rgb', NULL),
(746, 'C1', 5.50, '08:30-14:00', '08:30:00', '14:00:00', '--bs-primary-rgb', NULL),
(747, 'C3', 6.00, '08:30-14:30', '08:30:00', '14:30:00', '--bs-primary-rgb', NULL),
(748, 'C8', 7.00, '08:30-15:30', '08:30:00', '15:30:00', '--bs-primary-rgb', NULL),
(749, 'NEP3', 7.00, '08:30-15:30', '08:30:00', '15:30:00', '--bs-primary-rgb', NULL),
(750, 'C19', 7.50, '08:30-16:00', '08:30:00', '16:00:00', '--bs-primary-rgb', NULL),
(751, 'CC', 8.00, '08:30-16:30', '08:30:00', '16:30:00', '--bs-primary-rgb', NULL),
(752, 'NORM', 8.00, '08:30-16:30', '08:30:00', '16:30:00', '--bs-primary-rgb', NULL),
(753, 'C24', 8.50, '08:30-17:00', '08:30:00', '17:00:00', '--bs-primary-rgb', NULL),
(754, 'C22', 9.00, '08:30-17:30', '08:30:00', '17:30:00', '--bs-primary-rgb', NULL),
(755, 'C2', 9.50, '08:30-18:00', '08:30:00', '18:00:00', '--bs-primary-rgb', NULL),
(756, 'C20', 10.00, '08:30-18:30', '08:30:00', '18:30:00', '--bs-primary-rgb', NULL),
(757, 'C4', 11.00, '08:30-19:30', '08:30:00', '19:30:00', '--bs-primary-rgb', NULL),
(758, 'C13', 12.00, '08:30-20:30', '08:30:00', '20:30:00', '--bs-primary-rgb', ',1,'),
(759, 'D03', 3.00, '09:00-12:00', '09:00:00', '12:00:00', '--bs-primary-rgb', NULL),
(760, 'D1', 4.00, '09:00-13:00', '09:00:00', '13:00:00', '--bs-primary-rgb', NULL),
(761, 'D16', 5.00, '09:00-14:00', '09:00:00', '14:00:00', '--bs-primary-rgb', NULL),
(762, 'D14', 6.00, '09:00-15:00', '09:00:00', '15:00:00', '--bs-primary-rgb', NULL),
(763, 'D15', 6.50, '09:00-15:30', '09:00:00', '15:30:00', '--bs-primary-rgb', NULL),
(764, 'D18', 7.00, '09:00-16:00', '09:00:00', '16:00:00', '--bs-primary-rgb', NULL),
(765, 'D', 8.00, '09:00-17:00', '09:00:00', '17:00:00', '#16a34a', NULL),
(766, 'NOR2', 8.00, '09:00-17:00', '09:00:00', '17:00:00', '#16a34a', NULL),
(767, 'D19', 8.50, '09:00-17:30', '09:00:00', '17:30:00', '--bs-primary-rgb', NULL),
(768, 'D2', 9.00, '09:00-18:00', '09:00:00', '18:00:00', '--bs-primary-rgb', NULL),
(769, 'D23', 9.50, '09:00-18:30', '09:00:00', '18:30:00', '--bs-primary-rgb', NULL),
(770, 'D10', 10.00, '09:00-19:00', '09:00:00', '19:00:00', '--bs-primary-rgb', NULL),
(771, 'D17', 11.00, '09:00-20:00', '09:00:00', '20:00:00', '--bs-primary-rgb', NULL),
(772, 'D27', 12.00, '09:00-21:00', '09:00:00', '21:00:00', '#4f46e5', ',4,1,'),
(773, 'D6', 6.00, '09:30 - 15:30', '09:30:00', '15:30:00', '--bs-primary-rgb', NULL),
(774, 'D7', 7.00, '09:30 - 16:30', '09:30:00', '16:30:00', '--bs-primary-rgb', NULL),
(775, 'D25', 3.50, '09:30-13:00', '09:30:00', '13:00:00', '--bs-primary-rgb', NULL),
(776, 'D5', 5.00, '09:30-14:30', '09:30:00', '14:30:00', '--bs-primary-rgb', NULL),
(777, 'DD', 8.00, '09:30-17:30', '09:30:00', '17:30:00', '--bs-primary-rgb', NULL),
(778, 'D8', 8.50, '09:30-18:00', '09:30:00', '18:00:00', '--bs-primary-rgb', NULL),
(779, 'D9', 9.00, '09:30-18:30', '09:30:00', '18:30:00', '--bs-primary-rgb', NULL),
(780, 'D26', 11.50, '09:30-21:00', '09:30:00', '21:00:00', '--bs-primary-rgb', NULL),
(781, 'D24', 12.00, '09:30-21:30', '09:30:00', '21:30:00', '--bs-primary-rgb', NULL),
(782, 'D28', 8.50, '09:45-18:15', '09:45:00', '18:15:00', '--bs-primary-rgb', NULL),
(783, 'E25', 1.00, '10:00-11:00', '10:00:00', '11:00:00', '--bs-primary-rgb', NULL),
(784, 'E03', 3.00, '10:00-13:00', '10:00:00', '13:00:00', '--bs-primary-rgb', NULL),
(785, 'E1', 4.00, '10:00-14:00', '10:00:00', '14:00:00', '--bs-primary-rgb', NULL),
(786, 'E26', 4.50, '10:00-14:30', '10:00:00', '14:30:00', '--bs-primary-rgb', NULL),
(787, 'E2', 5.00, '10:00-15:00', '10:00:00', '15:00:00', '--bs-primary-rgb', NULL),
(788, 'E27', 5.50, '10:00-15:30', '10:00:00', '15:30:00', '--bs-primary-rgb', NULL),
(789, 'E6', 6.00, '10:00-16:00', '10:00:00', '16:00:00', '--bs-primary-rgb', NULL),
(790, 'E28', 6.50, '10:00-16:30', '10:00:00', '16:30:00', '--bs-primary-rgb', NULL),
(791, 'E7', 7.00, '10:00-17:00', '10:00:00', '17:00:00', '--bs-primary-rgb', NULL),
(792, 'NEP5', 7.00, '10:00-17:00', '10:00:00', '17:00:00', '--bs-primary-rgb', NULL),
(793, 'E29', 7.50, '10:00-17:30', '10:00:00', '17:30:00', '--bs-primary-rgb', NULL),
(794, 'E', 8.00, '10:00-18:00', '10:00:00', '18:00:00', '--bs-primary-rgb', NULL),
(795, 'E30', 8.50, '10:00-18:30', '10:00:00', '18:30:00', '--bs-primary-rgb', NULL),
(796, 'E3', 9.00, '10:00-19:00', '10:00:00', '19:00:00', '--bs-primary-rgb', NULL),
(797, 'E31', 9.50, '10:00-19:30', '10:00:00', '19:30:00', '--bs-primary-rgb', NULL),
(798, 'E10', 10.00, '10:00-20:00', '10:00:00', '20:00:00', '--bs-primary-rgb', NULL),
(799, 'E20', 10.50, '10:00-20:30', '10:00:00', '20:30:00', '--bs-primary-rgb', NULL),
(800, 'E11', 11.00, '10:00-21:00', '10:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(801, 'E13', 11.50, '10:00-21:30', '10:00:00', '21:30:00', '--bs-primary-rgb', NULL),
(802, 'E12', 12.00, '10:00-22:00', '10:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(803, 'E17', 6.00, '10:30-16:30', '10:30:00', '16:30:00', '--bs-primary-rgb', NULL),
(804, 'EE', 8.00, '10:30-18:30', '10:30:00', '18:30:00', '--bs-primary-rgb', NULL),
(805, 'F8', 6.00, '11:00-17:00', '11:00:00', '17:00:00', '--bs-primary-rgb', NULL),
(806, 'F10', 6.50, '11:00-17:30', '11:00:00', '17:30:00', '--bs-primary-rgb', NULL),
(807, 'F7', 7.00, '11:00-18:00', '11:00:00', '18:00:00', '--bs-primary-rgb', NULL),
(808, 'F', 8.00, '11:00-19:00', '11:00:00', '19:00:00', '--bs-primary-rgb', NULL),
(809, 'F9', 9.00, '11:00-20:00', '11:00:00', '20:00:00', '--bs-primary-rgb', NULL),
(810, 'F6', 10.00, '11:00-21:00', '11:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(811, 'F11', 11.00, '11:00-22:00', '11:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(812, 'F2', 10.00, '11:15-21:15', '11:15:00', '21:15:00', '--bs-primary-rgb', NULL),
(813, 'F1', 10.00, '11:30-21:30', '11:30:00', '21:30:00', '--bs-primary-rgb', NULL),
(814, 'G2', 4.00, '12:00-16:00', '12:00:00', '16:00:00', '--bs-primary-rgb', NULL),
(815, 'G5', 5.00, '12:00-17:00', '12:00:00', '17:00:00', '--bs-primary-rgb', NULL),
(816, 'G1', 7.00, '12:00-19:00', '12:00:00', '19:00:00', '--bs-primary-rgb', NULL),
(817, 'G', 8.00, '12:00-20:00', '12:00:00', '20:00:00', '--bs-primary-rgb', NULL),
(818, 'G9', 9.00, '12:00-21:00', '12:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(819, 'G10', 10.00, '12:00-22:00', '12:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(820, 'I1', 4.00, '12:30-16:30', '12:30:00', '16:30:00', '--bs-primary-rgb', NULL),
(821, 'G4', 7.50, '12:30-20:00', '12:30:00', '20:00:00', '--bs-primary-rgb', NULL),
(822, 'GG', 8.00, '12:30-20:30', '12:30:00', '20:30:00', '--bs-primary-rgb', NULL),
(823, 'NOR3', 8.00, '12:30-20:30', '12:30:00', '20:30:00', '--bs-primary-rgb', NULL),
(824, 'G3', 9.00, '12:30-21:30', '12:30:00', '21:30:00', '--bs-primary-rgb', NULL),
(825, 'H2', 4.00, '13:00-17:00', '13:00:00', '17:00:00', '--bs-primary-rgb', NULL),
(826, 'H4', 7.00, '13:00-20:00', '13:00:00', '20:00:00', '--bs-primary-rgb', NULL),
(827, 'H', 8.00, '13:00-21:00', '13:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(828, 'H9', 9.00, '13:00-22:00', '13:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(829, 'H3', 8.00, '13:15-21:15', '13:15:00', '21:15:00', '--bs-primary-rgb', NULL),
(830, 'H1', 8.00, '13:30-21:30', '13:30:00', '21:30:00', '--bs-primary-rgb', NULL),
(831, 'I6', 3.00, '14:00-17:00', '14:00:00', '17:00:00', '--bs-primary-rgb', NULL),
(832, 'I2', 4.00, '14:00-18:00', '14:00:00', '18:00:00', '--bs-primary-rgb', NULL),
(833, 'I4', 5.00, '14:00-19:00', '14:00:00', '19:00:00', '--bs-primary-rgb', NULL),
(834, 'I5', 7.00, '14:00-21:00', '14:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(835, 'I', 8.00, '14:00-22:00', '14:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(836, 'I8', 8.00, '14:00-22:00', '14:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(837, 'I9', 9.00, '14:00-23:00', '14:00:00', '23:00:00', '--bs-primary-rgb', NULL),
(838, 'I7', 8.00, '14:15-22:15', '14:15:00', '22:15:00', '--bs-primary-rgb', NULL),
(839, 'I3', 4.00, '15:00-19:00', '15:00:00', '19:00:00', '--bs-primary-rgb', NULL),
(840, 'J5', 5.00, '15:00-20:00', '15:00:00', '20:00:00', '--bs-primary-rgb', NULL),
(841, 'J2', 6.00, '15:00-21:00', '15:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(842, 'J1', 7.00, '15:00-22:00', '15:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(843, 'J', 8.00, '15:00-23:00', '15:00:00', '23:00:00', '--bs-primary-rgb', NULL),
(844, 'J3', 8.00, '15:30-23:30', '15:30:00', '23:30:00', '--bs-primary-rgb', NULL),
(845, 'K3', 5.00, '16:00-21:00', '16:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(846, 'K4', 6.00, '16:00-22:00', '16:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(847, 'K', 8.00, '16:00-24:00', '16:00:00', '24:00:00', '--bs-primary-rgb', NULL),
(848, 'L', 8.00, '17:00-01:00', '17:00:00', '01:00:00', '--bs-primary-rgb', NULL),
(849, 'L3', 9.00, '17:00-02:00', '17:00:00', '02:00:00', '--bs-primary-rgb', NULL),
(850, 'L4', 10.00, '17:00-03:00', '17:00:00', '03:00:00', '--bs-primary-rgb', NULL),
(851, 'L5', 10.50, '17:00-03:30', '17:00:00', '03:30:00', '--bs-primary-rgb', NULL),
(852, 'L6', 11.00, '17:00-04:00', '17:00:00', '04:00:00', '--bs-primary-rgb', NULL),
(853, 'L7', 11.50, '17:00-04:30', '17:00:00', '04:30:00', '--bs-primary-rgb', NULL),
(854, 'L2', 12.00, '17:00-05:00', '17:00:00', '05:00:00', '--bs-primary-rgb', NULL),
(855, 'L8', 12.00, '17:00-05:00', '17:00:00', '05:00:00', '--bs-primary-rgb', NULL),
(856, 'L1', 4.00, '17:00-21:00', '17:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(857, 'L9', 5.00, '17:00-22:00', '17:00:00', '22:00:00', '--bs-primary-rgb', NULL),
(858, 'M', 8.00, '18:00-02:00', '18:00:00', '02:00:00', '--bs-primary-rgb', NULL),
(859, 'M2', 9.00, '18:00-03:00', '18:00:00', '03:00:00', '--bs-primary-rgb', NULL),
(860, 'M3', 9.50, '18:00-03:30', '18:00:00', '03:30:00', '--bs-primary-rgb', NULL),
(861, 'M4', 10.00, '18:00-04:00', '18:00:00', '04:00:00', '--bs-primary-rgb', NULL),
(862, 'M5', 10.50, '18:00-04:30', '18:00:00', '04:30:00', '--bs-primary-rgb', NULL),
(863, 'M6', 11.00, '18:00-05:00', '18:00:00', '05:00:00', '--bs-primary-rgb', NULL),
(864, 'M7', 11.50, '18:00-05:30', '18:00:00', '05:30:00', '--bs-primary-rgb', NULL),
(865, 'M1', 12.00, '18:00-06:00', '18:00:00', '06:00:00', '--bs-primary-rgb', NULL),
(866, 'M8', 8.00, '18:30-02:30', '18:30:00', '02:30:00', '--bs-primary-rgb', NULL),
(867, 'N', 8.00, '19:00-03:00', '19:00:00', '03:00:00', '--bs-primary-rgb', NULL),
(868, 'N1', 12.00, '19:00-07:00', '19:00:00', '07:00:00', '--bs-primary-rgb', NULL),
(869, 'N3', 8.00, '20:00-04:00', '20:00:00', '04:00:00', '--bs-primary-rgb', NULL),
(870, 'N4', 9.00, '20:00-05:00', '20:00:00', '05:00:00', '--bs-primary-rgb', NULL),
(871, 'P1', 10.00, '21:30-07:30', '21:30:00', '07:30:00', '--bs-primary-rgb', NULL),
(872, 'R', 8.00, '22:00-06:00', '22:00:00', '06:00:00', '--bs-primary-rgb', NULL),
(873, 'N2', 12.00, '22:00-10:00', '22:00:00', '10:00:00', '--bs-primary-rgb', NULL),
(874, 'S', 8.00, '23:00-07:00', '23:00:00', '07:00:00', '--bs-primary-rgb', NULL),
(875, 'URLOP', 8.00, '09:00-17:00', '09:00:00', '17:00:00', '#d97706', NULL),
(876, 'CHCE WOLNE', 0.00, '00:00-00:00', '00:00:00', '00:00:00', '#000000', NULL),
(877, 'DELEG12', 12.00, '09:00-21:00', '09:00:00', '21:00:00', '--bs-primary-rgb', NULL),
(878, 'OFF', 0.00, '00:00-00:00', '00:00:00', '00:00:00', '#4b5563', ',4,'),
(879, 'WS', 0.00, '00:00-00:00', '00:00:00', '00:00:00', '#4b5563', ',4,'),
(880, 'WN', 0.00, '00:00-00:00', '00:00:00', '00:00:00', '#4b5563', ',4,'),
(881, 'WSS', 0.00, '00:00-00:00', '00:00:00', '00:00:00', '--bs-primary-rgb', ''),
(882, 'NST1', 2.00, '10:00-12:00', '10:00:00', '12:00:00', '--bs-primary-rgb', NULL),
(883, 'WOLNE WNIO', 0.00, '00:00-00:00', '00:00:00', '00:00:00', '#000000', NULL);

--
-- Wyzwalacze `shifts`
--
DELIMITER $$
CREATE TRIGGER `shift_times_insert` BEFORE INSERT ON `shifts` FOR EACH ROW BEGIN
  SET NEW.start_time = SUBSTRING_INDEX(NEW.time_interval, '-', 1);
  SET NEW.end_time = SUBSTRING_INDEX(NEW.time_interval, '-', -1);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `shift_times_update` BEFORE UPDATE ON `shifts` FOR EACH ROW BEGIN
  SET NEW.start_time = SUBSTRING_INDEX(NEW.time_interval, '-', 1);
  SET NEW.end_time = SUBSTRING_INDEX(NEW.time_interval, '-', -1);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_categories`
--

CREATE TABLE `stat_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `color` varchar(30) DEFAULT NULL,
  `display_order` decimal(5,1) NOT NULL DEFAULT 10.0,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `stat_categories`
--

INSERT INTO `stat_categories` (`id`, `name`, `color`, `display_order`, `created_by`, `created_at`) VALUES
(1, 'test kat', NULL, 10.0, NULL, '2025-08-02 23:30:08');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_clicks`
--

CREATE TABLE `stat_clicks` (
  `id` bigint(20) NOT NULL,
  `counter_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `value` int(11) NOT NULL DEFAULT 1,
  `click_timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `stat_clicks`
--

INSERT INTO `stat_clicks` (`id`, `counter_id`, `user_id`, `sfid_id`, `value`, `click_timestamp`) VALUES
(1, 3, 4, 20004014, 1, '2025-07-31 09:14:39'),
(2, 2, 4, 20004014, 1, '2025-07-31 09:14:40'),
(3, 2, 4, 20004014, 1, '2025-07-31 09:14:40'),
(4, 2, 4, 20004014, -1, '2025-07-31 09:14:41'),
(5, 2, 4, 20004014, -1, '2025-07-31 09:14:42'),
(6, 3, 4, 20004014, -1, '2025-07-31 09:14:43'),
(7, 2, 4, 20004014, -1, '2025-07-31 09:16:01'),
(8, 2, 4, 20004014, 1, '2025-07-31 09:16:02'),
(9, 5, 4, 20004014, 1, '2025-07-31 14:53:58'),
(10, 5, 4, 20004014, 1, '2025-07-31 14:53:59'),
(11, 5, 4, 20004014, 1, '2025-07-31 14:54:00'),
(12, 5, 4, 20004014, 1, '2025-07-31 14:54:01'),
(13, 5, 4, 20004014, -1, '2025-07-31 14:54:01'),
(14, 5, 4, 20004014, -1, '2025-07-31 14:54:02'),
(15, 5, 4, 20004014, -1, '2025-07-31 14:54:02'),
(16, 5, 4, 20004014, -1, '2025-07-31 14:54:03'),
(17, 5, 4, 20004014, -10, '2025-07-31 14:54:07'),
(18, 5, 4, 20004014, 10, '2025-07-31 14:54:12'),
(19, 10, 4, 20004014, 1, '2025-07-31 14:59:15'),
(20, 10, 4, 20004014, 1, '2025-07-31 14:59:17'),
(21, 10, 4, 20004014, -1, '2025-07-31 14:59:19'),
(22, 10, 4, 20004014, -1, '2025-07-31 14:59:20'),
(23, 4, 4, 20004014, 1, '2025-07-31 15:02:56'),
(24, 4, 4, 20004014, -1, '2025-07-31 15:02:57'),
(25, 4, 4, 20004014, 1, '2025-07-31 15:03:23'),
(28, 16, 4, 20004014, 1, '2025-07-31 22:00:00'),
(30, 16, 7, 20004014, 1, '2025-07-31 22:00:00'),
(31, 16, 5, 20004014, 1, '2025-07-31 22:00:00'),
(32, 2, 4, 20004014, 1, '2025-07-31 22:00:00'),
(33, 2, 4, 20004014, -1, '2025-07-31 22:00:00'),
(34, 6, 4, 20004014, 1, '2025-07-31 22:00:00'),
(35, 6, 4, 20004014, -1, '2025-07-31 22:00:00'),
(36, 5, 4, 20004014, 1, '2025-07-31 22:00:00'),
(37, 10, 4, 20004014, 1, '2025-07-31 22:00:00'),
(38, 10, 7, 20004014, 1, '2025-07-31 22:00:00'),
(39, 10, 7, 20004014, -1, '2025-07-31 22:00:00'),
(40, 5, 7, 20004014, 1, '2025-07-31 22:00:00'),
(41, 5, 7, 20004014, -1, '2025-07-31 22:00:00'),
(42, 10, 4, 20004014, -1, '2025-07-31 22:00:00'),
(43, 16, 4, 20004014, -1, '2025-07-31 22:00:00'),
(44, 16, 7, 20004014, -1, '2025-07-31 22:00:00'),
(45, 16, 5, 20004014, -1, '2025-07-31 22:00:00'),
(46, 17, 7, 20004014, 1, '2025-07-31 22:00:00'),
(47, 17, 7, 20004014, -1, '2025-07-31 22:00:00'),
(48, 4, 7, 20004014, 1, '2025-07-31 22:00:00'),
(49, 4, 7, 20004014, -1, '2025-07-31 22:00:00'),
(50, 2, 7, 20004014, 1, '2025-07-31 22:00:00'),
(51, 3, 7, 20004014, 1, '2025-07-31 22:00:00'),
(52, 2, 4, 20004014, 1, '2025-07-31 22:00:00'),
(53, 3, 7, 20004014, -1, '2025-07-31 22:00:00'),
(54, 2, 7, 20004014, -1, '2025-07-31 22:00:00'),
(55, 2, 4, 20004014, -1, '2025-07-31 22:00:00'),
(56, 5, 7, 20004014, 1, '2025-07-31 22:00:00'),
(57, 5, 7, 20004014, -1, '2025-07-31 22:00:00'),
(58, 5, 4, 20004014, -1, '2025-07-31 22:00:00'),
(59, 5, 4, 20004014, 1, '2025-07-31 22:00:00'),
(60, 5, 4, 20004014, -1, '2025-07-31 22:00:00'),
(61, 6, 4, 20004014, 1, '2025-07-31 22:00:00'),
(62, 6, 4, 20004014, -1, '2025-07-31 22:00:00'),
(63, 10, 4, 20004014, 1, '2025-07-31 22:00:00'),
(64, 11, 4, 20004014, 1, '2025-07-31 22:00:00'),
(65, 10, 7, 20004014, 1, '2025-07-31 22:00:00'),
(66, 11, 7, 20004014, 1, '2025-07-31 22:00:00'),
(67, 11, 7, 20004014, -1, '2025-07-31 22:00:00'),
(68, 10, 7, 20004014, -1, '2025-07-31 22:00:00'),
(69, 10, 4, 20004014, -1, '2025-07-31 22:00:00'),
(70, 11, 4, 20004014, -1, '2025-07-31 22:00:00'),
(71, 5, 4, 20004014, 1, '2025-07-31 22:00:00'),
(72, 5, 4, 20004014, -1, '2025-07-31 22:00:00'),
(73, 3, 7, 20004014, 3, '2025-07-31 22:00:00'),
(74, 5, 7, 20004014, 1, '2025-07-31 22:00:00'),
(75, 4, 7, 20004014, 8, '2025-07-31 22:00:00'),
(76, 5, 4, 20004014, 1, '2025-07-31 22:00:00'),
(77, 22, 7, 20004014, 1, '2025-07-31 22:00:00'),
(78, 4, 4, 20004014, 1, '2025-07-31 22:00:00'),
(79, 4, 4, 20004014, -1, '2025-07-31 22:00:00'),
(80, 4, 4, 20004014, 3, '2025-07-31 22:00:00'),
(81, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(82, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(83, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(84, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(85, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(86, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(87, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(88, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(89, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(90, 19, 4, 20004014, 1, '2025-07-31 22:00:00'),
(91, 2, 4, 20004014, 1, '2025-07-31 22:00:00'),
(92, 2, 4, 20004014, 1, '2025-07-31 22:00:00'),
(93, 3, 4, 20004014, 1, '2025-07-31 22:00:00'),
(94, 2, 7, 20004014, 1, '2025-07-31 22:00:00'),
(95, 19, 4, 20004014, 20, '2025-07-31 22:00:00'),
(96, 19, 4, 20004014, 115, '2025-07-31 22:00:00'),
(97, 19, 7, 20004014, 97, '2025-07-31 22:00:00'),
(98, 5, 7, 20004014, 1, '2025-07-31 22:00:00'),
(99, 2, 4, 20004014, 1, '2025-07-31 22:00:00'),
(100, 3, 4, 20004014, 1, '2025-07-31 22:00:00'),
(101, 17, 4, 20004014, 1, '2025-07-31 22:00:00'),
(102, 19, 4, 20004014, 45, '2025-07-31 22:00:00'),
(103, 4, 4, 20004014, 8, '2025-07-31 22:00:00'),
(104, 4, 4, 20004014, 8, '2025-07-31 22:00:00'),
(105, 2, 4, 20004014, 1, '2025-07-31 22:00:00'),
(106, 3, 4, 20004014, 1, '2025-07-31 22:00:00'),
(107, 3, 4, 20004014, 1, '2025-07-31 22:00:00'),
(108, 19, 4, 20004014, 190, '2025-07-31 22:00:00');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_counters`
--

CREATE TABLE `stat_counters` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `stat_category_id` int(11) DEFAULT NULL,
  `display_order` decimal(5,1) NOT NULL DEFAULT 10.0,
  `color` varchar(30) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL COMMENT 'NULL dla globalnych/przypisanych, ID usera dla osobistych',
  `assigned_user_id` int(11) DEFAULT NULL COMMENT 'ID usera dla którego licznik jest dedykowany (gdy user_id=NULL)',
  `sfid_id` int(11) DEFAULT NULL,
  `location_category_id` int(11) DEFAULT NULL,
  `is_sfid_summary` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('active','archived') DEFAULT 'active',
  `created_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `stat_counters`
--

INSERT INTO `stat_counters` (`id`, `name`, `stat_category_id`, `display_order`, `color`, `user_id`, `assigned_user_id`, `sfid_id`, `location_category_id`, `is_sfid_summary`, `status`, `created_by`, `created_at`) VALUES
(1, 'Pozyskanie', NULL, 1.0, '#000000', NULL, NULL, NULL, NULL, 1, 'active', 4, '2025-07-31 09:13:50'),
(2, 'Pozyskanie ISP', NULL, 2.0, NULL, NULL, NULL, NULL, NULL, 0, 'active', 4, '2025-07-31 09:14:05'),
(3, 'Pozyskanie INNE', NULL, 1.0, NULL, NULL, NULL, NULL, NULL, 0, 'active', 4, '2025-07-31 09:14:16'),
(4, 'Zatrzymanie', NULL, 7.0, NULL, NULL, NULL, NULL, 1, 0, 'active', 4, '2025-07-31 09:15:08'),
(5, 'Telefony', NULL, 9.5, NULL, NULL, NULL, NULL, 1, 0, 'active', 4, '2025-07-31 14:51:27'),
(6, 'NKS', NULL, 11.0, NULL, NULL, NULL, NULL, 1, 0, 'active', 4, '2025-07-31 14:51:45'),
(7, 'Router/Modem', NULL, 12.0, NULL, NULL, NULL, NULL, 1, 0, 'active', 4, '2025-07-31 14:52:51'),
(8, 'Sprzęt TOTAL', NULL, 9.0, '#ff0000', NULL, NULL, 20004014, NULL, 1, 'active', 4, '2025-07-31 14:53:16'),
(9, 'Baza TOTAL', NULL, 10.0, NULL, NULL, NULL, 20004014, NULL, 1, 'active', 4, '2025-07-31 14:57:56'),
(10, 'ND/OD', NULL, 10.0, NULL, NULL, NULL, NULL, 1, 0, 'active', 4, '2025-07-31 14:58:55'),
(11, 'Odebrane', NULL, 10.0, NULL, NULL, NULL, NULL, 1, 0, 'active', 4, '2025-07-31 14:59:07'),
(12, 'Δ Delta TOTAL', NULL, 9.0, '#f50000', NULL, NULL, 20004014, NULL, 1, 'active', 4, '2025-07-31 15:02:14'),
(16, 'VAS SU TOTAL', NULL, 10.0, '#ff0000', NULL, NULL, NULL, NULL, 1, 'active', 4, '2025-08-01 09:33:15'),
(17, 'VAS SU', NULL, 10.0, NULL, NULL, NULL, 20004014, NULL, 0, 'active', 4, '2025-08-01 09:41:52'),
(18, 'VAS INNE', NULL, 10.0, NULL, NULL, NULL, 20004014, NULL, 0, 'active', 4, '2025-08-01 09:42:10'),
(19, 'DELTA', NULL, 10.0, NULL, NULL, NULL, 20004014, NULL, 0, 'active', 4, '2025-08-01 09:43:31'),
(20, 'Zatrzymanie TOTAL', NULL, 10.0, '#ff0000', NULL, NULL, 20004014, NULL, 1, 'active', 4, '2025-08-01 09:44:46'),
(21, 'TELEFONY TOTAL', NULL, 10.0, '#ff0000', NULL, NULL, 20004014, NULL, 1, 'active', 4, '2025-08-01 10:16:48'),
(22, 'Akcesoria', NULL, 10.0, NULL, NULL, NULL, 20004014, NULL, 0, 'active', 4, '2025-08-01 10:17:49'),
(23, 'VAS INNE TOTAL', NULL, 10.0, '#ff0000', NULL, NULL, NULL, NULL, 1, 'active', 4, '2025-08-01 10:37:26'),
(24, 'NKS TOTAL', NULL, 10.0, '#ff0000', NULL, NULL, NULL, NULL, 1, 'active', 4, '2025-08-01 10:42:42'),
(25, 'Pozyskanie ISP TOTAL', NULL, 10.0, '#000000', NULL, NULL, NULL, NULL, 1, 'active', 4, '2025-08-01 10:49:07'),
(26, 'Akcesoria TOTAL', NULL, 10.0, '#ff0000', NULL, NULL, NULL, NULL, 1, 'active', 4, '2025-08-01 10:50:21');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_counters_new`
--

CREATE TABLE `stat_counters_new` (
  `id` int(11) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `increment` int(11) NOT NULL DEFAULT 1,
  `type` enum('number','currency') NOT NULL DEFAULT 'number',
  `symbol` varchar(10) DEFAULT NULL,
  `category_id` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `display_order` decimal(5,1) NOT NULL DEFAULT 10.0,
  `color` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `stat_counters_new`
--

INSERT INTO `stat_counters_new` (`id`, `sfid_id`, `title`, `increment`, `type`, `symbol`, `category_id`, `is_active`, `is_default`, `display_order`, `color`) VALUES
(6, 20004014, 'test', 1, 'currency', 'zł', 1, 1, 1, 1.0, NULL),
(7, 20004014, 'test', 1, 'number', NULL, 1, 0, 0, 99.0, NULL);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_counter_sums`
--

CREATE TABLE `stat_counter_sums` (
  `summary_counter_id` int(11) NOT NULL,
  `source_counter_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `stat_counter_sums`
--

INSERT INTO `stat_counter_sums` (`summary_counter_id`, `source_counter_id`) VALUES
(1, 2),
(1, 3),
(8, 5),
(8, 6),
(8, 7),
(9, 10),
(9, 11),
(12, 19),
(16, 17),
(20, 4),
(21, 5),
(23, 18),
(24, 6),
(25, 2),
(26, 22);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_daily_values_new`
--

CREATE TABLE `stat_daily_values_new` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `user_id` int(11) NOT NULL,
  `counter_id` int(11) NOT NULL,
  `value` int(11) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_kpi_adjustments_new`
--

CREATE TABLE `stat_kpi_adjustments_new` (
  `id` int(11) NOT NULL,
  `kpi_goal_id` int(11) NOT NULL,
  `month` varchar(7) NOT NULL COMMENT 'Format: YYYY-MM',
  `value` int(11) NOT NULL,
  `reason` text DEFAULT NULL,
  `admin_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_kpi_goals_new`
--

CREATE TABLE `stat_kpi_goals_new` (
  `id` int(11) NOT NULL,
  `sfid_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `totalGoal` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `stat_kpi_goals_new`
--

INSERT INTO `stat_kpi_goals_new` (`id`, `sfid_id`, `name`, `totalGoal`, `is_active`) VALUES
(1, 20004014, 'Umowy w miesiącu', 50, 0),
(2, 20004014, 'cel', 1, 0),
(3, 20004014, 'test', 1, 0);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `stat_kpi_linked_counters_new`
--

CREATE TABLE `stat_kpi_linked_counters_new` (
  `kpi_goal_id` int(11) NOT NULL,
  `counter_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `personal_number` varchar(20) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role` enum('user','admin','superadmin') NOT NULL DEFAULT 'user',
  `sfid_id` int(11) DEFAULT NULL,
  `privacy_settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '{"show_phone": false}' CHECK (json_valid(`privacy_settings`)),
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `email2` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `users`
--

INSERT INTO `users` (`id`, `personal_number`, `name`, `email`, `password_hash`, `phone`, `role`, `sfid_id`, `privacy_settings`, `last_login`, `created_at`, `email2`, `is_active`) VALUES
(1, 'SU', 'AdminTest', 'test@test.pl', '$2y$10$Ce3BX4XBeCYjdvcWvZHRw.9i.DzDDwiQhoZK.LveKX9Dt2HECHZ42', '', 'admin', 29999999, NULL, '2025-08-03 15:34:54', '2025-04-07 00:54:45', 'pergamin@abc0.pl', 1),
(4, '22004142', 'Jakub Jaworowicz', 'jakub.jaworowicz@salon.liberty.eu', '$2y$10$y5TIF.odoUvOZwQtY4IQDePynT3.k0QXbm7szMjDGPEnJn8g//Ry.', '+48535920913', 'superadmin', 20004014, '\"{\\\"show_phone\\\":\\\"on\\\"}\"', '2025-08-03 16:04:03', '2025-04-07 02:22:46', 'kuba@jaworowi.cz', 1),
(5, '22005892', 'Martyna Piętak', 'martyna.pietak@salon.liberty.eu', '$2y$10$QYhvPkEfP9VLtqmuntCCLernJj9I0Bt2j5ng0put0kIxDkOlcSs0y', NULL, 'user', 20004014, NULL, '2025-08-01 15:38:08', '2025-04-07 00:54:45', 'martyna.pietak@gmail.com', 1),
(7, '22005755', 'Dominik Dechnik', 'dominik.dechnik@salon.liberty.eu', '$2y$10$QYhvPkEfP9VLtqmuntCCLernJj9I0Bt2j5ng0put0kIxDkOlcSs0y', NULL, 'user', 20004014, NULL, '2025-08-02 13:08:37', '2025-04-07 00:54:45', 'dechnik.dominik@gmail.com', 1),
(8, '22005250', 'User', 'test@user.pl', '$2y$10$c6YW2VmX8c7qpGkPcukZluoNA2ncR74TsOd892Ofb.un0d2kiYPH2', '123456789', 'user', 29999999, '\"{\\\"show_phone\\\":\\\"on\\\"}\"', '2025-08-01 10:05:00', '2025-04-07 02:22:46', '', 1),
(9, '', 'testFormularz', 'test@test2.pl', '$2y$10$VSqTdwReEkQznAvzdlbtge6r5HIpvmU9kP3WRlB33aCCbeMVIR2SO', NULL, 'user', 29999999, '{\"show_phone\": false}', '2025-07-29 23:21:24', '2025-07-29 21:20:59', NULL, 0);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `vacations`
--

CREATE TABLE `vacations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `reason` text NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `vacations`
--

INSERT INTO `vacations` (`id`, `user_id`, `start_date`, `end_date`, `reason`, `status`, `approved_by`, `approved_at`, `created_at`) VALUES
(14, 5, '2025-04-01', '2025-04-04', 'Oczekiwanie na zatwierdzenie zatrudnienia.', 'approved', NULL, NULL, '2025-04-13 11:58:57'),
(17, 5, '2025-04-07', '2025-04-11', 'Oczekiwanie na zatwierdzenie zatrudnienia.', 'approved', NULL, NULL, '2025-04-13 11:58:57'),
(20, 4, '2025-08-21', '2025-08-22', 'Urlop dodany przez administratora', 'approved', 4, '2025-07-25 12:13:23', '2025-04-09 12:04:41'),
(21, 4, '2025-02-24', '2025-02-28', 'Urlop dodany przez administratora', 'approved', NULL, NULL, '2025-04-09 12:04:41'),
(22, 4, '2025-03-03', '2025-03-07', 'Urlop dodany przez administratora', 'approved', NULL, NULL, '2025-04-09 12:04:41'),
(24, 7, '2025-03-19', '2025-03-19', 'Urlop dodany przez administratora', 'approved', NULL, NULL, '2025-04-23 14:30:15'),
(25, 7, '2025-03-21', '2025-03-21', 'Urlop dodany przez administratora', 'approved', NULL, NULL, '2025-04-23 14:30:24'),
(26, 7, '2025-03-25', '2025-03-25', 'Urlop dodany przez administratora', 'approved', NULL, NULL, '2025-04-23 14:30:36'),
(27, 7, '2025-03-27', '2025-03-27', 'Urlop dodany przez administratora', 'approved', NULL, NULL, '2025-04-23 14:30:43'),
(28, 7, '2025-03-28', '2025-03-28', 'Urlop dodany przez administratora', 'approved', NULL, NULL, '2025-04-23 14:30:56'),
(34, 4, '2025-08-07', '2025-08-10', 'SAP FIORI', 'approved', NULL, NULL, '2025-07-12 13:12:10'),
(36, 7, '2025-10-27', '2025-11-09', 'Urlop', 'approved', NULL, NULL, '2025-07-12 13:15:39'),
(37, 5, '2025-09-26', '2025-10-09', 'SAP Urlop 14', 'approved', 4, '2025-07-12 15:30:28', '2025-07-12 13:27:38'),
(38, 8, '2025-07-31', '2025-08-01', 'jednak nie jade', 'rejected', 1, '2025-07-26 11:06:56', '2025-07-23 21:05:26'),
(39, 8, '2025-08-05', '2025-08-06', 'jakis tam urlop', 'rejected', 1, '2025-07-24 16:05:37', '2025-07-24 13:41:45'),
(40, 1, '2025-08-18', '2025-08-19', 'test', 'rejected', 1, '2025-07-24 16:02:16', '2025-07-24 14:02:01'),
(41, 1, '2025-07-28', '2025-07-29', 'jujun', 'approved', 1, '2025-07-26 11:07:57', '2025-07-26 09:07:54'),
(42, 1, '2025-08-07', '2025-08-07', 'urlop', 'approved', 1, '2025-07-30 09:08:51', '2025-07-30 07:08:44');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `wishes_limits`
--

CREATE TABLE `wishes_limits` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `sfid_id` int(11) DEFAULT NULL,
  `year` smallint(4) NOT NULL,
  `month` tinyint(2) NOT NULL,
  `limit_count` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `app_menu`
--
ALTER TABLE `app_menu`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`);

--
-- Indeksy dla tabeli `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeksy dla tabeli `dashboard_announcements`
--
ALTER TABLE `dashboard_announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sfid_id` (`sfid_id`);

--
-- Indeksy dla tabeli `dashboard_cards`
--
ALTER TABLE `dashboard_cards`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `global_working_hours`
--
ALTER TABLE `global_working_hours`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sfid_id` (`sfid_id`,`year`,`month`);

--
-- Indeksy dla tabeli `invitation_codes`
--
ALTER TABLE `invitation_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `sfid_id` (`sfid_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indeksy dla tabeli `kpi_goals`
--
ALTER TABLE `kpi_goals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_kpi_counter_id` (`counter_id`),
  ADD KEY `fk_kpi_stat_category_id` (`stat_category_id`),
  ADD KEY `fk_kpi_creator` (`created_by`);

--
-- Indeksy dla tabeli `licznik_categories`
--
ALTER TABLE `licznik_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sfid_active` (`sfid_id`,`is_active`);

--
-- Indeksy dla tabeli `licznik_counters`
--
ALTER TABLE `licznik_counters`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `idx_sfid_active` (`sfid_id`,`is_active`),
  ADD KEY `idx_default` (`is_default`);

--
-- Indeksy dla tabeli `licznik_daily_values`
--
ALTER TABLE `licznik_daily_values`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `daily_unique` (`date`,`user_id`,`counter_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_date_user` (`date`,`user_id`),
  ADD KEY `idx_counter_date` (`counter_id`,`date`);

--
-- Indeksy dla tabeli `licznik_kpi_adjustments`
--
ALTER TABLE `licznik_kpi_adjustments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `idx_kpi_month` (`kpi_goal_id`,`month`);

--
-- Indeksy dla tabeli `licznik_kpi_goals`
--
ALTER TABLE `licznik_kpi_goals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sfid_active` (`sfid_id`,`is_active`);

--
-- Indeksy dla tabeli `licznik_kpi_linked_counters`
--
ALTER TABLE `licznik_kpi_linked_counters`
  ADD PRIMARY KEY (`kpi_goal_id`,`counter_id`),
  ADD KEY `counter_id` (`counter_id`);

--
-- Indeksy dla tabeli `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeksy dla tabeli `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeksy dla tabeli `pomidor_corrections`
--
ALTER TABLE `pomidor_corrections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_employee` (`employee_id`),
  ADD KEY `idx_creator` (`created_by`);

--
-- Indeksy dla tabeli `schedules`
--
ALTER TABLE `schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `shift_id` (`shift_id`),
  ADD KEY `sfid_id` (`sfid_id`);

--
-- Indeksy dla tabeli `schedule_locks`
--
ALTER TABLE `schedule_locks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sfid_month` (`sfid_id`,`month_date`),
  ADD KEY `locked_by_user_id` (`locked_by_user_id`);

--
-- Indeksy dla tabeli `schedule_requests`
--
ALTER TABLE `schedule_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `schedule_entry_id` (`schedule_entry_id`);

--
-- Indeksy dla tabeli `sfid_locations`
--
ALTER TABLE `sfid_locations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `fk_location_category_id_new` (`location_category_id`);

--
-- Indeksy dla tabeli `sfid_location_categories`
--
ALTER TABLE `sfid_location_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indeksy dla tabeli `shifts`
--
ALTER TABLE `shifts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `symbol` (`symbol`);

--
-- Indeksy dla tabeli `stat_categories`
--
ALTER TABLE `stat_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `fk_stat_cat_created_by` (`created_by`);

--
-- Indeksy dla tabeli `stat_clicks`
--
ALTER TABLE `stat_clicks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_scl_counter` (`counter_id`),
  ADD KEY `fk_scl_user` (`user_id`);

--
-- Indeksy dla tabeli `stat_counters`
--
ALTER TABLE `stat_counters`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_sc_stat_category_id` (`stat_category_id`),
  ADD KEY `fk_sc_owner` (`user_id`),
  ADD KEY `fk_sc_assigned_user` (`assigned_user_id`),
  ADD KEY `fk_sc_creator` (`created_by`),
  ADD KEY `fk_sc_sfid` (`sfid_id`),
  ADD KEY `fk_sc_loc_cat` (`location_category_id`);

--
-- Indeksy dla tabeli `stat_counters_new`
--
ALTER TABLE `stat_counters_new`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sfid_id` (`sfid_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indeksy dla tabeli `stat_counter_sums`
--
ALTER TABLE `stat_counter_sums`
  ADD PRIMARY KEY (`summary_counter_id`,`source_counter_id`),
  ADD KEY `fk_sums_source` (`source_counter_id`);

--
-- Indeksy dla tabeli `stat_daily_values_new`
--
ALTER TABLE `stat_daily_values_new`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `daily_unique` (`date`,`user_id`,`counter_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `counter_id` (`counter_id`);

--
-- Indeksy dla tabeli `stat_kpi_adjustments_new`
--
ALTER TABLE `stat_kpi_adjustments_new`
  ADD PRIMARY KEY (`id`),
  ADD KEY `kpi_goal_id` (`kpi_goal_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indeksy dla tabeli `stat_kpi_goals_new`
--
ALTER TABLE `stat_kpi_goals_new`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sfid_id` (`sfid_id`);

--
-- Indeksy dla tabeli `stat_kpi_linked_counters_new`
--
ALTER TABLE `stat_kpi_linked_counters_new`
  ADD PRIMARY KEY (`kpi_goal_id`,`counter_id`),
  ADD KEY `counter_id` (`counter_id`);

--
-- Indeksy dla tabeli `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_number` (`personal_number`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `sfid_id` (`sfid_id`);

--
-- Indeksy dla tabeli `vacations`
--
ALTER TABLE `vacations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeksy dla tabeli `wishes_limits`
--
ALTER TABLE `wishes_limits`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `scope_limit` (`user_id`,`sfid_id`,`year`,`month`),
  ADD KEY `sfid_id` (`sfid_id`);

--
-- AUTO_INCREMENT dla zrzuconych tabel
--

--
-- AUTO_INCREMENT dla tabeli `app_menu`
--
ALTER TABLE `app_menu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT dla tabeli `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT dla tabeli `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4446;

--
-- AUTO_INCREMENT dla tabeli `dashboard_announcements`
--
ALTER TABLE `dashboard_announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT dla tabeli `dashboard_cards`
--
ALTER TABLE `dashboard_cards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT dla tabeli `global_working_hours`
--
ALTER TABLE `global_working_hours`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT dla tabeli `invitation_codes`
--
ALTER TABLE `invitation_codes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT dla tabeli `kpi_goals`
--
ALTER TABLE `kpi_goals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT dla tabeli `licznik_categories`
--
ALTER TABLE `licznik_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT dla tabeli `licznik_counters`
--
ALTER TABLE `licznik_counters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT dla tabeli `licznik_daily_values`
--
ALTER TABLE `licznik_daily_values`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=199;

--
-- AUTO_INCREMENT dla tabeli `licznik_kpi_adjustments`
--
ALTER TABLE `licznik_kpi_adjustments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `licznik_kpi_goals`
--
ALTER TABLE `licznik_kpi_goals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT dla tabeli `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT dla tabeli `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `pomidor_corrections`
--
ALTER TABLE `pomidor_corrections`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT dla tabeli `schedules`
--
ALTER TABLE `schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1159;

--
-- AUTO_INCREMENT dla tabeli `schedule_locks`
--
ALTER TABLE `schedule_locks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT dla tabeli `schedule_requests`
--
ALTER TABLE `schedule_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT dla tabeli `sfid_location_categories`
--
ALTER TABLE `sfid_location_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT dla tabeli `shifts`
--
ALTER TABLE `shifts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=884;

--
-- AUTO_INCREMENT dla tabeli `stat_categories`
--
ALTER TABLE `stat_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- AUTO_INCREMENT dla tabeli `stat_clicks`
--
ALTER TABLE `stat_clicks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=109;

--
-- AUTO_INCREMENT dla tabeli `stat_counters`
--
ALTER TABLE `stat_counters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT dla tabeli `stat_counters_new`
--
ALTER TABLE `stat_counters_new`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT dla tabeli `stat_daily_values_new`
--
ALTER TABLE `stat_daily_values_new`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `stat_kpi_adjustments_new`
--
ALTER TABLE `stat_kpi_adjustments_new`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `stat_kpi_goals_new`
--
ALTER TABLE `stat_kpi_goals_new`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT dla tabeli `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT dla tabeli `vacations`
--
ALTER TABLE `vacations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT dla tabeli `wishes_limits`
--
ALTER TABLE `wishes_limits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ograniczenia dla tabeli `dashboard_announcements`
--
ALTER TABLE `dashboard_announcements`
  ADD CONSTRAINT `dashboard_announcements_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE SET NULL;

--
-- Ograniczenia dla tabeli `global_working_hours`
--
ALTER TABLE `global_working_hours`
  ADD CONSTRAINT `global_working_hours_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `invitation_codes`
--
ALTER TABLE `invitation_codes`
  ADD CONSTRAINT `invitation_codes_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `invitation_codes_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `kpi_goals`
--
ALTER TABLE `kpi_goals`
  ADD CONSTRAINT `fk_kpi_counter_id` FOREIGN KEY (`counter_id`) REFERENCES `stat_counters` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_kpi_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_kpi_stat_category_id` FOREIGN KEY (`stat_category_id`) REFERENCES `stat_categories` (`id`) ON DELETE SET NULL;

--
-- Ograniczenia dla tabeli `licznik_categories`
--
ALTER TABLE `licznik_categories`
  ADD CONSTRAINT `licznik_categories_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `licznik_counters`
--
ALTER TABLE `licznik_counters`
  ADD CONSTRAINT `licznik_counters_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `licznik_counters_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `licznik_categories` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `licznik_daily_values`
--
ALTER TABLE `licznik_daily_values`
  ADD CONSTRAINT `licznik_daily_values_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `licznik_daily_values_ibfk_2` FOREIGN KEY (`counter_id`) REFERENCES `licznik_counters` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `licznik_kpi_adjustments`
--
ALTER TABLE `licznik_kpi_adjustments`
  ADD CONSTRAINT `licznik_kpi_adjustments_ibfk_1` FOREIGN KEY (`kpi_goal_id`) REFERENCES `licznik_kpi_goals` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `licznik_kpi_adjustments_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`);

--
-- Ograniczenia dla tabeli `licznik_kpi_goals`
--
ALTER TABLE `licznik_kpi_goals`
  ADD CONSTRAINT `licznik_kpi_goals_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `licznik_kpi_linked_counters`
--
ALTER TABLE `licznik_kpi_linked_counters`
  ADD CONSTRAINT `licznik_kpi_linked_counters_ibfk_1` FOREIGN KEY (`kpi_goal_id`) REFERENCES `licznik_kpi_goals` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `licznik_kpi_linked_counters_ibfk_2` FOREIGN KEY (`counter_id`) REFERENCES `licznik_counters` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `password_resets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ograniczenia dla tabeli `pomidor_corrections`
--
ALTER TABLE `pomidor_corrections`
  ADD CONSTRAINT `fk_pomidor_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pomidor_employee` FOREIGN KEY (`employee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ograniczenia dla tabeli `schedules`
--
ALTER TABLE `schedules`
  ADD CONSTRAINT `schedules_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedules_ibfk_2` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedules_ibfk_3` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `schedule_locks`
--
ALTER TABLE `schedule_locks`
  ADD CONSTRAINT `schedule_locks_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedule_locks_ibfk_2` FOREIGN KEY (`locked_by_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `sfid_locations`
--
ALTER TABLE `sfid_locations`
  ADD CONSTRAINT `fk_location_category_id_new` FOREIGN KEY (`location_category_id`) REFERENCES `sfid_location_categories` (`id`) ON DELETE SET NULL;

--
-- Ograniczenia dla tabeli `stat_categories`
--
ALTER TABLE `stat_categories`
  ADD CONSTRAINT `fk_stat_cat_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Ograniczenia dla tabeli `stat_clicks`
--
ALTER TABLE `stat_clicks`
  ADD CONSTRAINT `fk_scl_counter` FOREIGN KEY (`counter_id`) REFERENCES `stat_counters` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_scl_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `stat_counters`
--
ALTER TABLE `stat_counters`
  ADD CONSTRAINT `fk_sc_assigned_user` FOREIGN KEY (`assigned_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sc_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sc_loc_cat` FOREIGN KEY (`location_category_id`) REFERENCES `sfid_location_categories` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sc_owner` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sc_sfid` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sc_stat_category_id` FOREIGN KEY (`stat_category_id`) REFERENCES `stat_categories` (`id`) ON DELETE SET NULL;

--
-- Ograniczenia dla tabeli `stat_counters_new`
--
ALTER TABLE `stat_counters_new`
  ADD CONSTRAINT `stat_counters_new_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `stat_counters_new_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `stat_categories` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `stat_counter_sums`
--
ALTER TABLE `stat_counter_sums`
  ADD CONSTRAINT `fk_sums_source` FOREIGN KEY (`source_counter_id`) REFERENCES `stat_counters` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sums_summary` FOREIGN KEY (`summary_counter_id`) REFERENCES `stat_counters` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `stat_daily_values_new`
--
ALTER TABLE `stat_daily_values_new`
  ADD CONSTRAINT `stat_daily_values_new_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `stat_daily_values_new_ibfk_2` FOREIGN KEY (`counter_id`) REFERENCES `stat_counters_new` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `stat_kpi_adjustments_new`
--
ALTER TABLE `stat_kpi_adjustments_new`
  ADD CONSTRAINT `stat_kpi_adjustments_new_ibfk_1` FOREIGN KEY (`kpi_goal_id`) REFERENCES `stat_kpi_goals_new` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `stat_kpi_adjustments_new_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `stat_kpi_goals_new`
--
ALTER TABLE `stat_kpi_goals_new`
  ADD CONSTRAINT `stat_kpi_goals_new_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `stat_kpi_linked_counters_new`
--
ALTER TABLE `stat_kpi_linked_counters_new`
  ADD CONSTRAINT `stat_kpi_linked_counters_new_ibfk_1` FOREIGN KEY (`kpi_goal_id`) REFERENCES `stat_kpi_goals_new` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `stat_kpi_linked_counters_new_ibfk_2` FOREIGN KEY (`counter_id`) REFERENCES `stat_counters_new` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`) ON DELETE SET NULL;

--
-- Ograniczenia dla tabeli `vacations`
--
ALTER TABLE `vacations`
  ADD CONSTRAINT `vacations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ograniczenia dla tabeli `wishes_limits`
--
ALTER TABLE `wishes_limits`
  ADD CONSTRAINT `wishes_limits_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
