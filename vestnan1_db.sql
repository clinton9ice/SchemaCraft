-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 05, 2024 at 03:11 PM
-- Server version: 10.6.20-MariaDB
-- PHP Version: 8.3.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vestnan1_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `message`
--

CREATE TABLE `message` (
  `id` int(150) NOT NULL,
  `sender` varchar(150) NOT NULL,
  `receiver` varchar(150) NOT NULL,
  `conversation` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `id` int(11) NOT NULL,
  `login_cookie` varchar(250) NOT NULL,
  `Track_ID` varchar(250) NOT NULL,
  `receiver_name` varchar(250) NOT NULL,
  `receiver_phone` varchar(250) NOT NULL,
  `start_date` varchar(250) NOT NULL,
  `end_date` varchar(250) NOT NULL,
  `origin_country` varchar(250) NOT NULL,
  `destination_country` varchar(250) NOT NULL,
  `product_photo` varchar(250) NOT NULL,
  `product_name` varchar(250) NOT NULL,
  `product_address` varchar(250) NOT NULL,
  `delivery_price` varchar(250) NOT NULL,
  `distance` varchar(250) NOT NULL DEFAULT '10',
  `route` longtext NOT NULL,
  `alert` longtext DEFAULT NULL,
  `rand` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`id`, `login_cookie`, `Track_ID`, `receiver_name`, `receiver_phone`, `start_date`, `end_date`, `origin_country`, `destination_country`, `product_photo`, `product_name`, `product_address`, `delivery_price`, `distance`, `route`) VALUES
(1, 'DXL-6706107###', 'DXL-6706107', 'john ben', '08037144569', '20-09-2024', '20-10-2024', 'Ghana', 'Nigeria', 'product.png', 'Sneakers', '12 maryland', '10000', '10', '{\"route\": [{\"location\": \"congo\", \"status\": \"loading\", \"date\": \"2024-11-04\", \"time\": \"21:06\"}]}'),
(2, 'DXL-5349001###', 'DXL-5349001', 'john ben', '08037144569', '20-09-2024', '20-10-2024', 'Ghana', 'Nigeria', 'product.png', 'Sneakers', '12 maryland', '10000', '20', '');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(150) NOT NULL,
  `username` varchar(150) NOT NULL,
  `password` varchar(150) NOT NULL,
  `loginCookie` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `loginCookie`) VALUES
(1, 'Okoezekingsley', 'Kingsley$7', 'adminxxx'),
(2, 'sinclair', 'tochukwu', 'adminxxx');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `message`
--
ALTER TABLE `message`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `message`
--
ALTER TABLE `message`
  MODIFY `id` int(150) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(150) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
