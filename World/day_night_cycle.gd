extends CanvasModulate

const NIGHT_COLOR = Color("#282173")
const DAY_COLOR = Color("#ffffff")
const TIME_SCALE = 0.01

var time = randf_range(0, 6)

func _process(delta):
	self.time += delta * TIME_SCALE
	# lerp = linear interpolate
	self.color = NIGHT_COLOR.lerp(DAY_COLOR, abs(sin(time)))
