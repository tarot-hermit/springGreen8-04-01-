USE springGreen8;

CREATE TABLE users (
	user_no INT 	AUTO_INCREMENT PRIMARY KEY,
	user_id 	VARCHAR(50)  NOT NULL UNIQUE,
	user_pw 	VARCHAR(255) NOT NULL,
	user_name 	VARCHAR(50)  NOT NULL,
	user_email 	VARCHAR(100) UNIQUE,
	user_img	VARCHAR(255) DEFAULT 'default.png',
	user_bio 	VARCHAR(300) DEFAULT NULL,
	user_role 	ENUM('USER','ADMIN') DEFAULT 'USER',
	join_date 	DATETIME	DEFAULT NOW()
);

