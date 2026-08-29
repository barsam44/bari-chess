extends Node2D

const BOARD_SIZE := 8
const TILE_SIZE := 80

@onready var SquareScene := preload("res://Square.tscn")
@onready var PieceScene := preload("res://Piece.tscn")

func _ready():
	_create_board()
	_spawn_pieces()


func _create_board():
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			var square = SquareScene.instantiate()
			square.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			square.board_pos = Vector2i(x, y)
			square.square_clicked.connect(_on_square_clicked)

			# رنگ‌بندی شطرنجی
			var color_rect = square.get_node("ColorRect")
			if (x + y) % 2 == 0:
				color_rect.color = Color.DEEP_PINK
			else:
				color_rect.color = Color.DEEP_SKY_BLUE

			add_child(square)


func _spawn_pieces():
	# مهره‌های سفید
	for x in range(8):
		_create_piece("pawn", "white", Vector2i(x, 6))

	_create_piece("rook", "white", Vector2i(0, 7))
	_create_piece("rook", "white", Vector2i(7, 7))
	_create_piece("knight", "white", Vector2i(1, 7))
	_create_piece("knight", "white", Vector2i(6, 7))
	_create_piece("bishop", "white", Vector2i(2, 7))
	_create_piece("bishop", "white", Vector2i(5, 7))
	_create_piece("queen", "white", Vector2i(3, 7))
	_create_piece("king", "white", Vector2i(4, 7))

	# مهره‌های سیاه
	for x in range(8):
		_create_piece("pawn", "black", Vector2i(x, 1))

	_create_piece("rook", "black", Vector2i(0, 0))
	_create_piece("rook", "black", Vector2i(7, 0))
	_create_piece("knight", "black", Vector2i(1, 0))
	_create_piece("knight", "black", Vector2i(6, 0))
	_create_piece("bishop", "black", Vector2i(2, 0))
	_create_piece("bishop", "black", Vector2i(5, 0))
	_create_piece("queen", "black", Vector2i(3, 0))
	_create_piece("king", "black", Vector2i(4, 0))


func _create_piece(type: String, color: String, pos: Vector2i):
	var piece = PieceScene.instantiate()
	piece.piece_type = type
	piece.piece_color = color

	piece.position = Vector2(
	pos.x * TILE_SIZE + TILE_SIZE / 2,
	pos.y * TILE_SIZE + TILE_SIZE / 2
)


	add_child(piece)


func _on_square_clicked(pos: Vector2i):
	print("Clicked:", pos)
