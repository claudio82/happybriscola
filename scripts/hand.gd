extends Node2D

@onready var Deck = get_node("../Deck")
@onready var CardHolder = $CardHolder

var hand = []
var cardpath = "res://assets/texture/cards/"
var card_width
@export var cardScale = Vector2(0.5, 0.5) #: set = _setScale

#func _setScale(val):
#	cardScale = val

@export var is_player_hand = false: set = _setPlayerHand

func _setPlayerHand(val):
	is_player_hand = val

func draw_card_from_deck(pos_in_hand):
	var _card = Deck.give_cards(1)[0]
	hand.insert(pos_in_hand, _card)
	if _card:
		card_width = _card.get_card_width()
		var x_offset = 10 + card_width / 2
		_card.position = $DeckLocation.position + Vector2(pos_in_hand*x_offset, 0) 
		_card.handPosition = _card.position
		_card.move_card(_card.handPosition)
		
		if _card.get_parent():
			_card.get_parent().remove_child(_card)
		add_child(_card)

func draw_briscola(_card, pos_in_hand):
	if _card:
		_card.visible = true
		_card.flip()
		#_card.update_sprite()
		card_width = _card.get_card_width()
		var x_offset = 10 + card_width / 2
		_card.position = $DeckLocation.position + Vector2(pos_in_hand*x_offset, 0) 
		_card.handPosition = _card.position
		_card.move_card(_card.handPosition)
		
		if _card.get_parent():
			_card.get_parent().remove_child(_card)
		add_child(_card)

func get_card_at(idx) -> Area2D:
	return hand.get(idx)

func draw_cards(num):
	hand += Deck.give_cards(num)
	sprite_cards()
	place_cards()

func draw_deck():
	Deck.draw_d()

func sprite_cards():
	for i in hand.size():
		hand[i].update_sprite()
		hand[i].flip()
		hand[i].cardScale = cardScale

func place_cards():
	card_width = hand[0].get_card_width()
	var x_offset = 10 + card_width / 2
	for i in hand.size():
		if !(hand[i].dealt):
			hand[i].position = $DeckLocation.position + Vector2(i*x_offset, 0)
		hand[i].handPosition = hand[i].position
		hand[i].move_card(hand[i].handPosition)
		hand[i].isPlayerCard = is_player_hand
		hand[i].dealt = true
		CardHolder.add_child(hand[i])

func flip_cards():
	for i in hand.size():
		hand[i].flip()

func get_hand() -> Array :
	return hand

func print_hand():
	for i in hand.size():
		print(hand[i].print_card_info())
		
func reset_hand():
	for i in hand.size():
		hand[i].kill_card()
		
func get_hand_size()->int:
	return hand.size()

func search_remove_card(_card, _owner):
	var i = hand.find(_card)
	if (_owner == "Player"):
		_card.lastRemoveFromPlayerHandIdx = i
	else:
		_card.lastRemoveFromOpponentHandIdx = i
	hand.pop_at(i)

func remove_cpu_played_card(idx) -> Area2D:	
	var _card = hand.pop_at(idx)
	_card.lastRemoveFromOpponentHandIdx = idx
	return _card

func allow_selection(_selectable: bool):
	for i in hand.size():
		hand[i].selectable = _selectable

func _active_card(card):
	for i in hand.size():
		hand[i].make_active(card)
