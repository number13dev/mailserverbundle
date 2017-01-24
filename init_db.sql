CREATE DATABASE IF NOT EXISTS spamassassin;
CREATE USER IF NOT EXISTS spamassassin@% IDENTIFIED BY '{{SQL_USR_PW}}';
GRANT ALL PRIVILEGES ON spamassassin.* TO spamassassin;
FLUSH PRIVILEGES;

USE vmail;
CREATE TABLE IF NOT EXISTS `x_tlspolicy` (
    `id` int unsigned NOT NULL AUTO_INCREMENT,
    `domain` varchar(255) NOT NULL,
    `policy` enum('none', 'may', 'encrypt', 'dane', 'dane-only', 'fingerprint', 'verify', 'secure') NOT NULL,
    `params` varchar(255),
    PRIMARY KEY (`id`),
    UNIQUE KEY (`domain`)
    ) CHARSET=latin1;
