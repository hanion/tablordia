extends DeckPrep

var pack_second_value := 0
var expansion_name := "exp_skill" # "exp_military"

var exp_island_env := [
	1,1,2,3,3,4,5,5,
	6,7,7,8,8,9,10,11,
	12,13,14,15,16,16,17,17,
	17,18,18,19,19,20,20,20,
	20,20,20,20,20,20,20,20,
	20,20,20,20,30,30,31,31,
	39,38,37,36,35,34,33,32,
	47,46,45,44,43,42,41,40,
	53,52,51,50,49,48, 55,54,
	63,62,61,60,59,58,57,56,
]

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
			prepping_deck.can_make_cards_visible = false
			prepping_deck.can_make_cards_hidden = false
		
		
		"exp_island":
			for card_value in shuffle(exp_island_env):
				add_to_pdeck(card_value, pack_second_value)
			prepping_deck.can_make_cards_visible = false
			prepping_deck.can_make_cards_hidden = false
			
		
	
	
	print("exp: created pdeck (",expansion_name,")")
