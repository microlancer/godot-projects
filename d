[1mdiff --git a/kanji-game/scenes/battle.tscn b/kanji-game/scenes/battle.tscn[m
[1mindex f93df71..1d5d50c 100644[m
[1m--- a/kanji-game/scenes/battle.tscn[m
[1m+++ b/kanji-game/scenes/battle.tscn[m
[36m@@ -1,4 +1,4 @@[m
[31m-[gd_scene load_steps=458 format=3 uid="uid://p1onvqcjv8ce"][m
[32m+[m[32m[gd_scene load_steps=457 format=3 uid="uid://p1onvqcjv8ce"][m
 [m
 [ext_resource type="Script" path="res://scripts/battle.gd" id="1_vyelx"][m
 [ext_resource type="PackedScene" uid="uid://bmrjl77m8kh4x" path="res://scenes/world.tscn" id="2_f0y0t"][m
[36m@@ -25,10 +25,6 @@[m [mline_spacing = -10.0[m
 [sub_resource type="LabelSettings" id="LabelSettings_423xv"][m
 font_color = Color(0.356863, 0.356863, 0.356863, 0.243137)[m
 [m
[31m-[sub_resource type="LabelSettings" id="LabelSettings_cyab5"][m
[31m-line_spacing = 0.0[m
[31m-font_size = 5[m
[31m-[m
 [sub_resource type="AtlasTexture" id="AtlasTexture_eqlou"][m
 atlas = ExtResource("79_pgljm")[m
 region = Rect2(64, 672, 32, 32)[m
[36m@@ -3287,9 +3283,6 @@[m [moffset_bottom = 40.0[m
 [m
 [node name="PlayerLevel" type="Label" parent="UI2"][m
 layout_mode = 0[m
[31m-[m
[31m-[node name="PlayerStats" type="Label" parent="UI2"][m
[31m-layout_mode = 0[m
 offset_left = 59.0[m
 offset_top = 1.0[m
 offset_right = 215.0[m
[36m@@ -3301,15 +3294,6 @@[m [mtheme_override_constants/outline_size = 5[m
 theme_override_font_sizes/font_size = 46[m
 text = "level: 1"[m
 [m
[31m-[node name="EnemyStats" type="Label" parent="UI2"][m
[31m-layout_mode = 0[m
[31m-offset_left = 49.0[m
[31m-offset_top = 50.0[m
[31m-offset_right = 146.0[m
[31m-offset_bottom = 97.0[m
[31m-label_settings = SubResource("LabelSettings_cyab5")[m
[31m-horizontal_alignment = 2[m
[31m-[m
 [node name="EnemyLevel" type="Label" parent="UI2"][m
 layout_mode = 0[m
 offset_left = 82.0[m
[1mdiff --git a/kanji-game/scripts/battle.gd b/kanji-game/scripts/battle.gd[m
[1mindex b4f022c..e0748fd 100644[m
[1m--- a/kanji-game/scripts/battle.gd[m
[1m+++ b/kanji-game/scripts/battle.gd[m
[36m@@ -502,6 +502,7 @@[m [mfunc _animation_finished():[m
 		$AudioStreamPlayer2D.play()[m
 		player_hp = player_hp_max[m
 		Health_bar_player.hide()[m
[32m+[m		[32m$UI2/PlayerLevel.hide()[m
 		$UI2/NextBattleButton.text = "Try again"[m
 		$UI2/NextBattleButton.show()[m
 		$UI/KanjiDrawPanel.hide()[m
[36m@@ -544,8 +545,10 @@[m [mfunc _animation_finished_enemy():[m
 		$AudioStreamPlayer2D2.volume_db = -15.0[m
 		$AudioStreamPlayer2D2.play()[m
 		Health_bar_enemy.hide()[m
[32m+[m		[32m$UI2/EnemyLevel.hide()[m
 		animated_enemy.hide()[m
 		Health_bar_player.hide()[m
[32m+[m		[32m$UI2/PlayerLevel.hide()[m
 		$UI2/NextBattleButton.text = "次 (つぎ)"[m
 		$UI2/NextBattleButton.show()[m
 		$UI/KanjiDrawPanel.hide()[m
[36m@@ -631,7 +634,8 @@[m [mfunc get_gold():[m
 	var gold_amount = randi_range(1, enemy_level)[m
 	[m
 	$Prize/TextureRectCoin/GoldAmount.text = str(gold_amount)[m
[31m-	[m
[32m+[m	[32m$Prize/PlayerGold_Graphic/PlayerGold.text = str(player_gold)[m
[32m+[m	[32m$Prize/PlayerEXP_Graphic/Playerexperience.text = str(player_kp)[m
 	player_gold += gold_amount[m
 	[m
 	update_hp()[m
[36m@@ -1000,7 +1004,7 @@[m [mfunc update_hp():[m
 	if enemy_hp > 0:[m
 		pass[m
 	else:[m
[31m-		$UI2/EnemyStats.text = ""[m
[32m+[m		[32mpass[m
 		[m
 	print({[m
 		"player_hp":player_hp,[m
[36m@@ -1069,6 +1073,7 @@[m [mfunc _encounter_enemy():[m
 	[m
 	$AudioStreamPlayer2D.stop()[m
 	Health_bar_enemy.show()[m
[32m+[m	[32m$UI2/EnemyLevel.show()[m
 	[m
 	print("_encounter_enemy")[m
 	[m
[36m@@ -1117,7 +1122,9 @@[m [mfunc start_battle():[m
 	animated_enemy.play()[m
 	[m
 	Health_bar_player.show()[m
[32m+[m	[32m$UI2/PlayerLevel.show()[m
 	Health_bar_enemy.show()[m
[32m+[m	[32m$UI2/EnemyLevel.show()[m
 [m
 	Globals.AudioStreamPlayerBgMusic.stream = Globals.music_action1[m
 	Globals.AudioStreamPlayerBgMusic.play()[m
