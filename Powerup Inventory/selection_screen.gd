extends Control

signal powerup_selected(name)

const POWER_PATH = "res://Powerups/"

const ITEM_DATA = {
	"healthy": "Gain more health",
	"faster": "Increase your speed"
}

@export var CardPath1 := NodePath()
@export var CardPath2 := NodePath()
@export var CardPath3 := NodePath() 

var Card1: Button
var Card2: Button
var Card3: Button

func _set_img_desc(Card, name, img, desc):
	var TextureRect:TextureRect = Card.get_node("VBoxContainer/TextureRect")
	var NameLabel:Label = Card.get_node("VBoxContainer/Name")
	var DescLabel:Label = Card.get_node("VBoxContainer/Description")
	
	
	
	TextureRect.texture = load(img)
	NameLabel.text = name
	DescLabel.text = desc
	

func _select_card1():
	var name: String = Card1.get_node("VBoxContainer/Name").text
	emit_signal("powerup_selected", name)
	reset_options()

func _select_card2():
	var name: String = Card2.get_node("VBoxContainer/Name").text
	emit_signal("powerup_selected", name)
	reset_options()
	
func _select_card3():
	var name: String = Card3.get_node("VBoxContainer/Name").text
	emit_signal("powerup_selected", name)
	reset_options()

func reset_options():
	var n := ITEM_DATA.size()
	var i1 := randi() % n
	var i2 := randi() % n
	var i3 := randi() % n
	# while (i1 == i2):
	# 	i2 = randi() % n
	# while (i2 == i3):
	# 	i3 = randi() % n
		
	var key1: String = ITEM_DATA.keys()[i1]
	var key2: String = ITEM_DATA.keys()[i2]
	var key3: String = ITEM_DATA.keys()[i3]
	
	_set_img_desc(Card1, key1, POWER_PATH + key1 + ".png", ITEM_DATA[key1])
	_set_img_desc(Card2, key2, POWER_PATH + key2 + ".png", ITEM_DATA[key2])
	_set_img_desc(Card3, key3, POWER_PATH + key3 + ".png", ITEM_DATA[key3])
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	Card1 = get_node(CardPath1)
	Card2 = get_node(CardPath2)
	Card3 = get_node(CardPath3)
	
	Card1.connect("pressed",Callable(self,"_select_card1"))
	Card2.connect("pressed",Callable(self,"_select_card2"))
	Card3.connect("pressed",Callable(self,"_select_card3"))
	
	reset_options()


