class_name CardReleasedState extends CardState

var played: bool

func enter():
	played = false
	
	if card_ui.targets.is_empty(): 
		# Going against the tutorial which changes state in the on_input event. This avoids lag. Might cause bug later?
		transition_requested.emit(self, CardState.State.BASE)
	else:
		played = true
		card_ui.play()
		