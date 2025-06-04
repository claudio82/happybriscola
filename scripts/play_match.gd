extends Node2D

var player_card
var opponent_card

var iBriscola
var iBriscolaMinor
var p1Points = 0
var cpuPoints = 0

var winner = -1

enum PlayerType { PlayerOne = 1, Cpu = 2 }

@onready var PlayerCardPosition = $PlayerCardPosition
@onready var OpponentCardPosition = $OpponentCardPosition
@onready var FlipSnd:AudioStreamPlayer = $FlipSnd

signal turn_is_over()
signal update_ui_pts(value1:int, value2:int)

func who_starts_first() -> String:
	var rnd = randi() % 2
	if rnd == 0:
		return "Player"
	return "Opponent" 

func play_turn(firstToPlay, showOppCard = true):
	if firstToPlay == "Player":
		player_card.move_card(PlayerCardPosition.position)		
	else:
		opponent_card.move_card(OpponentCardPosition.position)
		if showOppCard:
			opponent_card.flip()
	
	if !FlipSnd.playing:
		FlipSnd.play()

func compute_turn_winner() -> int:
	
	var numCardPlayer1 = player_card.value
	var seedCardPlayer1 = player_card.suit
	var numCardPlayer2 = opponent_card.value
	var seedCardPlayer2 = opponent_card.suit
	
	if seedCardPlayer1 == iBriscola and seedCardPlayer2 != iBriscola:
		winner = PlayerType.PlayerOne
	elif seedCardPlayer2 == iBriscola and seedCardPlayer1 != iBriscola:
		winner = PlayerType.Cpu
	elif seedCardPlayer1 == iBriscola and seedCardPlayer2 == iBriscola:
		if numCardPlayer1 == 1:
			winner = PlayerType.PlayerOne
		elif numCardPlayer2 == 1:
			winner = PlayerType.Cpu
		elif numCardPlayer1 == 3:
			winner = PlayerType.PlayerOne
		elif numCardPlayer2 == 3:
			winner = PlayerType.Cpu
		elif numCardPlayer1 > numCardPlayer2 and numCardPlayer1 != 1 and numCardPlayer1 != 3 and numCardPlayer2 != 1 and numCardPlayer2 != 3:
			winner = PlayerType.PlayerOne
		else:
			winner = PlayerType.Cpu
	else:
		# Nobody has a briscola
		if seedCardPlayer1 == iBriscolaMinor and seedCardPlayer2 != iBriscolaMinor:
			winner = PlayerType.PlayerOne
		elif seedCardPlayer2 == iBriscolaMinor and seedCardPlayer1 != iBriscolaMinor:
			winner = PlayerType.Cpu
		elif seedCardPlayer1 == iBriscolaMinor and seedCardPlayer2 == iBriscolaMinor:
			if numCardPlayer1 == 1:
				winner = PlayerType.PlayerOne
			elif numCardPlayer2 == 1:
				winner = PlayerType.Cpu
			elif numCardPlayer1 == 3:
				winner = PlayerType.PlayerOne
			elif numCardPlayer2 == 3:
				winner = PlayerType.Cpu
			elif numCardPlayer1 > numCardPlayer2 and numCardPlayer1 != 1 and numCardPlayer1 != 3 and numCardPlayer2 != 1 and numCardPlayer2 != 3:
				winner = PlayerType.PlayerOne
			else:
				winner = PlayerType.Cpu
	return winner

func inc_score_turn_and_assign_pts() -> void:
	var scoreTurn = player_card.get_points() + opponent_card.get_points()
	if winner == PlayerType.PlayerOne:
		p1Points += scoreTurn
	else:
		cpuPoints += scoreTurn
	print("\nPlayer points = ", p1Points)
	print("Opponent points = ", cpuPoints)
	
	emit_signal("update_ui_pts", p1Points, cpuPoints)
	get_tree().call_group("ui_scene", "_update_ui_pts", p1Points, cpuPoints)

func clear_turn():
	#await get_tree().create_timer(0.8).timeout
	if player_card:
		player_card.kill_card()
	if opponent_card:
		opponent_card.kill_card()
	
	emit_signal("turn_is_over")
	get_tree().call_group("main_scene", "_turn_over")

