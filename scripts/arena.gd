extends Control
signal battle_finished(won: bool, rewards: int, trophies: int)

var running := false
var mode_name := "Gem Grab"
var player_pos := Vector2(480, 275)
var player_hp := 3000.0
var player_max_hp := 3000.0
var enemies: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
var obstacles: Array[Rect2] = []
var move_vector := Vector2.ZERO
var attack_cooldown := 0.0
var super_charge := 0.0
var elapsed := 0.0
var gems := 0
var goal := 10
var result_sent := false
var touch_origin := Vector2.ZERO
var touch_id := -1
var attack_pressed := false
var super_pressed := false
var hud_font: Font

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	hud_font = ThemeDB.fallback_font
	start_battle("Gem Grab")

func start_battle(mode: String) -> void:
	mode_name = mode
	running = true
	result_sent = false
	player_pos = Vector2(size.x * 0.5, size.y * 0.58)
	player_hp = 3000
	super_charge = 0
	elapsed = 0
	gems = 0
	goal = 10 if mode == "Gem Grab" else 1
	bullets.clear()
	enemies.clear()
	obstacles = [
		Rect2(150, 130, 120, 34), Rect2(690, 130, 120, 34),
		Rect2(280, 230, 50, 90), Rect2(630, 230, 50, 90),
		Rect2(400, 100, 160, 28), Rect2(400, 390, 160, 28)
	]
	for i in range(5):
		enemies.append({
			"pos": Vector2(randf_range(90, size.x - 90), randf_range(70, size.y * 0.42)),
			"hp": 1900.0, "max_hp": 1900.0, "cooldown": randf_range(0.3, 1.8),
			"color": [Color("#ff5d6c"), Color("#ffb347"), Color("#a78bfa"), Color("#45d6c4"), Color("#f472b6")][i],
			"dir": Vector2.ZERO
		})
	queue_redraw()

func _process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	var keyboard := Vector2(
		float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left")),
		float(Input.is_action_pressed("move_down")) - float(Input.is_action_pressed("move_up"))
	)
	var movement := move_vector
	if keyboard.length() > 0.1:
		movement = keyboard.normalized()
	player_pos += movement * 205.0 * delta
	player_pos.x = clampf(player_pos.x, 32, size.x - 32)
	player_pos.y = clampf(player_pos.y, 70, size.y - 32)
	for e in enemies:
		var to_player: Vector2 = player_pos - e.pos
		if to_player.length() > 130:
			e.pos += to_player.normalized() * 65.0 * delta
		else:
			e.pos += Vector2(randf_range(-1,1), randf_range(-1,1)) * 28 * delta
		e.cooldown -= delta
		if e.cooldown <= 0:
			e.cooldown = randf_range(1.1, 2.1)
			bullets.append({"pos": e.pos, "vel": to_player.normalized() * 185.0, "team": 1, "damage": 230.0, "life": 2.5})
	if attack_pressed or Input.is_action_pressed("attack"):
		_fire_player()
	if super_pressed or Input.is_action_just_pressed("super"):
		_use_super()
	super_pressed = false
	for b in bullets:
		b.pos += b.vel * delta
		b.life -= delta
		if b.team == 1 and b.pos.distance_to(player_pos) < 25:
			player_hp -= b.damage
			b.life = 0
		elif b.team == 0:
			for e in enemies:
				if b.pos.distance_to(e.pos) < 26 and e.hp > 0:
					e.hp -= b.damage
					b.life = 0
					super_charge = minf(100, super_charge + 14)
					if e.hp <= 0:
						gems += 1
						profile_reward_placeholder()
					break
	bullets = bullets.filter(func(b): return b.life > 0 and b.pos.x > 0 and b.pos.x < size.x and b.pos.y > 0 and b.pos.y < size.y)
	enemies = enemies.filter(func(e): return e.hp > 0)
	if player_hp <= 0:
		_finish(false)
	elif enemies.is_empty():
		_finish(true)
	elif mode_name == "Gem Grab" and gems >= goal:
		_finish(true)
	elif elapsed > 95:
		_finish(gems >= 5)
	queue_redraw()

func profile_reward_placeholder() -> void:
	pass

func _fire_player() -> void:
	if attack_cooldown > 0:
		return
	attack_cooldown = 0.28
	var target: Dictionary = {}
	var nearest := INF
	for e in enemies:
		var d: float = player_pos.distance_to(e.pos)
		if d < nearest:
			nearest = d
			target = e
	var dir := Vector2.UP
	if not target.is_empty():
		dir = (target.pos - player_pos).normalized()
	bullets.append({"pos": player_pos + dir * 25, "vel": dir * 440.0, "team": 0, "damage": 560.0, "life": 1.1})

func _use_super() -> void:
	if super_charge < 100:
		return
	super_charge = 0
	for e in enemies:
		if e.pos.distance_to(player_pos) < 210:
			e.hp -= 1250
	bullets = bullets.filter(func(b): return b.team != 1 or b.pos.distance_to(player_pos) > 170)

