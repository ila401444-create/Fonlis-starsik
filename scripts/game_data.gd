extends RefCounted
class_name GameData

const NAMES := [
"Astra","Bront","Cinder","Dynamo","Echo","Fable","Glint","Havoc","Iris","Jolt",
"Kairo","Lumen","Mako","Nova","Onyx","Pixel","Quill","Rivet","Sable","Tango",
"Umbra","Vex","Warden","Xeno","Yara","Zephyr","Bolt","Cricket","Drift","Ember",
"Flint","Gizmo","Hex","Indigo","Jinx","Koda","Lark","Mistral","Nix","Orbit",
"Prism","Rook","Sonic","Thorn","Volt","Wisp","Axel","Blaze","Comet","Dusk",
"Frost","Gale","Hush","Ion","Jade","Knox","Lynx","Moss","Nyx","Opal",
"Piper","Quest","Razor","Storm","Talon","Violet","Whirl","Yuki","Zed","Archer",
"Bandit","Cipher","Dash","Electra","Flick","Grav","Halo","Inferno","Jett","Karma",
"Locke","Mirage","Nero","Omega","Phantom","Rumble","Shade","Torque","Vector","Wolf",
"Yonder","Zero","Bishop","Crash","Dagger","Flare","Glacier","Hopper","Kestrel","Marble",
"Ranger","Sparks","Titan","Vandal","Whisper","Zodiac"
]

static func fighter(index: int) -> Dictionary:
	var i := posmod(index, NAMES.size())
	var colors := [
		Color("#ff5964"), Color("#ffb347"), Color("#f5df4d"), Color("#7bd66f"),
		Color("#40d9c5"), Color("#48a9ff"), Color("#8b83ff"), Color("#d77bff"),
		Color("#ff82b2"), Color("#e9f0ff")
	]
	return {
		"id": i, "name": NAMES[i], "rarity": ["COMMON","RARE","SUPER RARE","EPIC","MYTHIC","LEGENDARY"][i % 6],
		"hp": 3000 + (i % 5) * 350, "damage": 420 + (i % 4) * 70,
		"speed": 150.0 + float(i % 4) * 10.0, "color": colors[i % colors.size()],
		"attack": ["Pulse Shot","Triple Burst","Arc Bolt","Heavy Slam"][i % 4],
		"super": ["Nova Wave","Overdrive","Starfall","Shock Ring"][i % 4]
	}
