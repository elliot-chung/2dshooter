extends PopupPanel

@export (NodePath) var MenuButtonPath := NodePath()

var MenuButton: TextureButton

func _handle_button(toggle: bool):
	print(toggle)
	if toggle:
		popup_centered()
	else:
		set_visible(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	MenuButton = get_node(MenuButtonPath)
	
	MenuButton.connect("toggled",Callable(self,"_handle_button"))
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
