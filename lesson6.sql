

-- 1. Проанализировать запросы, которые выполнялись на занятии, определить возможные корректировки и/или улучшения (JOIN пока не применять).



-- 2. Пусть задан некоторый пользователь. 
--    Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.


-- user_id = 78
SELECT 
	from_user_id
FROM 
	messages 
WHERE 
	from_user_id IN (SELECT friend_id FROM friendships f WHERE user_id = 78 and status_id = 2)
GROUP BY 
	from_user_id
ORDER BY 
	COUNT(*) DESC
LIMIT 1;


-- 3. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.


DROP TEMPORARY TABLE IF EXISTS tmp_10_young_users;
CREATE TABLE tmp_10_young_users
	SELECT user_id FROM profiles p ORDER BY birthday LIMIT 10;

DROP TEMPORARY TABLE IF EXISTS tmp_targets;
CREATE TEMPORARY TABLE tmp_targets
	-- messages target-type 1
	SELECT id AS 'target_id', 1 AS 'target_type_id' FROM messages WHERE from_user_id IN (SELECT user_id FROM tmp_10_young_users) 
	UNION
	-- users target-type 2
	SELECT id, 2 FROM media WHERE id IN (SELECT user_id FROM tmp_10_young_users) 
	UNION
	-- media target-type 3
	SELECT id, 3 FROM media WHERE user_id IN (SELECT user_id FROM tmp_10_young_users) 
	UNION
	-- posts target-type 4
	SELECT id, 4 FROM posts WHERE user_id IN (SELECT user_id FROM tmp_10_young_users) ;
DROP TABLE IF EXISTS tmp_10_young_users;

SELECT COUNT(*) FROM likes WHERE (target_id, target_type_id) IN (SELECT target_id, target_type_id FROM tmp_targets)  ;



-- 4. Определить кто больше поставил лайков (всего) - мужчины или женщины?


DROP TEMPORARY TABLE IF EXISTS tmp_gender_likes;
CREATE TEMPORARY TABLE tmp_gender_likes
SELECT 
	IF(user_id IN (SELECT user_id FROM profiles p WHERE gender = "M"), "M", "F") AS gender
FROM likes l ;

SELECT gender, COUNT(gender) FROM tmp_gender_likes GROUP BY gender ORDER BY COUNT(gender) DESC LIMIT 1;



-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

CREATE TEMPORARY TABLE tmp_user_activity
	SELECT from_user_id AS user_id, COUNT(from_user_id) AS total FROM messages m GROUP BY from_user_id
	UNION
	SELECT user_id, COUNT(user_id) FROM likes GROUP BY user_id 
	UNION
	SELECT user_id, COUNT(user_id) FROM posts GROUP BY user_id 
	UNION
	SELECT user_id, COUNT(user_id) FROM media GROUP BY user_id;

SELECT user_id FROM tmp_user_activity GROUP BY user_id ORDER BY COUNT(total) LIMIT 10;

