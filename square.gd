extends Node2D

@export var board_pos: Vector2i

signal square_clicked(board_pos: Vector2i)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("square_clicked", board_pos)