func _finish(won: bool) -> void:
	if result_sent:
		return
	result_sent = true
	running = false
	battle_finished.emit(won, 35 if won else 12, 8 if won else -2)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x > size.x * 0.68 and event.position.y > size.y * 0.55:
				if event.position.y > size.y * 0.78:
					super_pressed = true
				else:
					attack_pressed = true
			else:
				touch_id = event.index
				touch_origin = event.position
				move_vector = Vector2.ZERO
		else:
			attack_pressed = false
			move_vector = Vector2.ZERO
			touch_id = -1
	elif event is InputEventScreenDrag and event.index == touch_id:
		move_vector = (event.position - touch_origin).limit_length(65) / 65.0
	elif event is InputEventMouseButton:
		if event.pressed:
			if event.position.x > size.x * 0.68:
				if event.position.y > size.y * 0.78: super_pressed = true
				else: attack_pressed = true
			else:
				touch_origin = event.position
				move_vector = Vector2.ZERO
		else:
			attack_pressed = false
			move_vector = Vector2.ZERO
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if event.position.x < size.x * 0.65:
			move_vector = (event.position - touch_origin).limit_length(65) / 65.0

func _draw() -> void:
	var w := size.x
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color("#183b42"))
	# Arena floor tiles
	for x in range(0, int(w), 48):
		for y in range(0, int(h), 48):
			draw_rect(Rect2(x, y, 46, 46), Color("#204c4c") if ((x/48 + y/48) % 2 == 0) else Color("#1d4547"))
	for r in obstacles:
		draw_rect(r, Color("#547c67"), true, 7)
		draw_rect(r.grow(-5), Color("#365e50"), true, 5)
		draw_line(r.position + Vector2(8,8), r.position + Vector2(r.size.x-8,r.size.y-8), Color("#72967a"), 3)
	for i in range(4):
		var gem_pos := Vector2(w * (0.25 + i*0.16), h*0.49)
		draw_colored_polygon(PackedVector2Array([gem_pos+Vector2(0,-8),gem_pos+Vector2(7,0),gem_pos+Vector2(0,8),gem_pos+Vector2(-7,0)]), Color("#62f2e2"))
	for b in bullets:
		draw_circle(b.pos, 7 if b.team == 0 else 6, Color("#ffe66d") if b.team == 0 else Color("#ff647c"))
	for e in enemies:
		draw_circle(e.pos + Vector2(0,4), 23, Color(0,0,0,0.25))
		draw_circle(e.pos, 20, e.color)
		draw_circle(e.pos + Vector2(-6,-5), 5, Color.WHITE)
		draw_circle(e.pos + Vector2(6,-5), 5, Color.WHITE)
		draw_rect(Rect2(e.pos + Vector2(-22,-31), Vector2(44,5)), Color("#562e3b"))
		draw_rect(Rect2(e.pos + Vector2(-22,-31), Vector2(44 * e.hp/e.max_hp,5)), Color("#66e58c"))
	draw_circle(player_pos + Vector2(0,5), 25, Color(0,0,0,0.28))
	draw_circle(player_pos, 22, Color("#4da8ff"))
	draw_circle(player_pos + Vector2(-7,-6), 6, Color.WHITE)
	draw_circle(player_pos + Vector2(7,-6), 6, Color.WHITE)
	draw_rect(Rect2(player_pos + Vector2(-27,-34), Vector2(54,6)), Color("#542c39"))
	draw_rect(Rect2(player_pos + Vector2(-27,-34), Vector2(54 * player_hp/player_max_hp,6)), Color("#6df09a"))
	# HUD
	draw_rect(Rect2(14, 12, 235, 58), Color("#102a35",0.9), true, 12)
	draw_string(hud_font, Vector2(27,35), mode_name.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color.WHITE)
	draw_string(hud_font, Vector2(27,56), "GEMS  %02d / %02d     TIME %02d" % [gems, goal, int(maxf(0,95-elapsed))], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#8ff9ed"))
	# joystick and action buttons
	draw_circle(Vector2(90,h-86), 54, Color(0.05,0.12,0.2,0.65))
	draw_circle(Vector2(90,h-86) + move_vector*35, 24, Color("#8bd5ff",0.8))
	draw_circle(Vector2(w-105,h-90), 42, Color("#f5a623",0.9))
	draw_circle(Vector2(w-105,h-90), 32, Color("#ffcf62"))
	draw_string(hud_font, Vector2(w-140,h-83), "ATTACK", HORIZONTAL_ALIGNMENT_CENTER, 70, 13, Color("#402b18"))
	draw_circle(Vector2(w-75,h-183), 30, Color("#9a76ff",0.95))
	draw_string(hud_font, Vector2(w-104,h-178), "SUPER", HORIZONTAL_ALIGNMENT_CENTER, 58, 12, Color.WHITE)
	draw_rect(Rect2(w-145,h-226,110,8), Color("#30264b"), true, 4)
	draw_rect(Rect2(w-145,h-226,110*super_charge/100,8), Color("#c7a8ff"), true, 4)

var profile_reward_placeholder_value := 0
