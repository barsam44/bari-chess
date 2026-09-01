extends Node2D

@export var piece_type: String = "pawn"   # pawn, rook, knight, bishop, queen, king
@export var piece_color: String = "white" # white یا black

signal piece_clicked(piece)

func _ready():
	_load_texture()


func _load_texture():
	var sprite := $Sprite2D

	# ساخت مسیر فایل بر اساس اسم‌گذاری تو
	var path := "res://pieces-basic/%s-%s.png" % [piece_color, piece_type]

	# تلاش برای لود کردن تکسچر
	var tex := load(path)

	if tex:
		sprite.texture = tex
	else:
		push_error("Texture not found: " + path)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		piece_clicked.emit(self)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("piece_clicked", self)
