extends Control

const ArenaSceneScript = preload("res://scripts/arena.gd")
const Data = preload("res://scripts/game_data.gd")
const Profile = preload("res://scripts/profile.gd")

var profile
var root: Control
var current_page := "Home"
var selected_mode := "Gem Grab"
var arena: Control
var fighters_grid: GridContainer
var content: VBoxContainer
var header_coins: Label
var header_trophies: Label
var notice: Label
var current_fighter := 0
var modes := ["Gem Grab", "Showdown", "Brawl Ball", "Heist", "Knockout"]

func _ready() -> void:
	profile = Profile.new()
	_build_shell()
	_show_page("Home")

func _build_shell() -> void:
	for c in get_children(): c.queue_free()
	var bg := ColorRect.new()
	bg.color = Color("#101a2b")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var header := HBoxContainer.new()
	header.position = Vector2(18, 12)
	header.size = Vector2(924, 48)
	root.add_child(header)
	var logo := Label.new()
	logo.text = "★ FONLIS STARS"
	logo.add_theme_font_size_override("font_size", 24)
	logo.add_theme_color_override("font_color", Color("#ffe16a"))
	header.add_child(logo)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	header_coins = Label.new()
	header_trophies = Label.new()
	header.add_child(_chip_label("🪙 " + str(profile.data.coins), Color("#ffd66b")))
	header.add_child(_chip_label("🏆 " + str(profile.data.trophies), Color("#ffdc68")))
	var line := ColorRect.new()
	line.color = Color("#2b3b55")
	line.position = Vector2(18, 65)
	line.size = Vector2(924, 2)
	root.add_child(line)
	var nav := HBoxContainer.new()
	nav.position = Vector2(14, 76)
	nav.size = Vector2(932, 44)
	nav.add_theme_constant_override("separation", 5)
	root.add_child(nav)
	for p in ["Home","Brawlers","Trophy Road","Quests","Shop"]:
		var b := Button.new()
		b.text = p
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 38
		b.add_theme_font_size_override("font_size", 14)
		b.pressed.connect(func(): _show_page(p))
		_style_button(b, Color("#293e5c"))
		nav.add_child(b)
	content = VBoxContainer.new()
	content.position = Vector2(22, 132)
	content.size = Vector2(916, 385)
	content.add_theme_constant_override("separation", 12)
	root.add_child(content)
	notice = Label.new()
	notice.position = Vector2(22, 518)
	notice.size = Vector2(916, 18)
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.add_theme_font_size_override("font_size", 12)
	notice.add_theme_color_override("font_color", Color("#8ca5c7"))
	root.add_child(notice)

func _chip_label(text_value: String, color: Color) -> Label:
	var l := Label.new()
	l.text = text_value
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", 17)
	return l

func _style_button(b: Button, color: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.set_corner_radius_all(10)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 7
	normal.content_margin_bottom = 7
	b.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.15)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_color_override("font_color", Color.WHITE)

func _clear_content() -> void:
	for c in content.get_children():
		c.queue_free()

func _show_page(page: String) -> void:
	current_page = page
	_clear_content()
	notice.text = ""
	match page:
		"Home": _page_home()
		"Brawlers": _page_brawlers()
		"Trophy Road": _page_trophy()
		"Quests": _page_quests()
		"Shop": _page_shop()
		"Battle": _start_battle()

