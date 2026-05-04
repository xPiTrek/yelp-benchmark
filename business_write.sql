SELECT * FROM yelp_business WHERE business_id = ?
SELECT r.review_id, r.stars FROM yelp_review r WHERE r.business_id = ?
UPDATE yelp_business SET stars = 4.0 WHERE business_id = ?
UPDATE yelp_business SET review_count = review_count + 1 WHERE business_id = ?
DELETE FROM yelp_review WHERE business_id = ? AND review_id LIKE 'bench_%'
