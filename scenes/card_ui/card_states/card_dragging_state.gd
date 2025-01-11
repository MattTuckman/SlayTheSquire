class_name CardDraggingState extends CardState

const DRAG_MINIMUM_THRESHOLD = 0.1

var ui_layer: Node
var min_drag_elapsed := false

func enter():
	card_ui.color.color = Color.LAWN_GREEN
	card_ui.state.text = "DRAGGING"
	if ui_layer == null:
		ui_layer = get_tree().get_first_node_in_group("ui_layer")
	card_ui.reparent(ui_layer)
	
	min_drag_elapsed = false
	var threshold_timer := get_tree().create_timer(DRAG_MINIMUM_THRESHOLD, false)
	threshold_timer.timeout.connect(func(): min_drag_elapsed = true)
	
	
func on_input(event: InputEvent):
	var mouse_motion := event is InputEventMouseMotion
	var cancel = event.is_action_pressed("right_mouse")
	var confirm = event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse")
	var single_targeted := card_ui.card.is_single_targeted()
	
	if single_targeted and mouse_motion and card_ui.targets.size() > 0:
		transition_requested.emit(self, CardState.State.AIMING)
		return
	
	if mouse_motion:
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.pivot_offset
		
		
	if cancel:
		transition_requested.emit(self, CardState.State.BASE)
	elif min_drag_elapsed and confirm:
		get_viewport().set_input_as_handled()
		transition_requested.emit(self, CardState.State.RELEASED)
	
