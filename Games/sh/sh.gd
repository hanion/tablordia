extends Spatial


const my_paths := {
	"shboard":"/root/Main/sh/shboard",
	"sh_chancellor":"/root/Main/sh/sh_chancellor",
	"sh_president":"/root/Main/sh/sh_president"
	}



func _ready() -> void:
	write_paths()


func write_paths() -> void:
	for objname in my_paths.keys():
		if List.paths.has(objname):
			push_error("List already has this objects path")
		List.paths[objname] = my_paths[objname]
	
