SELECT * FROM yelp_user WHERE user_id = ?
SELECT name, review_count, average_stars, yelping_since FROM yelp_user WHERE user_id = ?
SELECT r.review_id, r.stars, r.date FROM yelp_review r WHERE r.user_id = ?
SELECT r.review_id, r.stars, b.name AS business, b.city FROM yelp_review r JOIN yelp_business b ON r.business_id = b.business_id WHERE r.user_id = ?
SELECT AVG(r.stars) AS avg_stars, COUNT(r.review_id) AS num_reviews FROM yelp_review r WHERE r.user_id = ?
SELECT r.stars, b.name AS business, b.city, b.stars AS business_stars FROM yelp_review r JOIN yelp_business b ON r.business_id = b.business_id WHERE r.user_id = ? ORDER BY r.stars DESC LIMIT 10
