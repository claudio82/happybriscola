extends Node

#var card_names = ["1-1", "2-1", "3-1", "4-1", "5-1", "6-1", "7-1", "8-1", "9-1", "10-1", 
#	"1-2", "2-2", "3-2", "4-2", "5-2", "6-2", "7-2", "8-2", "9-2", "10-2", 
#	"1-3", "2-3", "3-3", "4-3", "5-3", "6-3", "7-3", "8-3", "9-3", "10-3", 
#	"1-4", "2-4", "3-4", "4-4", "5-4", "6-4", "7-4", "8-4", "9-4", "10-4" ]
#var card_values = [1,2,3,4,5,6,7,8,9,10]
#var card_suits = [1,2,3,4]
var deck = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	init_deck()

func init_deck() -> void:
	for suit in range(0, 4):
		for value in range(0, 10):
			var card = preload("res://scenes/card.tscn").instantiate()
			#card.card_name = card_names[value+10*suit]
			card.value = value + 1
			card.suit = suit + 1
			
			# card.connect("card_selected", get_tree().get_root().get_node("Main"), "_card_selected")
			deck.append(card)
	deck.shuffle()
	print(deck.size(), " cards in the deck.")

func give_cards(num):
	var cardreturn = []
	for i in num:
		if (deck.size() > 0):
			cardreturn.append(deck[i])
		#print(cardreturn[i].card_name)
	for i in cardreturn.size():
		if (deck.size() > 0):
			deck.pop_at(0)
	print(deck.size(), " cards in the deck.")
	return cardreturn

func is_empty() -> bool:
	return deck.is_empty()

func reset_table():
	for i in deck.size():
		deck[i].kill_card()
	deck = []
	
func re_add_briscola(card):
	deck.push_back(card)
	
func print_first_card_in_deck():
	print("deck first card: ", deck[0].value, "-", deck[0].suit)

func draw_d():
	if deck.size() > 0:
		deck[0].handPosition = get_node("../DeckPile").position #Vector2(300,300)
		deck[0].move_card(deck[0].handPosition)
		add_child(deck[0])
