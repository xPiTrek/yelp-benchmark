SELECT * FROM yelp_business WHERE business_id = ?
SELECT name, city, state, stars, review_count FROM yelp_business WHERE business_id = ?
SELECT r.review_id, r.stars, r.date, r.useful FROM yelp_review r WHERE r.business_id = ?
SELECT r.review_id, r.stars, u.name AS reviewer, u.review_count FROM yelp_review r JOIN yelp_user u ON r.user_id = u.user_id WHERE r.business_id = ?
SELECT AVG(r.stars) AS avg_stars, COUNT(r.review_id) AS num_reviews, SUM(r.useful) AS total_useful FROM yelp_review r WHERE r.business_id = ?
