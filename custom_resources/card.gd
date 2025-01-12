class_name Card extends Resource

enum Type {ATTACK, SKILL, POWER}
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

# Some day...
var _colorMap := {
					 str(Type.ATTACK) + str(Target.SELF): Color.ORANGE_RED,
					 str(Type.ATTACK) + str(Target.SINGLE_ENEMY): Color.RED,
					 str(Type.ATTACK) + str(Target.ALL_ENEMIES): Color.DARK_RED,
					 str(Type.ATTACK) + str(Target.EVERYONE): Color.INDIAN_RED,
					 str(Type.SKILL) + str(Target.SELF): Color.SADDLE_BROWN,
					 str(Type.SKILL) + str(Target.SINGLE_ENEMY): Color.BROWN,
					 str(Type.SKILL) + str(Target.ALL_ENEMIES): Color.ROSY_BROWN,
					 str(Type.SKILL) + str(Target.EVERYONE): Color.BURLYWOOD,
					 str(Type.POWER) + str(Target.SELF): Color.GOLDENROD,
					 str(Type.POWER) + str(Target.SINGLE_ENEMY): Color.GOLD,
					 str(Type.POWER) + str(Target.ALL_ENEMIES): Color.DARK_GOLDENROD,
					 str(Type.POWER) + str(Target.EVERYONE): Color.LIGHT_GOLDENROD,
				 }

@export_group("Card Attributes")
@export var id: String
@export var type: Type
@export var target: Target
@export var cost: int

@export_group("Card Visuals")
@export var icon: Texture
@export_multiline var toolip_text: String

func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY

func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		print("No valid targets.")
		return []
	
	var tree := targets[0].get_tree()
	
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("player")
		Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("enemies")
		Target.EVERYONE:
			return tree.get_nodes_in_group("enemies") + tree.get_nodes_in_group("player")
		_:
			return[]

func play(targets: Array[Node], char_stats: CharacterStats) -> void:
	Events.card_played.emit(self)
	char_stats.mana -= cost

	if is_single_targeted():
		apply_effects(targets)
	else:
		apply_effects(_get_targets(targets))


func apply_effects(_targets: Array[Node]) -> void:
	pass

func getColor() -> Color:
	return _colorMap.get(str(self.type) + str(self.target))