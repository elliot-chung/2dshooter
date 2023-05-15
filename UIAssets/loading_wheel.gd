extends TextureProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween().set_loops()
	tween.tween_property(self, "radial_initial_angle", 360.0, 1.5).as_relative()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
