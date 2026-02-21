extends Node
#
#func _ready():
	#var dir = DirAccess.open("res://")  # nebo cesta k tvému projektu
	#_parse_dir(dir)
	#
#func _parse_dir(dir: DirAccess):
	#dir.list_dir_begin()
	#var file_name = dir.get_next()
	#while file_name != "":
		#if dir.current_is_dir() and file_name != "." and file_name != "..":
			#_parse_dir(DirAccess.open(dir.get_current_dir() + "/" + file_name))
		#elif file_name.ends_with(".gd"):
			#_print_functions(dir.get_current_dir() + "/" + file_name)
		#file_name = dir.get_next()
	#dir.list_dir_end()
#
#func _print_functions(path: String):
	#var text = FileAccess.get_file_as_string(path)
	#for line in text.split("\n"):
		#if line.strip_edges().begins_with("func "):
			#print(path + ": " + line.strip_edges())
