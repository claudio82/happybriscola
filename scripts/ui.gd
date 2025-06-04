extends CanvasLayer

@onready var PlayerPointsLbl = $PlayersPoints/PlayerPointsLbl
@onready var PlayerPointsVal = $PlayersPoints/PlayerPointsVal
@onready var OpponentPointsLbl = $PlayersPoints/OpponentPointsLbl
@onready var OpponentPointsVal = $PlayersPoints/OpponentPointsVal
@onready var MatchWinner = $MatchWinner
@onready var RestartActionMsg = $RestartActionMsg

@onready var PlayerWonSnd: AudioStreamPlayer =  $PlayerWonSnd
@onready var PlayerLostSnd: AudioStreamPlayer = $PlayerLostSnd

var pl_points = 0
var op_points = 0
var cur_winner: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_in_group("ui_scene"):
		add_to_group("ui_scene")
	
	MatchWinner.text = ""
	MatchWinner.visible = false

	var msg = tr("RestartMsg")
	RestartActionMsg.text = "[font size=24][pulse freq=1.8 color=#ac101240 ease=-2.0]%s[/pulse][/font]" % msg
	RestartActionMsg.visible = false
	
	PlayerPointsLbl.text = tr("PlayerPointsLbl") # "player points: "
	OpponentPointsLbl.text = tr("OpponentPointsLbl") # "opponent points: "
	
	set_points_labels()
	
func set_points_labels():
	PlayerPointsVal.text = "%s" % pl_points
	OpponentPointsVal.text = "%s" % op_points

func _update_ui_pts(playerPoints, opponentPoints):
	pl_points = playerPoints
	op_points = opponentPoints
	
	set_points_labels()

func _game_over_to_ui(winner):
	var txt
	if winner == "Player" :
		#txt = "YOU WIN !"
		txt = tr("WinMsg")
		if PlayerWonSnd:
			PlayerWonSnd.play()
	elif winner == "Opponent" :
		#txt = "YOU LOSE !"
		txt = tr("LoseMsg")
		if PlayerLostSnd:
			PlayerLostSnd.play()
	else :
		#txt = "DRAW GAME"
		txt = tr("DrawMsg")
		if PlayerLostSnd:
			PlayerLostSnd.play()
	
	cur_winner = winner
	MatchWinner.text = "[font size=58][wave amp=50.0 freq=5.0 connected=1]%s[/wave][/font]" % txt  #"[font size=58][rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]%s[/rainbow][/font]" % txt	
	MatchWinner.visible = true
	RestartActionMsg.visible = true
	
	
# SIGNAL FUNCTIONS
func _update_points_labels():
	PlayerPointsLbl.text = tr("PlayerPointsLbl") # "player points: "
	OpponentPointsLbl.text = tr("OpponentPointsLbl") # "opponent points: "	

func _update_restart_label():
	var msg = tr("RestartMsg")
	RestartActionMsg.text = "[font size=24][pulse freq=1.8 color=#ac101240 ease=-2.0]%s[/pulse][/font]" % msg

func _update_current_winner():
	if !cur_winner.is_empty():
		var txt
		if cur_winner == "Player":
			txt = tr("WinMsg")
		elif cur_winner == "Opponent":
			txt = tr("LoseMsg")
		else:
			txt = tr("DrawMsg")
		
		MatchWinner.text = "[font size=58][wave amp=50.0 freq=5.0 connected=1]%s[/wave][/font]" % txt
