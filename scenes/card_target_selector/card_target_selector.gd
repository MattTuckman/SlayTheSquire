extends Node2D

const ARC_POINTS := 8

@onready var card_arc: Line2D = $CanvasLayer/CardArc
@onready var area_2d: Area2D = $Area2D

var current_card: CardUI
var targeting := false

var last_aim_target: Area2D

func _ready() -> void:
	Events.card_aim_ended.connect(_on_card_aim_ended)
	Events.card_aim_started.connect(_on_card_aim_started)

func _process(_delta: float):
	if not targeting:
		return
	
	area_2d.position = get_local_mouse_position()
	var target := _get_relevant_pos(last_aim_target) if last_aim_target else get_local_mouse_position()
	card_arc.points = _get_points(target)
	
func _get_relevant_pos(area: Area2D) -> Vector2:
	return area.position

func _get_points(target: Vector2) -> Array:
	var points := []
	var start := current_card.global_position
	start.x += (current_card.size.x / 2)
	var distance := (target - start)
	
	for i in ARC_POINTS:
		var t := (1.0 / ARC_POINTS) * i
		var x := start.x + (distance.x / ARC_POINTS) * i
		var y := start.y + ease_out_cubic(t) * distance.y
		points.append(Vector2(x, y))
	
	points.append(target)
	
	return points


func ease_out_cubic(number : float) -> float:
	return 1.0 - pow(1.0 - number, 3.0)


func _on_card_aim_started(card: CardUI) -> void:
	if not card.card.is_single_targeted():
		print("Something terrible happened, aiming with non-single card.")
		return
	
	targeting = true
	area_2d.monitoring = true
	area_2d.monitorable = true
	current_card = card


func _on_card_aim_ended(_card: CardUI) -> void:
	targeting = false
	card_arc.clear_points()
	area_2d.position = Vector2.ZERO
	area_2d.monitoring = false
	area_2d.monitorable = false
	current_card = null
	last_aim_target = null


func _on_area_2d_area_entered(area: Area2D) -> void:
	if not current_card or not targeting:
		print("No current card/ not targeting. Oops.")
		return
	
	if not current_card.targets.has(area):
		current_card.targets.append(area)
		last_aim_target = area


func _on_area_2d_area_exited(area: Area2D) -> void:
	if not current_card or not targeting:
		print("2: No current card/ not targeting. Oops.")
		return
	
	current_card.targets.erase(area)
	last_aim_target = null
