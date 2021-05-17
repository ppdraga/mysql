

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
CREATE TEMPORARY TABLE tmp_10_young_users
	SELECT user_id FROM profiles p ORDER BY birthday LIMIT 10;

SELECT * FROM tmp_10_young_users ;



-- 4. Определить кто больше поставил лайков (всего) - мужчины или женщины?


DROP TEMPORARY TABLE IF EXISTS tmp_gender_likes;
CREATE TEMPORARY TABLE tmp_gender_likes
SELECT 
	IF(user_id IN (SELECT user_id FROM profiles p WHERE gender = "M"), "M", "F") AS gender
FROM likes l ;

SELECT gender, COUNT(gender) FROM tmp_gender_likes GROUP BY gender ORDER BY COUNT(gender) DESC LIMIT 1;



-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.