func _page_home() -> void:
	var title := _title("WELCOME BACK, STAR PLAYER")
	content.add_child(title)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(row)
	var left := PanelContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_panel(left, Color("#1d3150"))
	row.add_child(left)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 9)
	left.add_child(v)
	var f: Dictionary = Data.fighter(int(profile.data.selected))
	var hero := Label.new()
	hero.text = "YOUR FIGHTER\n" + f.name
	hero.add_theme_font_size_override("font_size", 27)
	hero.add_theme_color_override("font_color", f.color)
	v.add_child(hero)
	var desc := Label.new()
	desc.text = "HP  %d     ATTACK  %d\nSUPER  %s\n\nChoose a mode and jump into the arena." % [f.hp, f.damage, f.super]
	desc.add_theme_font_size_override("font_size", 16)
	desc.add_theme_color_override("font_color", Color("#d5e2f5"))
	v.add_child(desc)
	var change := Button.new()
	change.text = "CHOOSE FIGHTER"
	_style_button(change, Color("#385a85"))
	change.pressed.connect(func(): _show_page("Brawlers"))
	v.add_child(change)
	var right := PanelContainer.new()
	right.custom_minimum_size.x = 290
	_panel(right, Color("#263d56"))
	row.add_child(right)
	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 9)
	right.add_child(rv)
	rv.add_child(_title("BATTLE MODES"))
	for m in modes:
		var b := Button.new()
		b.text = ("✓ " if selected_mode == m else "⚔ ") + m
		b.custom_minimum_size.y = 39
		_style_button(b, Color("#315a67") if selected_mode == m else Color("#344761"))
		b.pressed.connect(func():
			selected_mode = m
			_show_page("Home")
		)
		rv.add_child(b)
	var play := Button.new()
	play.text = "▶  PLAY BATTLE"
	play.custom_minimum_size.y = 52
	play.add_theme_font_size_override("font_size", 22)
	_style_button(play, Color("#e6a832"))
	play.add_theme_color_override("font_color", Color("#30251b"))
	play.pressed.connect(func(): _show_page("Battle"))
	rv.add_child(play)

func _page_brawlers() -> void:
	content.add_child(_title("BRAWLERS  •  " + str(profile.data.unlocked.size()) + " / " + str(Data.NAMES.size())))
	var sub := Label.new()
	sub.text = "Select an unlocked fighter. New fighters cost 500 coins."
	sub.add_theme_color_override("font_color", Color("#9eb4d3"))
	content.add_child(sub)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	fighters_grid = GridContainer.new()
	fighters_grid.columns = 6
	fighters_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fighters_grid.add_theme_constant_override("h_separation", 8)
	fighters_grid.add_theme_constant_override("v_separation", 8)
	scroll.add_child(fighters_grid)
	var unlocked: Array = profile.data.get("unlocked", [0])
	for i in range(Data.NAMES.size()):
		var f: Dictionary = Data.fighter(i)
		var b := Button.new()
		b.custom_minimum_size = Vector2(135, 88)
		b.text = ("★ " if int(profile.data.selected) == i else "") + f.name + "\n" + ("UNLOCKED" if i in unlocked else "500 🪙")
		b.add_theme_font_size_override("font_size", 13)
		_style_button(b, f.color.darkened(0.55) if i in unlocked else Color("#263249"))
		b.pressed.connect(func(): _select_fighter(i))
		fighters_grid.add_child(b)

func _select_fighter(i: int) -> void:
	var owned: Array = profile.data.get("unlocked", [0])
	if i not in owned:
		if profile.unlock_fighter(i):
			notice.text = "Unlocked " + Data.fighter(i).name + "!"
		else:
			notice.text = "Not enough coins — win battles to earn more."
	else:
		profile.data.selected = i
		profile.save_data()
		notice.text = Data.fighter(i).name + " selected."
	_show_page("Brawlers")

func _page_trophy() -> void:
	content.add_child(_title("TROPHY ROAD"))
	var card := PanelContainer.new()
	_panel(card, Color("#213752"))
	content.add_child(card)
	var v := VBoxContainer.new()
	card.add_child(v)
	var t := int(profile.data.trophies)
	var l := Label.new()
	l.text = "🏆  %d TROPHIES" % t
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color("#ffdf69"))
	v.add_child(l)
	for milestone in [10,25,50,100,200,350,500,750,1000,1500,2000,3000]:
		var row := HBoxContainer.new()
		var txt := Label.new()
		txt.text = ("✓  " if t >= milestone else "🔒  ") + str(milestone) + " trophies"
		txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(txt)
		var reward := Label.new()
		reward.text = "Reward: %d coins" % (milestone / 5 + 25)
		reward.add_theme_color_override("font_color", Color("#ffd66b"))
		row.add_child(reward)
		v.add_child(row)
		var bar := ProgressBar.new()
		bar.max_value = milestone
		bar.value = min(t, milestone)
		bar.custom_minimum_size.y = 8
		v.add_child(bar)

