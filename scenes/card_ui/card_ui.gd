class_name CardUI
extends Control

const BASE_STYLEBOX  := preload("res://scenes/card_ui/card_base_style_box.tres")
const DRAG_STYLEBOX  := preload("res://scenes/card_ui/card_dragging_style_box.tres")
const HOVER_STYLEBOX := preload("res://scenes/card_ui/card_hover_style_box.tres")

signal reparent_requested(which_card_ui: CardUI)
@onready var panel: Panel = $Panel
@onready var cost: Label = $Cost
@onready var icon: TextureRect = $Icon
@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine
@onready var targets: Array[Node] = []
@onready var original_index := self.get_index()

@export var card: Card: set = _set_card
@export var char_stats: CharacterStats : set = _set_char_stats
var playable := true : set = _set_playable
var disabled := false

var parent: Control
var tween: Tween


func _ready() -> void:
	Events.card_drag_started.connect(_on_card_drag_or_aim_started)
	Events.card_aim_started.connect(_on_card_drag_or_aim_started)
	Events.card_drag_ended.connect(self._on_card_drag_or_aim_ended)
	Events.card_aim_ended.connect(self._on_card_drag_or_aim_ended)
	card_state_machine.init(self)

func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)


func animate_to_position(new_position: Vector2, duration: float) -> void:
	tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", new_position, duration)


func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)


func _on_mouse_entered():
	card_state_machine.on_mouse_entered()


func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()


func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)


func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	targets.erase(area)

func setPanelTheme(res: Resource):
	panel.set("theme_override_styles/panel", res)
	
func play() -> void:
	if not card:
		return
	card.play(targets, char_stats)
	queue_free()


func _on_card_drag_or_aim_started(used_card: CardUI) -> void:
	if used_card == self:
		return
	disabled = true

func _on_card_drag_or_aim_ended(_used_card: CardUI) -> void:
	disabled = false
	self.playable = char_stats.can_play_card(card)

func _set_playable(value: bool) -> void:
	playable = value
	if not playable:
		cost.add_theme_color_override("font_color", Color.RED)
		icon.modulate = Color(1, 1, 1, .5)
	else:
		cost.remove_theme_color_override("font_color")
		icon.modulate = Color(1, 1, 1, 1)


func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	char_stats.stats_changed.connect(_on_char_stats_changed)


func _on_char_stats_changed() -> void:
	# Placeholder for the logic to handle when character stats are changed
	if char_stats:
		# Example: Update visuals or UI based on changed stats
		print("Character stats updated:", char_stats)

func _set_card(value: Card) -> void:
	if not is_node_ready():
		await ready

	card = value
	cost.text = str(card.cost)
	icon.texture = card.icon
