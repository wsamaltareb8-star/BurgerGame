extends Control

@export var game_scene: PackedScene

@onready var main_box: Control = find_child("MainMenuBox", true, false)
@onready var play_btn: Button = find_child("PlayButton", true, false)
@onready var shop_btn: Button = find_child("ShopButton", true, false)
@onready var exit_btn: Button = find_child("ExitButton", true, false)

@onready var shop_panel: Control = find_child("ShopPanel", true, false)
@onready var shop_money_lbl: Label = find_child("ShopMoneyLabel", true, false)
@onready var grill_upgrade_btn: Button = find_child("BuyGrillSpeedBtn", true, false)
@onready var profit_upgrade_btn: Button = find_child("BuyDoubleProfitBtn", true, false)
@onready var close_shop_btn: Button = find_child("CloseShopBtn", true, false)

const SAVE_PATH = "user://burger_stand_save.cfg"
var saved_money: int = 0
var grill_level: int = 0
var profit_level: int = 0
var grill_locked: bool = false
var profit_locked: bool = false
var sales_since_refresh: int = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	if main_box:
		main_box.visible = true
	if shop_panel:
		shop_panel.visible = false
	load_game_data()
	update_shop_ui()
	if play_btn:
		play_btn.pressed.connect(_on_play_pressed)
	if shop_btn:
		shop_btn.pressed.connect(_on_open_shop)
	if exit_btn:
		exit_btn.pressed.connect(_on_exit_pressed)
	if grill_upgrade_btn:
		grill_upgrade_btn.pressed.connect(_on_buy_fast_grill)
	if profit_upgrade_btn:
		profit_upgrade_btn.pressed.connect(_on_buy_bonus_profit)
	if close_shop_btn:
		close_shop_btn.pressed.connect(_on_close_shop)

func load_game_data() -> void:
	var cfg = ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		saved_money = cfg.get_value("player", "money", 0)
		grill_level = cfg.get_value("upgrades", "grill_level", 0)
		profit_level = cfg.get_value("upgrades", "profit_level", 0)
		grill_locked = cfg.get_value("shop", "grill_locked", false)
		profit_locked = cfg.get_value("shop", "profit_locked", false)
		sales_since_refresh = cfg.get_value("shop", "sales_count", 0)

func save_game_data() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("player", "money", saved_money)
	cfg.set_value("upgrades", "grill_level", grill_level)
	cfg.set_value("upgrades", "profit_level", profit_level)
	cfg.set_value("shop", "grill_locked", grill_locked)
	cfg.set_value("shop", "profit_locked", profit_locked)
	cfg.set_value("shop", "sales_count", sales_since_refresh)
	cfg.save(SAVE_PATH)

func update_shop_ui() -> void:
	var remaining = max(0, 4 - sales_since_refresh)
	if shop_money_lbl:
		shop_money_lbl.text = "الرصيد: " + str(saved_money) + "$ | المتبقي للتحديث: " + str(remaining) + " مبيعات"
	
	var grill_cost = 50 + (grill_level * 25)
	if grill_upgrade_btn:
		if grill_locked:
			grill_upgrade_btn.text = "شواية تيربو [مستوى " + str(grill_level) + "] (بِع " + str(remaining) + " للتجديد)"
			grill_upgrade_btn.disabled = true
		else:
			grill_upgrade_btn.text = "شواية تيربو [مستوى " + str(grill_level + 1) + "] - " + str(grill_cost) + "$"
			grill_upgrade_btn.disabled = saved_money < grill_cost
			
	var profit_cost = 75 + (profit_level * 25)
	if profit_upgrade_btn:
		if profit_locked:
			profit_upgrade_btn.text = "زيادة الأرباح [مستوى " + str(profit_level) + "] (بِع " + str(remaining) + " للتجديد)"
			profit_upgrade_btn.disabled = true
		else:
			profit_upgrade_btn.text = "زيادة الأرباح [مستوى " + str(profit_level + 1) + "] (+15$) - " + str(profit_cost) + "$"
			profit_upgrade_btn.disabled = saved_money < profit_cost

func _on_open_shop() -> void:
	load_game_data()
	update_shop_ui()
	if main_box:
		main_box.visible = false
	if shop_panel:
		shop_panel.visible = true

func _on_close_shop() -> void:
	if shop_panel:
		shop_panel.visible = false
	if main_box:
		main_box.visible = true

func _on_buy_fast_grill() -> void:
	var cost = 50 + (grill_level * 25)
	if saved_money >= cost and not grill_locked:
		saved_money -= cost
		grill_level += 1
		grill_locked = true
		sales_since_refresh = 0
		save_game_data()
		update_shop_ui()

func _on_buy_bonus_profit() -> void:
	var cost = 75 + (profit_level * 25)
	if saved_money >= cost and not profit_locked:
		saved_money -= cost
		profit_level += 1
		profit_locked = true
		sales_since_refresh = 0
		save_game_data()
		update_shop_ui()

func _on_play_pressed() -> void:
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		get_tree().change_scene_to_file("res://loading_screen.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
