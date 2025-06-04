extends Panel

@onready var resume_button : Button = $PauseMenu/Resume
@onready var option_button : OptionButton = $PauseMenu/VBoxContainer/HBoxContainer/LangOptBtn

signal update_points_labels()
signal update_restart_label()
signal update_current_winner()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("show_hide_options_menu"):
		get_tree().paused = false
		hide()
		get_viewport().set_input_as_handled()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()

func _show_pause_menu():
	show()

func _hide_pause_menu():
	self.visible = false

func _on_lang_opt_btn_item_selected(index: int) -> void:
	var locale : String = option_button.get_item_text(index)
	if (locale == "Italiano"):
		TranslationServer.set_locale("it")
	elif (locale == "English"):
		TranslationServer.set_locale("en")
		
	emit_signal("update_points_labels")
	get_tree().call_group("ui_scene", "_update_points_labels")
	
	emit_signal("update_restart_label")
	get_tree().call_group("ui_scene", "_update_restart_label")
	
	emit_signal("update_current_winner")
	get_tree().call_group("ui_scene", "_update_current_winner")

func _on_quit_pressed() -> void:
	get_tree().quit()
