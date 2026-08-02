-- Performance indexes for the search server auction house (GetAHItemsToCategory, history, AH expiry).
-- Apply to your live `xidb` (or equivalent) database. Safe to re-run: CREATE INDEX IF NOT EXISTS
-- (MySQL 8.0.29+ / MariaDB 10.5.2+; matches docker `mariadb:lts` in this repo).
--
-- 1) item_basic: every category browse uses WHERE item_basic.aH = ? — without an index on `aH`,
--    the server scans the entire item table (~tens of thousands of rows) per request.
-- 2) auction_house: the browse query joins active listings with
--    ... ON itemid = auction_house.itemid AND buyer_name IS NULL — a composite helps the join.
-- 3) auction_house: ExpireAHItems uses buyer_name IS NULL and a range on `date`.

CREATE INDEX IF NOT EXISTS `idx_item_basic_ah` ON `item_basic` (`aH`);
CREATE INDEX IF NOT EXISTS `idx_auction_house_item_buyer` ON `auction_house` (`itemid`, `buyer_name`);

-- Sale history panel: WHERE itemid = ? AND stack = ? AND buyer_name IS NOT NULL ORDER BY sell_date DESC
CREATE INDEX IF NOT EXISTS `idx_auction_house_item_stack_sell` ON `auction_house` (`itemid`, `stack`, `sell_date`);

CREATE INDEX IF NOT EXISTS `idx_auction_house_buyer_date` ON `auction_house` (`buyer_name`, `date`);
