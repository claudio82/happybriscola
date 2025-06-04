extends Node2D

@onready var Deck = $CardController/Deck
@onready var Player = $CardController/PlayerHand
@onready var Opponent = $CardController/OpponentHand
@onready var Table = $CardController/Table
@onready var PlayMatch = $CardController/PlayMatch
@onready var LangOptionSel:OptionButton = $CanvasLayer/Panel/PauseMenu/VBoxContainer/HBoxContainer/LangOptBtn

signal draw_cards_completed()
signal game_over_to_ui(winner: String)
signal show_pause_menu()
signal hide_pause_menu()
signal update_pts_labels()
signal update_restart_label()

# Game States
enum {
	SETUP,
	SELECT_CARD,
	START,
	FLOP,
	END
}
var gamestate = SETUP
var currentround = START
var card_selected = false
var player_card
var opponent_card
var briscolaSuit = -1
var briscolaMinor = -1
var playerTurn
var turn_winner
var turnNo
var isOpponentShowingCards = false   #if set to true show opponent cards
var lastRemoveFromPlayerHandIdx = -1
var lastRemoveFromOpponentHandIdx = -1

var isGameOver = false
var isPaused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !is_in_group("main_scene"):
		add_to_group("main_scene")
	
	GameManager.reload()
	#if (GameManager.language.length() == 0):
	#	var langOptIdx = LangOptionSel.selected
	#	if langOptIdx == 0:
	#		TranslationServer.set_locale("it") # we set the given locale in the TranslationServer
	#	elif langOptIdx == 1:
	#		TranslationServer.set_locale("en")
	#else:
	if GameManager.language == "it":
		LangOptionSel.selected = 0
		TranslationServer.set_locale("it")
	elif GameManager.language == "en":
		LangOptionSel.selected = 1
		TranslationServer.set_locale("en")
	
	emit_signal("update_pts_labels")
	get_tree().call_group("ui_scene", "_update_points_labels")
	
	emit_signal("update_restart_label")
	get_tree().call_group("ui_scene", "_update_restart_label")
	
	init_match()

func init_match():
	await get_tree().create_timer(1).timeout
	get_tree().call_group("players", "draw_cards", 3)
	
	print_players_hands()
	
	Table.draw_table_briscola()
	print("\nBRISCOLA CARD: ")
	Table.print_hand()
	briscolaSuit = Table.get_briscola().suit
	print("\nBRISCOLA SUIT: ", briscolaSuit)
	
	Deck.re_add_briscola(Table.get_briscola())
		
	Deck.print_first_card_in_deck()
	
	PlayMatch.iBriscola = briscolaSuit
	
	#Table.draw_pdeck()
	if isOpponentShowingCards:
		Opponent.flip_cards()
		#PlayMatch.debugOpponentCards = true
	
	#playerTurn = true
	turn_winner = PlayMatch.who_starts_first()

	# Player starts the match
	gamestate = SELECT_CARD
	
	turnNo = 1
	print("\nROUND =  ", turnNo)

	

func _process(_delta: float) -> void:

	#if Input.is_action_just_pressed("show_hide_options_menu"):
		#get_tree().paused = not get_tree().paused
		#get_viewport().set_input_as_handled()
		
		#emit_signal("show_pause_menu")
		#get_tree().call_group("ui_options_menu", "_show_pause_menu")
	
	match gamestate:
		SELECT_CARD:
			if currentround == START:
			#if (Player.get_hand_size() == Opponent.get_hand_size()):
				if turnNo < 23:
					if turn_winner == "Player":
						Player.allow_selection(true)
						currentround = FLOP
					else:
						Player.allow_selection(false)
						currentround = FLOP
						if Opponent.get_hand_size() > 0:
							opponent_starts_play()
				else:
					if Deck.is_empty():
						print("Deck is empty. Game Over!")
					gamestate = END
		END:
			if (PlayMatch.get_points("Player") > PlayMatch.get_points("Opponent")):
				turn_winner = "Player"
			elif (PlayMatch.get_points("Player") < PlayMatch.get_points("Opponent")):
				turn_winner = "Opponent"
			else:
				turn_winner = "Draw"
			
			show_gameover_scr()
			
			gamestate = FLOP

