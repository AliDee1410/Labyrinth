"""
This code is currently not being used in the project,
but may be useful in the future if I decide to implement a saving system
"""
extends Node

const SAVE_FILE = "user://save.json"

var save_data = {}

func read_save():
	var file = File.new()
	
	if not file.file_exists(SAVE_FILE):
		save_data = {"Player Name": "Unnamed"}
		write_save()
		
	file.open(SAVE_FILE, File.READ)
	var content = file.get_as_text()
	var data = parse_json(content)
	file.close()
	return data

func write_save():
	var file = File.new()
	
	file.open(SAVE_FILE, File.WRITE)
	file.store_line(to_json(save_data))
