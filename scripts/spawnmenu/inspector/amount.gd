extends HBoxContainer
# amount

signal amount_changed(am)

const MIN_VAL := 1
const MAX_VAL := 99


var amount:int = 1 setget set_amount

onready var val = $value

func _on_minus_pressed():
	if amount == MIN_VAL: return
	set_amount(amount-1)
	val.text = str(amount)


func _on_plus_pressed():
	if amount == MAX_VAL: return
	set_amount(amount+1)
	val.text = str(amount)

func _on_value_text_entered(new_text):
	var new_val = int(new_text)
	if new_val < MIN_VAL: 
		val.text = str(MIN_VAL)
		return
	if new_val > MAX_VAL: 
		val.text = str(MAX_VAL)
		return
	
	set_amount(new_val)


func set_amount(am) -> void:
	amount = am
	emit_signal("amount_changed",amount)
