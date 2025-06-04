extends Node

#signal language_changed(language:String)

var language: String = "it"
#var language := 0 :
#    set(mod_value):
#        if lamguage == mod_value:
#            return
#
#        language = mod_value
#        language_changed.emit(language)

const save_file := "user://saved.dat"

func reload() -> void:
	var file := ConfigFile.new()
	var err := file.load(save_file)
	if err != OK:
		push_error("error loading file " + str(err))
		return
	language = String(file.get_value("Globals", "Language"))

func save() -> void:
	var file := ConfigFile.new()
	file.set_value("Globals", "Language", language)
	var err := file.save(save_file)
	if err != OK:
		push_error("error saving file " + str(err))
