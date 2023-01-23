extends Control

signal powerup_selected(rarity, name)

const POWER_PATH = "res://Powerups/"

@export var InventoryPath := NodePath()
@export var CardPath1 := NodePath()
@export var CardPath2 := NodePath()
@export var CardPath3 := NodePath() 

var item_data: Dictionary
var Card1: Button
var Card2: Button
var Card3: Button

func _set_img_desc(Card, rarity, name, img, desc):
	var TextureRect:TextureRect = Card.get_node("VBoxContainer/TextureRect")
	var NameLabel:Label = Card.get_node("VBoxContainer/Name")
	var DescLabel:Label = Card.get_node("VBoxContainer/Description")
	
	
	Card.rarity = rarity
	TextureRect.texture = load(img)
	NameLabel.text = name
	DescLabel.text = desc
	

func _select_card1():
	var name: String = Card1.get_node("VBoxContainer/Name").text
	var rarity: String = Card1.rarity 
	emit_signal("powerup_selected", rarity, name)
	reset_options()

func _select_card2():
	var name: String = Card2.get_node("VBoxContainer/Name").text
	var rarity: String = Card2.rarity 
	emit_signal("powerup_selected", rarity, name)
	reset_options()
	
func _select_card3():
	var name: String = Card3.get_node("VBoxContainer/Name").text
	var rarity: String = Card3.rarity 
	emit_signal("powerup_selected", rarity, name)
	reset_options()

func reset_options():
	var common_n:int = item_data["common"].size()
	var rare_n: int = item_data["rare"].size()
	var legendary_n: int = item_data["legendary"].size()
	
	for Card in [Card1, Card2, Card3]:
		var rarity_factor = randi() % 100	
		var rarity = ""
		var key = ""
		var i = 0
		if rarity_factor < 75:
			rarity = "common"
			i = randi() % common_n
			# while (i1 == i2):
			# 	i2 = randi() % n
			# while (i2 == i3):
			# 	i3 = randi() % n
		elif rarity_factor < 95:
			rarity = "rare"
			i = randi() % rare_n
		else:
			rarity = "legendary"
			i = randi() % legendary_n	
		
		key = item_data[rarity].keys()[i]	
		
		_set_img_desc(Card, rarity, key, POWER_PATH + key + ".png", item_data[rarity][key].description)
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	item_data = get_node(InventoryPath).item_dictionary
	
	Card1 = get_node(CardPath1)
	Card2 = get_node(CardPath2)
	Card3 = get_node(CardPath3)
	
	Card1.connect("pressed",Callable(self,"_select_card1"))
	Card2.connect("pressed",Callable(self,"_select_card2"))
	Card3.connect("pressed",Callable(self,"_select_card3"))
	
	reset_options()


