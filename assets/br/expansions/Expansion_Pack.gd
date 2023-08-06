extends DeckPrep

var skill_pack_number := 0

func _ready():
	init("Card","exp_skill")

# only called in server
func create_draw_deck() -> void:
	for i in range(8,0, -1):
		add_to_pdeck(i, skill_pack_number)
	
	print("exp: created pdeck")
