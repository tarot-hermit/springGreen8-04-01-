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

CREATE TABLE media_video_cache (
	cache_no      INT AUTO_INCREMENT PRIMARY KEY,
	tmdb_id       INT NOT NULL,
	media_type    VARCHAR(20) NOT NULL,
	season_no     INT NULL,
	source_type   VARCHAR(30) NOT NULL,
	video_key     VARCHAR(100) NOT NULL,
	video_name    VARCHAR(255),
	video_site    VARCHAR(50) DEFAULT 'YouTube',
	video_type    VARCHAR(100),
	display_order INT NOT NULL DEFAULT 1,
	reg_date      DATETIME DEFAULT NOW(),
	UNIQUE KEY uk_media_video_cache_scope (media_type, tmdb_id, season_no, video_key)
);

