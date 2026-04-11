-- Performance indexes for the search server auction house (GetAHItemsToCategory, history).
-- Apply to your live `xidb` (or equivalent) database. Safe to run more than once if your
-- server supports IF NOT EXISTS (MySQL 8.0.29+ / MariaDB 10.5.2+); otherwise skip errors
-- for "Duplicate key name" if indexes already exist.
--
-- 1) item_basic: every category browse uses WHERE item_basic.aH = ? — without an index on `aH`,
--    the server scans the entire item table (~tens of thousands of rows) per request.
-- 2) auction_house: the browse query joins active listings with
--    ... ON itemid = auction_house.itemid AND buyer_name IS NULL — a composite helps the join.

ALTER TABLE `item_basic` ADD INDEX `idx_item_basic_ah` (`aH`);
ALTER TABLE `auction_house` ADD INDEX `idx_auction_house_item_buyer` (`itemid`, `buyer_name`);

-- Sale history panel: WHERE itemid = ? AND stack = ? AND buyer_name IS NOT NULL ORDER BY sell_date DESC
ALTER TABLE `auction_house` ADD INDEX `idx_auction_house_item_stack_sell` (`itemid`, `stack`, `sell_date`);
