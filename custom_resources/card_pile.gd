class_name CardPile
extends Resource

signal card_pile_size_change(cards_amount: int)

@export var cards: Array[Card] = []

func empty() -> bool:
	return cards.is_empty();
	
func draw_card() -> Card:
	var card = cards.pop_front()
	emit_pile_size_changed()
	return card
	
func add_card(card: Card):
	cards.append(card)
	emit_pile_size_changed()

func shuffle():
	cards.shuffle()
	
func clear():
	cards.clear()
	emit_pile_size_changed()
	
func _to_string() -> String:
	var _card_strings: PackedStringArray = []
	for i in range(cards.size()):
		_card_strings.append("%s: %s" % [i+1, cards[i].id])
	return "\n".join(_card_strings)

func emit_pile_size_changed():
	card_pile_size_change.emit(cards.size())
