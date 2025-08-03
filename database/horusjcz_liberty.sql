
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
-- Struktura tabeli dla tabeli `sfid_locations`
--

CREATE TABLE `sfid_locations` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Zrzut danych tabeli `sfid_locations`
--

INSERT INTO `sfid_locations` (`id`, `name`, `address`, `is_active`, `created_at`) VALUES
(20004014, 'Pasaż Grunwaldzki', 'Pl. Grunwaldzki 22, 50-363 Wrocław', 1, '2025-08-03 01:57:10'),
(29999999, 'Testowa', 'ul. Centralna 1', 1, '2025-08-03 01:57:10');

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `licznik_categories`
--
ALTER TABLE `licznik_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sfid_id` (`sfid_id`);

--
-- Indeksy dla tabeli `licznik_counters`
--
ALTER TABLE `licznik_counters`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sfid_id` (`sfid_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indeksy dla tabeli `licznik_daily_values`
--
ALTER TABLE `licznik_daily_values`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_counter_date` (`date`,`user_id`,`counter_id`),
  ADD KEY `counter_id` (`counter_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `date` (`date`);

--
-- Indeksy dla tabeli `licznik_kpi_goals`
--
ALTER TABLE `licznik_kpi_goals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sfid_id` (`sfid_id`);

--
-- Indeksy dla tabeli `licznik_kpi_linked_counters`
--
ALTER TABLE `licznik_kpi_linked_counters`
  ADD PRIMARY KEY (`kpi_goal_id`,`counter_id`),
  ADD KEY `counter_id` (`counter_id`);

--
-- Indeksy dla tabeli `sfid_locations`
--
ALTER TABLE `sfid_locations`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=198;

--
-- AUTO_INCREMENT dla tabeli `licznik_kpi_goals`
--
ALTER TABLE `licznik_kpi_goals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `licznik_counters`
--
ALTER TABLE `licznik_counters`
  ADD CONSTRAINT `licznik_counters_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `licznik_categories` (`id`),
  ADD CONSTRAINT `licznik_counters_ibfk_2` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`);

--
-- Ograniczenia dla tabeli `licznik_daily_values`
--
ALTER TABLE `licznik_daily_values`
  ADD CONSTRAINT `licznik_daily_values_ibfk_1` FOREIGN KEY (`counter_id`) REFERENCES `licznik_counters` (`id`);

--
-- Ograniczenia dla tabeli `licznik_kpi_goals`
--
ALTER TABLE `licznik_kpi_goals`
  ADD CONSTRAINT `licznik_kpi_goals_ibfk_1` FOREIGN KEY (`sfid_id`) REFERENCES `sfid_locations` (`id`);

--
-- Ograniczenia dla tabeli `licznik_kpi_linked_counters`
--
ALTER TABLE `licznik_kpi_linked_counters`
  ADD CONSTRAINT `licznik_kpi_linked_counters_ibfk_1` FOREIGN KEY (`kpi_goal_id`) REFERENCES `licznik_kpi_goals` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `licznik_kpi_linked_counters_ibfk_2` FOREIGN KEY (`counter_id`) REFERENCES `licznik_counters` (`id`) ON DELETE CASCADE;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