func selectCpuBestStartingCard(_turnNo, cpuPlaysFirst, opponent_hand, briscolaSuit) -> int: 
	var chosen_idx = -1
	var last_best_idx = -1
	if cpuPlaysFirst:
		for i in opponent_hand.size():
			if opponent_hand[i].get_points() < 5 and opponent_hand[i].suit != briscolaSuit:
				last_best_idx = i
	
		if last_best_idx == -1:
			var idx = getBriscola(opponent_hand, briscolaSuit)
			if idx < opponent_hand.size():
				last_best_idx = idx
	
		if last_best_idx == -1:
			chosen_idx = randi() % opponent_hand.size()
		else:
			chosen_idx = last_best_idx
	else:
		var idr = randi() % 10
		
		if (player_card.suit != briscolaSuit):	# se il giocatore non ha giocato una briscola
			var idx = getSoprataglio(opponent_hand, true)
			if (idx < opponent_hand.size()):
				last_best_idx = idx
			else:
				if (player_card.get_points()>=0):
					idx = getBriscola(opponent_hand, briscolaSuit)
					if idx < opponent_hand.size():	#se la cpu ha una briscola in mano
						if (player_card.get_points() > 2):	#se la carta giocata dal giocatore e' un cavallo o sopra, gioca la briscola
							last_best_idx = idx
						elif opponent_hand[idx].get_points() > 0:	# se la carta che si vuole giocare e' briscola ed ha un punteggio
							if (idr%10<5):	# la cpu decide se giocarla o meno
								last_best_idx = idx
					else:
						idx = getSoprataglio(opponent_hand, false)
						if idx < opponent_hand.size():
							last_best_idx = idx
						else:
							for i in range(0, opponent_hand.size()):
								if opponent_hand[i].suit != player_card.suit:
									if opponent_hand[i].get_points() == 0:
										last_best_idx = i
										break
			
		else:
			var idx = getSoprataglio(opponent_hand, false)
			if (idr%10<5 and idx < opponent_hand.size()):
				last_best_idx = idx
			else:
				for i in range(0, opponent_hand.size()):
					if opponent_hand[i].suit != player_card.suit:
						if opponent_hand[i].get_points() == 0:
							last_best_idx = i
							break
		
		if last_best_idx == -1:
			chosen_idx = 0
		else:
			chosen_idx = last_best_idx
	
	return chosen_idx

#Cerca la piu' grande carta dello stesso seme che prende, o la piu' piccola che non prende
# PARAMETRI DI INPUT:
#	mano: le carte in mano al giocatore da "aiutare"
#	c: carta giocata dall'altro giocatore
#	maggiore: flag che identifica se bisogna trovare "la piu' grande che prende" (true) o "la piu' piccola che non prende" (false)
# retituisce l'indice della carta da giocare
#
func getSoprataglio(opponent_hand, maggiore) -> int:
	var found = false
	var index = -1
	var minPoints = 0
	if maggiore:	# si cerca la carta piu' grande che puo' prendere la carta giocata
		for i in range(0, opponent_hand.size()):
			if (!found and (player_card.suit == opponent_hand[i].suit) and (player_card.get_points() < opponent_hand[i].get_points())):
				if opponent_hand[i].get_points() > minPoints:
					found = true
					index = i
					minPoints = opponent_hand[i].get_points()
				
			if (!found and (player_card.suit == opponent_hand[i].suit) and (opponent_hand[i].get_points() <= player_card.get_points())):
				if opponent_hand[i].get_points() == 0:
					found = true
					index = i
					break
				#else:
				#	break

	else:	#si cerca la carta piu' piccola che non puo' prendere la carta giocata
		for i in range(0, opponent_hand.size()):
			if ((player_card.suit == opponent_hand[i].suit) and (player_card.get_points() < opponent_hand[i].get_points())):
				found = true
				index = i
				break
	
	if found:
		return index
	else:
		return opponent_hand.size()

#Cerca la piu' piccola carta di briscola in mano
func getBriscola(opponent_hand, briscola_suit):
	var idx = opponent_hand.size()
	var maxPoints = 12
	for i in range(0,opponent_hand.size()):
		if briscola_suit == opponent_hand[i].suit:
			if opponent_hand[i].get_points() < maxPoints:
				idx = i
				maxPoints = opponent_hand[i].get_points()

	return idx

func get_points(playerName):
	if playerName == "Player":
		return p1Points
	else:
		return cpuPoints
