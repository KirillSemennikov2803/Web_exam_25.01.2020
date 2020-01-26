-- phpMyAdmin SQL Dump
-- version 4.9.4
-- https://www.phpmyadmin.net/
--
-- Хост: std-mysql
-- Время создания: Янв 25 2020 г., 11:57
-- Версия сервера: 5.7.26-0ubuntu0.16.04.1
-- Версия PHP: 7.4.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `std_848`
--
CREATE DATABASE IF NOT EXISTS `std_848` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `std_848`;

-- --------------------------------------------------------

--
-- Структура таблицы `request`
--

CREATE TABLE `request` (
  `id` int(32) NOT NULL,
  `date` date NOT NULL,
  `user_id` int(32) NOT NULL,
  `type_id` int(32) NOT NULL,
  `status_id` int(32) NOT NULL,
  `message` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `request`
--

INSERT INTO `request` (`id`, `date`, `user_id`, `type_id`, `status_id`, `message`) VALUES
(8, '0312-02-13', 1, 1, 1, '123312312312312'),
(9, '0032-02-13', 1, 1, 1, '2131231'),
(10, '0312-02-22', 1, 1, 2, '132321'),
(11, '2222-02-12', 1, 1, 2, '13312'),
(12, '0011-11-11', 1, 1, 1, '123'),
(14, '3222-02-02', 3, 1, 1, 'Привет');

-- --------------------------------------------------------

--
-- Структура таблицы `role_users`
--

CREATE TABLE `role_users` (
  `id` int(32) NOT NULL,
  `role` varchar(32) NOT NULL,
  `discription` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `role_users`
--

INSERT INTO `role_users` (`id`, `role`, `discription`) VALUES
(1, 'администратор', 'суперпользователь, имеет полный доступ к системе, в том числе к удалению обращений'),
(2, 'специалист технической поддержки', 'может производить манипуляции с состоянием обращений — изменением статуса'),
(3, 'пользователь', 'может оставлять обращения');

-- --------------------------------------------------------

--
-- Структура таблицы `status_request`
--

CREATE TABLE `status_request` (
  `id` int(32) NOT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `status_request`
--

INSERT INTO `status_request` (`id`, `status`) VALUES
(1, 'В работе'),
(2, 'Забили');

-- --------------------------------------------------------

--
-- Структура таблицы `type_request`
--

CREATE TABLE `type_request` (
  `id` int(32) NOT NULL,
  `type` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `type_request`
--

INSERT INTO `type_request` (`id`, `type`) VALUES
(1, 'Обращение'),
(2, 'Кляуза');

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `id` int(32) NOT NULL,
  `login` varchar(32) NOT NULL,
  `full_name` varchar(32) NOT NULL,
  `role_id` int(32) NOT NULL,
  `password` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `login`, `full_name`, `role_id`, `password`) VALUES
(1, 'admin', 'Семен Кириллов,он же Кирилл', 1, '21232f297a57a5a743894a0e4a801fc3'),
(2, 'tech', 'Семен Кириллов', 2, '21232f297a57a5a743894a0e4a801fc3'),
(3, 'user', 'Пользователь', 3, '21232f297a57a5a743894a0e4a801fc3');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `request`
--
ALTER TABLE `request`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `type_id` (`type_id`),
  ADD KEY `status_id` (`status_id`),
  ADD KEY `date` (`date`);

--
-- Индексы таблицы `role_users`
--
ALTER TABLE `role_users`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `status_request`
--
ALTER TABLE `status_request`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `type_request`
--
ALTER TABLE `type_request`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `role_id` (`role_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `request`
--
ALTER TABLE `request`
  MODIFY `id` int(32) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `request`
--
ALTER TABLE `request`
  ADD CONSTRAINT `request_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `request_ibfk_2` FOREIGN KEY (`status_id`) REFERENCES `status_request` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `request_ibfk_3` FOREIGN KEY (`type_id`) REFERENCES `type_request` (`id`) ON DELETE CASCADE;

--
-- Ограничения внешнего ключа таблицы `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `role_users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
