extends Area2D

const CARD_W = 177
var card_name
var value	# starts from 1 (ace) to 10 (king)
var suit	# from 1 to 4
var flipped = false
var dealt = false
var isPlayerCard = false
var selectable:bool :set=set_selectable
var selected_card = false
var cardScale: set=set_card_scale, get=get_card_scale
var handPosition = Vector2.ZERO
var handRotation = Vector2.ZERO

var lastRemoveFromPlayerHandIdx = -1
var lastRemoveFromOpponentHandIdx = -1

@export var focus_move_on_y = 40

signal card_selected(node)

@onready var sprite:Sprite2D = $Sprite2D

func set_card_scale(scaleDbl) -> void:
	cardScale = scaleDbl

func get_card_scale() -> float:
	if cardScale:
		return cardScale
	return 0.0
	
func set_selectable(val):
	selectable = val

func get_card_width() -> int:
	return CARD_W

func _ready() -> void:
	update_sprite()

func update_sprite() -> void:
	if sprite:
		sprite.texture = get_texture()

func get_texture() -> Resource:
	if not flipped:
		return preload("res://assets/textures/cards/back.png")
		
	var res_path = "res://assets/textures/cards/{value}-{suit}.png".format({
		"value": str(value),
		"suit": str(suit)
	})
	
	return load(res_path)

func flip() -> void:
	flipped = !flipped
	update_sprite()

func move_card(dest):
	position = dest
	
func get_points()-> int:
	if value == 1:
		return 11
	elif value  == 3:
		return 10
	elif value == 10:
		return 4
	elif value == 9:
		return 3
	elif value == 8:
		return 2
	else:
		return 0


func kill_card()-> void:
	queue_free()

func print_card_info() -> String:
	return str(value) + "-" + str(suit)

func make_focus():
	if selectable:
		var position_shift = position
		position_shift.y -= focus_move_on_y
		if position == handPosition:
			move_card(position_shift)
		z_index = 2
		selected_card = true
		emit_signal("active_card", self)

func off_focus():
	if selectable:
		move_card(handPosition)
		z_index = 1
		selected_card = false

func make_active(card):
	if card != self:
		off_focus()

func _on_Card_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:  #|| event is InputEventScreenTouch:		
		if selectable and !selected_card and event.is_action_pressed("click") and isPlayerCard :
			selected_card = true
			emit_signal("card_selected", self)
			get_tree().call_group("main_scene", "_card_selected", self)
