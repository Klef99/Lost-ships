extends Control


@onready var player = null
@onready var levelPanel = $CanvasLayer/LevelUp
@onready var upgradeOptions = $CanvasLayer/LevelUp/UpgradeOptions
@onready var sndLevelUp = $CanvasLayer/LevelUp/snd_levelup
@onready var hpbar = $CanvasLayer/HPbar
@onready var expBar = $CanvasLayer/EXPbar
@onready var lblLevel = $CanvasLayer/EXPbar/lbl_level
@onready var lblTimer = $CanvasLayer/lbl_timer
@onready var collectedWeapons = $CanvasLayer/CollectedWeapons
@onready var collectedUpgrades = $CanvasLayer/CollectedUpgrades

@onready var itemOptions = preload("res://elements/UI/ItemOption/item_option.tscn")
@onready var itemContainer = preload("res://elements/UI/ItemContainer/item_container.tscn")

func update_hpbar(cur, max):
	hpbar.max_value = max
	hpbar.value = cur

func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in player.collected_upgrades: #Find already collected upgrades
			pass
		elif i in player.upgrade_options: #If the upgrade is already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #Don't pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: #Check for PreRequisites
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in player.collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		player.upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func levelup():
	Hud.sndLevelUp.play()
	lblLevel.text = str("Level: ",player.experience_level)
	var tween = Hud.levelPanel.create_tween()
	tween.tween_property(Hud.levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true
	
	
func adjust_gui_collection(upgrade):
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in player.collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)

