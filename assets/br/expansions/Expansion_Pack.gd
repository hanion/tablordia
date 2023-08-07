extends DeckPrep

var pack_second_value := 0
var expansion_name := "exp_skill" # "exp_military"


var exp_skill_env := [
	8,7,6,5,4,3,2,1
]

var exp_military_env := [
	0,0,
	1,1,1,1,
	2,2,2,2,2,2,2,2,2,2,
	3,3,3,3,3,
	4,4,4,4,4,
	5,5,5,5,5,
	6,6,7,7,
	8,8,9,9,
	10,10,10,10,
	11,12,
	13,13,13,13,
	14,14,15,15,
	16,17,18,19,20,21,22,
	23,24,25,26,27,28,29,30,31,
	32,33,34,35,36,37,38
]





func _ready():
	init("Card",expansion_name)





# only called in server
func create_draw_deck() -> void:
	
	match expansion_name:
		"exp_skill":
			for card_value in exp_skill_env:
				add_to_pdeck(card_value, pack_second_value)
	
		"exp_military":
			for card_value in shuffle(exp_military_env):
				add_to_pdeck(card_value, pack_second_value)
	
	
	print("exp: created pdeck (",expansion_name,")")
