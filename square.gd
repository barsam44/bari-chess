extends Area2D

signal square_clicked(pos: Vector2i)

var board_pos: Vector2i
var base_color: Color = Color.WHITE

func _ready():
	input_pickable = true
	$ColorRect.size = Vector2(50, 50)
	$ColorRect.position = Vector2.ZERO
	update_color()

func update_color():
	$ColorRect.color = base_color

func set_highlight(active: bool):
	modulate = Color.YELLOW if active else Color.WHITE
	if not active:
		update_color()

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		square_clicked.emit(board_pos)
