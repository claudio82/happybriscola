extends "res://scripts/hand.gd"

var cardDistance = 65
var briscolaCard
@onready var startPoint = $LeftPoint

func draw_pdeck():
	draw_deck()

func draw_table_briscola():
	draw_cards(1)
	set_briscola()

func place_cards():
	for i in hand.size():
		hand[i].handPosition.y = startPoint.position.y
		hand[i].handPosition.x = startPoint.position.x + i * cardDistance
		add_child(hand[i])
		if !hand[i].dealt:
			hand[i].position = $Deck.position
		hand[i].dealt = true
		hand[i].move_card(hand[i].handPosition)

func set_briscola():
	briscolaCard = hand[0]
	print("\nBRISCOLA SET TO: ", briscolaCard.value, "-", briscolaCard.suit)
	
func get_briscola() -> Area2D:
	return briscolaCard
	
func hide_cards():
	for i in hand.size():
		hand[i].hide()
