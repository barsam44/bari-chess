extends Node2D

@export var piece_type: String = "pawn"
@export var piece_color: String = "white"

func _ready():
	_load_texture()

func _load_texture():
	var sprite := $Sprite2D
	var path := "res://pieces-basic/%s-%s.png" % [piece_color, piece_type]
	var tex := load(path)
	if tex:
		sprite.texture = tex
	else:
		push_warning("Texture not found: " + path)
