extends Node

var request_collection := {}
var request_index := 0

#	var info  = {
#		"type":type,
#		"name":name,
#		"amount":amount,
#		"value":val,
#		"owner_id":hand_owner_id,
#		"in_deck":deck name,
#		"in_dispenser":self.name,
#		"translation":spawn translation
#		}

#var request_collection = {
#	"request_index":info
#}


# called by server
# when received any spawn request
func collect(info:Dictionary):
	
	request_collection[request_index] = info.duplicate(true)
	request_index += 1