func _page_quests() -> void:
	content.add_child(_title("DAILY QUESTS"))
	var quests := [
		["Play 1 battle", "Complete any battle", 30],
		["Deal damage", "Win a battle to claim the reward", 45],
		["Collect stars", "Earn trophies in the arena", 60]
	]
	for i in range(quests.size()):
		var card := PanelContainer.new()
		_panel(card, Color("#223752"))
		content.add_child(card)
		var row := HBoxContainer.new()
		card.add_child(row)
		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(v)
		var a := Label.new()
		a.text = quests[i][0]
		a.add_theme_font_size_override("font_size", 18)
		v.add_child(a)
		var d := Label.new()
		d.text = quests[i][1]
		d.add_theme_color_override("font_color", Color("#9db3d0"))
		v.add_child(d)
		var b := Button.new()
		b.text = "CLAIM " + str(quests[i][2])
		_style_button(b, Color("#3a866e"))
		var claimed: Array = profile.data.get("claimed", [])
		b.disabled = i in claimed
		b.pressed.connect(func():
			var arr: Array = profile.data.get("claimed", [])
			if i not in arr:
				arr.append(i)
				profile.data.claimed = arr
				profile.add_coins(int(quests[i][2]))
				notice.text = "Quest reward claimed!"
				_show_page("Quests")
		)
		row.add_child(b)

func _page_shop() -> void:
	content.add_child(_title("STAR SHOP"))
	var row := HBoxContainer.new()
	content.add_child(row)
	for item in [
		["COIN STASH", "150 coins", 100, Color("#e9b949")],
		["GEM PACK", "10 gems", 250, Color("#48d8ca")],
		["STAR BUNDLE", "500 coins", 300, Color("#b08cff")]
	]:
		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_panel(card, Color("#233650"))
		row.add_child(card)
		var v := VBoxContainer.new()
		card.add_child(v)
		var t := Label.new()
		t.text = item[0]
		t.add_theme_font_size_override("font_size", 18)
		t.add_theme_color_override("font_color", item[3])
		v.add_child(t)
		var d := Label.new()
		d.text = item[1]
		v.add_child(d)
		var b := Button.new()
		b.text = "BUY  %d coins" % item[2]
		_style_button(b, item[3].darkened(0.45))
		b.pressed.connect(func():
			if int(profile.data.coins) >= int(item[2]):
				profile.data.coins -= int(item[2])
				if item[0] == "GEM PACK": profile.data.gems = int(profile.data.gems) + 10
				else: profile.data.coins = int(profile.data.coins) + int(item[2]) * 2
				profile.save_data()
				notice.text = "Purchase complete!"
				_show_page("Shop")
			else:
				notice.text = "Not enough coins."
		)
		v.add_child(b)

func _start_battle() -> void:
	_clear_content()
	notice.text = "Fight! Defeat bots and collect gems."
	arena = ArenaSceneScript.new()
	arena.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	arena.position = Vector2.ZERO
	arena.size = Vector2(960, 540)
	arena.battle_finished.connect(_on_battle_finished)
	root.add_child(arena)
	var back := Button.new()
	back.text = "✕  QUIT"
	back.position = Vector2(800, 12)
	back.size = Vector2(135, 38)
	_style_button(back, Color("#a84052"))
	back.pressed.connect(func():
		if is_instance_valid(arena): arena.queue_free()
		_show_page("Home")
	)
	root.add_child(back)

func _on_battle_finished(won: bool, rewards: int, trophies: int) -> void:
	profile.data.battles = int(profile.data.get("battles",0)) + 1
	profile.data.coins = int(profile.data.coins) + rewards
	profile.data.trophies = maxi(0, int(profile.data.trophies) + trophies)
	if won: profile.data.wins = int(profile.data.wins) + 1
	else: profile.data.losses = int(profile.data.losses) + 1
	profile.save_data()
	if is_instance_valid(arena): arena.queue_free()
	_show_page("Home")
	notice.text = ("VICTORY!  +" if won else "DEFEAT  +") + str(rewards) + " coins, " + str(trophies) + " trophies"

func _title(text_value: String) -> Label:
	var l := Label.new()
	l.text = text_value
	l.add_theme_font_size_override("font_size", 24)
	l.add_theme_color_override("font_color", Color("#f1f6ff"))
	return l

func _panel(panel: PanelContainer, color: Color) -> void:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(14)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", s)