func _input(event: InputEvent) -> void:
	if isGameOver and Input.is_action_just_pressed("click"):
		saveGlobalVarsToFile()
		get_tree().reload_current_scene()
		
	if event.is_action_pressed("show_hide_options_menu"):
		get_node("CanvasLayer/Panel").visible = true
		get_tree().paused = !get_tree().paused
		get_viewport().set_input_as_handled()

func show_gameover_scr():
	emit_signal("game_over_to_ui", turn_winner)
	get_tree().call_group("ui_scene", "_game_over_to_ui", turn_winner)
	
	isGameOver = true
	#get_tree().paused = true

func opponent_starts_play():
	var selIndex = PlayMatch.selectCpuBestStartingCard(turnNo, true, Opponent.get_hand(), briscolaSuit)
	opponent_card = Opponent.remove_cpu_played_card(selIndex)
	
	lastRemoveFromOpponentHandIdx = opponent_card.lastRemoveFromOpponentHandIdx
	PlayMatch.opponent_card = opponent_card
	print("Opponent card = ", opponent_card.value, " - ", opponent_card.suit)
	
	briscolaMinor = opponent_card.suit
	print("Briscola minor set to: ", briscolaMinor)
	PlayMatch.iBriscolaMinor = briscolaMinor
	
	if isOpponentShowingCards:
		PlayMatch.play_turn("Opponent", false)
	else:
		PlayMatch.play_turn("Opponent")
	
	Player.allow_selection(true)

func process_last_played_hand():
	var winner = PlayMatch.compute_turn_winner()
	match winner:
		1:
			turn_winner = "Player"
		2:
			turn_winner = "Opponent"
	print("Turn winner is: ", turn_winner)
	
	PlayMatch.inc_score_turn_and_assign_pts()
	
	if turn_winner == "Opponent":
		#playerTurn = false
		if turnNo < 18:
			#await get_tree().create_timer(3.6).timeout
						
			Opponent.draw_card_from_deck(lastRemoveFromOpponentHandIdx)
			if isOpponentShowingCards:
				Opponent.get_card_at(lastRemoveFromOpponentHandIdx).flip()
			await get_tree().create_timer(1).timeout
			Player.draw_card_from_deck(lastRemoveFromPlayerHandIdx)
			Player.get_card_at(lastRemoveFromPlayerHandIdx).isPlayerCard = true
			Player.get_card_at(lastRemoveFromPlayerHandIdx).flip()
			
			#lastRemoveFromOpponentHandIdx = -1
			#lastRemoveFromPlayerHandIdx = -1
			
			emit_signal("draw_cards_completed")
			get_tree().call_group("main_scene", "_draw_cards_completed")
		else:
			
			emit_signal("draw_cards_completed")
			get_tree().call_group("main_scene", "_draw_cards_completed")
			
		#turnNo += 1
					
		print_players_hands()
		
	else:
		#playerTurn = true
		if turnNo < 18:
			#await get_tree().create_timer(3).timeout
						
			Player.draw_card_from_deck(lastRemoveFromPlayerHandIdx)
			Player.get_card_at(lastRemoveFromPlayerHandIdx).isPlayerCard = true
			Player.get_card_at(lastRemoveFromPlayerHandIdx).flip()
			await get_tree().create_timer(1).timeout
			Opponent.draw_card_from_deck(lastRemoveFromOpponentHandIdx)
			if isOpponentShowingCards:
				Opponent.get_card_at(lastRemoveFromOpponentHandIdx).flip()
				
			#lastRemoveFromOpponentHandIdx = -1
			#lastRemoveFromPlayerHandIdx = -1
			
			emit_signal("draw_cards_completed")
			get_tree().call_group("main_scene", "_draw_cards_completed")
		else:
			
			emit_signal("draw_cards_completed")
			get_tree().call_group("main_scene", "_draw_cards_completed")
		
		#turnNo += 1
		
		print_players_hands()

	if (turnNo == 18):
		Table.hide_cards()
		
		var _brisc = Table.get_briscola()
		if turn_winner == "Opponent":
			Player.draw_briscola(_brisc, lastRemoveFromPlayerHandIdx)
		else:
			Opponent.draw_briscola(_brisc, lastRemoveFromOpponentHandIdx)
	
	print("\nROUND =  ", turnNo)

