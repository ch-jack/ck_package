
CREATE TABLE `ck_items` (
	`name` varchar(50) NOT NULL,
	`label` varchar(50) NOT NULL,
	`bind` int(11) DEFAULT 0,
	`weight` smallint(4) DEFAULT 500,
	`text` TinyText DEFAULT "",

	PRIMARY KEY (`name`)
);

CREATE TABLE `ck_package` (
	`identifier` varchar(22) NOT NULL,
	`name` varchar(50) NOT NULL,
	`count` int(11) NOT NULL,
	`timelimit` int(11) NOT NULL,
	`type` varchar(10) NOT NULL,
	`extradata` longtext DEFAULT NULL,
	
	PRIMARY KEY (`identifier`, `item`, `timelimit`)
);
