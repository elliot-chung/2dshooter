extends Control

signal powerup_selected(rarity, name)

const POWER_PATH = "res://Powerups/"

@export var InventoryPath := NodePath()
@export var CardPath1 := NodePath()
@export var CardPath2 := NodePath()
@export var CardPath3 := NodePath() 

var item_data: Dictionary
var Card1: TextureRect
var Card2: TextureRect
var Card3: TextureRect

func _set_img_desc(Card, rarity, name, img, desc):
	var TextureRect:TextureRect = Card.get_node("TextureRect")
	var NameLabel:Label = Card.get_node("Name")
	var DescLabel:Label = Card.get_node("Description")
	
	
	Card.rarity = rarity
	Card.texture = load("res://Powerup Inventory/" + rarity + ".png")
	TextureRect.texture = load(img)
	NameLabel.text = name.replace("_", " ")
	DescLabel.text = desc
	

func _select_card1():
	var name: String = Card1.get_node("Name").text.replace(" ", "_")
	var rarity: String = Card1.rarity 
	emit_signal("powerup_selected", rarity, name)
	reset_options()

func _select_card2():
	var name: String = Card2.get_node("Name").text.replace(" ", "_")
	var rarity: String = Card2.rarity 
	emit_signal("powerup_selected", rarity, name)
	reset_options()
	
func _select_card3():
	var name: String = Card3.get_node("Name").text.replace(" ", "_")
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
		if rarity_factor < 80:
			rarity = "common"
			i = randi() % common_n
		elif rarity_factor < 99:
			rarity = "rare"
			i = randi() % rare_n
		else:
			rarity = "legendary"
			i = randi() % legendary_n	
		
		key = item_data[rarity].keys()[i]	
		
		_set_img_desc(Card, rarity, key, item_data[rarity][key].img_path, item_data[rarity][key].description)
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	item_data = get_node(InventoryPath).item_dictionary
	
	Card1 = get_node(CardPath1)
	Card2 = get_node(CardPath2)
	Card3 = get_node(CardPath3)
	
	Card1.get_node("Button").connect("pressed",Callable(self,"_select_card1"))
	Card2.get_node("Button").connect("pressed",Callable(self,"_select_card2"))
	Card3.get_node("Button").connect("pressed",Callable(self,"_select_card3"))
	
	reset_options()