func print_players_hands():
	print("\nPLAYER HAND: ")
	Player.print_hand()
	
	print("\nOPPONENT HAND: ")
	Opponent.print_hand()


#func allow_selection():
#	Player.allow_selection(true)

#### SIGNAL FUNCTIONS


func _card_selected(card):
	print("Selected card = ", card.value, " - ", card.suit)
	
	if (Player.get_hand_size() == Opponent.get_hand_size()):
		Player.allow_selection(false)
		Player.search_remove_card(card, "Player")
		print("Player card removed at index = ", card.lastRemoveFromPlayerHandIdx)
		#print("\nNew Player Hand: ")
		#Player.print_hand()
		player_card = card
		lastRemoveFromPlayerHandIdx = player_card.lastRemoveFromPlayerHandIdx
		PlayMatch.player_card = player_card
		briscolaMinor = player_card.suit
		print("Briscola minor set to: ", briscolaMinor)	
		PlayMatch.iBriscolaMinor = briscolaMinor
		
		var selIndex = PlayMatch.selectCpuBestStartingCard(turnNo, false, Opponent.get_hand(), briscolaSuit)
		opponent_card = Opponent.remove_cpu_played_card(selIndex)
		lastRemoveFromOpponentHandIdx = opponent_card.lastRemoveFromOpponentHandIdx
		PlayMatch.opponent_card = opponent_card
		print("Opponent card removed at index = ", PlayMatch.opponent_card.lastRemoveFromOpponentHandIdx)
		#print("\nNew Opponent Hand: ")
		#Opponent.print_hand()
		
		print_players_hands()				
		
		PlayMatch.play_turn("Player")
		if isOpponentShowingCards:
			PlayMatch.play_turn("Opponent", false)
		else:
			PlayMatch.play_turn("Opponent")
		
		if turnNo >= 18:
			await get_tree().create_timer(1).timeout
			emit_signal("draw_cards_completed")
			get_tree().call_group("main_scene", "_draw_cards_completed")
		
		process_last_played_hand()
		
	elif (Player.get_hand_size() > Opponent.get_hand_size()):
		Player.allow_selection(false)
		
		Player.search_remove_card(card, "Player")
		print("Player card removed at index = ", card.lastRemoveFromPlayerHandIdx)
		player_card = card
		lastRemoveFromPlayerHandIdx = player_card.lastRemoveFromPlayerHandIdx
		PlayMatch.player_card = player_card
		
		print_players_hands()
		
		PlayMatch.play_turn("Player")
		
		if turnNo >= 18:
			await get_tree().create_timer(1).timeout
			emit_signal("draw_cards_completed")
			get_tree().call_group("main_scene", "_draw_cards_completed")
		
		process_last_played_hand()

func _hidden_options_menu():
	pass
	#get_tree().paused = false
	

func _turn_over():
	turnNo += 1

func _draw_cards_completed():
	PlayMatch.clear_turn()
	
	currentround = START

func saveGlobalVarsToFile():
	var selLang = LangOptionSel.get_item_text(LangOptionSel.selected)
	if selLang == "Italiano":
		GameManager.language = "it"
	elif selLang == "English":
		GameManager.language = "en"
	
	GameManager.save()
