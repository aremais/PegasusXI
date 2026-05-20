-- HTBF Prime reward duplicates in item_basic (29365-29380) were missing extension rows.
-- Stats copied from retail item IDs (20683, 21664, 21856, 26039, etc.). Safe to re-run.

INSERT IGNORE INTO `item_weapon` VALUES (29365,'zantetsuken',3,0,242,242,228,2,1,236,167,0);
INSERT IGNORE INTO `item_weapon` VALUES (29366,'zantetsuken_x',4,0,0,0,0,2,1,456,323,0);
INSERT IGNORE INTO `item_weapon` VALUES (29367,'geirrothr',8,0,0,0,0,1,1,492,348,0);
INSERT IGNORE INTO `item_weapon` VALUES (29368,'sacro_bulwark',8,0,0,0,0,1,1,492,348,0);
INSERT IGNORE INTO `item_weapon` VALUES (29376,'cath_palug_hammer',11,0,242,242,242,3,1,300,212,0);
INSERT IGNORE INTO `item_weapon` VALUES (29377,'cath_palug_stone',0,0,0,0,0,0,0,0,0,0);

INSERT IGNORE INTO `item_equipment` VALUES (29369,'sacro_gorget',99,0,2097216,0,0,0,512,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29370,'sacro_cord',99,0,1605660,0,0,0,1024,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29371,'sacro_mantle',99,0,397602,0,0,0,32768,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29372,'hjarrandi_helm',99,0,0,0,0,0,32,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29373,'hjarrandi_breastplate',99,119,8385,199,0,0,32,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29374,'freke_ring',99,0,1589276,0,0,0,24576,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29375,'gere_ring',99,0,2494754,0,0,0,24576,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29378,'cath_palug_crown',99,0,1589276,53,0,0,16,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29379,'cath_palug_ring',99,0,155904,0,0,0,24576,0,0,0);
INSERT IGNORE INTO `item_equipment` VALUES (29380,'cath_palug_earring',99,0,16384,0,0,0,6144,0,0,0);
