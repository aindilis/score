-- MySQL dump 9.11
--
-- Host: localhost    Database: score
-- ------------------------------------------------------
-- Server version	4.0.24_Debian-10-log

--
-- Table structure for table `agents`
--

USE score;

CREATE TABLE `annotations` (
`ID` int(11) NOT NULL auto_increment,
`Source` tinytext,
`SourceID` int(11),
`Priority` tinytext,
`DueDate` datetime,
PRIMARY KEY  (`ID`)
) TYPE=MyISAM;
