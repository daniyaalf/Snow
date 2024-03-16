extends Panel

var time: float = 0.0
var minutes: int = 0
var seconds: int = 0
var msec: int = 0
var stats = PlayerStats
var enemyGlobalStats = EnemyGlobalStats

func _ready():
	stats.connect("no_health", stop)
	enemyGlobalStats.connect("no_enemies", stop)

func _process(delta) -> void:
	time += delta
	msec = int(fmod(time, 1) * 100)
	seconds = int(fmod(time, 60))
	minutes = int(fmod(time, 3600) / 60)
	$Minutes.text = "%02d:" % minutes
	$Seconds.text = "%02d." % seconds
	$Msecs.text = "%03d" % msec

func stop() -> void:
	set_process(false)

func get_time_formatted() -> String:
	return "02d:%02d:%03d" % [minutes, seconds, msec]
