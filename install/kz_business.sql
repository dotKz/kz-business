-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : Dim 07 août 2022 à 14:33
-- Version du serveur :  5.7.31
-- Version de PHP : 7.3.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------

--
-- Structure de la table `kz_business`
--

DROP TABLE IF EXISTS `kz_business`;
CREATE TABLE IF NOT EXISTS `kz_business` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `business` varchar(50) NOT NULL,
  `businessdata` text,
  `type` varchar(50) CHARACTER SET utf8mb4 DEFAULT 'Aucun',
  `item_harvest` varchar(50) DEFAULT NULL,
  `item_process` varchar(50) DEFAULT NULL,
  `blips` varchar(50) DEFAULT NULL,
  `qg` text,
  `harvest` text CHARACTER SET utf8mb4,
  `processing` text CHARACTER SET utf32,
  `sale` text CHARACTER SET utf32,
  PRIMARY KEY (`id`),
  UNIQUE KEY `business` (`business`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
