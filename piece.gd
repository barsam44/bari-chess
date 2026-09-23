extends Node2D

@export var piece_type: String = "pawn"   # pawn, rook, knight, bishop, queen, king
@export var piece_color: String = "white" # white یا black

var board_pos: Vector2i  # موقعیت مهره روی صفحه
var is_selected: bool = false

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


func select():
	"""مهره رو انتخاب کن و حرکت‌های معتبر رو نمایش بده"""
	is_selected = true
	print(piece_color, " ", piece_type, " selected at ", board_pos)
	emit_signal("piece_clicked", self)


func deselect():
	"""مهره رو از انتخاب خارج کن"""
	is_selected = false


func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		select()
