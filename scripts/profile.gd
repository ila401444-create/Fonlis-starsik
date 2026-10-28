extends RefCounted
class_name PlayerProfile

const SAVE_PATH := "user://fonlis_profile.json"
var data: Dictionary = {}

func _init() -> void:
	load_data()

func load_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var parsed = JSON.parse_string(f.get_as_text()) if f else null
		if parsed is Dictionary:
			data = parsed
	if data.is_empty():
		data = {
			"coins": 850, "gems": 35, "trophies": 0, "wins": 0, "losses": 0,
			"selected": 0, "unlocked": [0, 1, 2], "quests": [0, 0, 0],
			"claimed": [], "battles": 0
		}
		save_data()

func save_data() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))

func add_coins(amount: int) -> void:
	data.coins = int(data.get("coins", 0)) + amount
	save_data()

func unlock_fighter(id: int) -> bool:
	var owned: Array = data.get("unlocked", [0])
	if id in owned or int(data.get("coins", 0)) < 500:
		return false
	data.coins -= 500
	owned.append(id)
	data.unlocked = owned
	save_data()
	return true
