extends Control

@onready var heartUIFull = $HeartUIFull
@onready var heartUIEmpty = $HeartUIEmpty

var hearts = 4 : set = set_hearts
var max_hearts = 4 : set = set_max_hearts

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		# heart is 15 pixels including a space
		heartUIFull.set_size(Vector2(hearts * 15, 11))

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.set_size(Vector2(max_hearts * 15, 11))

func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", set_hearts)
	PlayerStats.connect("max_health_changed", set_max_hearts)
