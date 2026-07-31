SELECT trigger_name FROM information_schema.triggers
WHERE trigger_schema = DATABASE()
  AND trigger_name IN (
    'account_delete','session_delete','auction_house_list','auction_house_buy',
    'char_insert','char_delete','delivery_box_insert',
    'ensure_synth_ingredients_are_ordered','ensure_synergy_ingredients_are_ordered'
)
ORDER BY trigger_name;
