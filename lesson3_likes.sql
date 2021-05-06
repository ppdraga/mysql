-- Таблица постов
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор поста", 
  user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на автора поста",
  body TEXT NOT NULL COMMENT "Текст поста",
  created_at DATETIME DEFAULT NOW() COMMENT "Время создания поста",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления поста",
  FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT "Посты";

-- Таблица медиа к посту
CREATE TABLE posts_media (
  post_id INT UNSIGNED NOT NULL COMMENT "Ссылка на пост", 
  media_id INT UNSIGNED NOT NULL COMMENT "Ссылка на медиа файл",
  created_at DATETIME DEFAULT NOW() COMMENT "Время добавления медиа контента к посту",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления медиа контента к посту",
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (media_id) REFERENCES media(id)
) COMMENT "Медиа к постам";

-- Таблица лайков к постам
CREATE TABLE post_likes (
  post_id INT UNSIGNED NOT NULL COMMENT "Ссылка на пост",
  user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на автора лайка",
  created_at DATETIME DEFAULT NOW() COMMENT "Время добавления лайка к посту",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления лайка к посту",
  FOREIGN KEY (post_id) REFERENCES posts(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT "Лайки к постам";

-- Таблица лайков к медиа
CREATE TABLE media_likes (
  media_id INT UNSIGNED NOT NULL COMMENT "Ссылка на медиа файл",
  user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на автора лайка",
  created_at DATETIME DEFAULT NOW() COMMENT "Время добавления лайка для медиа",
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления лайка для медиа",
  FOREIGN KEY (media_id) REFERENCES media(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
) COMMENT "Лайки к медиа";

