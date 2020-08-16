CREATE TABLE `predicates` (
  `ID` int(11) NOT NULL auto_increment,
  `Predicate` tinytext,
  `Arg1` tinytext,
  `Arg2` tinytext,
  PRIMARY KEY  (`ID`)
) TYPE=MyISAM;
