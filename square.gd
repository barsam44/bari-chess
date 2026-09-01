extends Node2D

@export var board_pos: Vector2i

signal square_clicked(pos: Vector2i)

@onready var color_rect := $ColorRect

var base_color: Color
var highlight_color: Color = Color(1, 1, 0, 0.6) # زرد شفاف
var is_highlighted: bool = false

func _ready():
	base_color = color_rect.color

func set_highlight(on: bool):
	is_highlighted = on
	color_rect.color = highlight_color if on else base_color

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("square_clicked", board_pos)
