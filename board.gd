extends Node2D

const TILE_SIZE = 50
const BOARD_SIZE = 8

var SquareScene = preload("res://Square.tscn")
var PieceScene = preload("res://Piece.tscn")

var squares: Dictionary = {}
var pieces: Dictionary = {}
var highlighted_squares: Array = []

var camera: Camera2D
var selected_piece: Node = null

const Z_SQUARES = 0
const Z_PIECES = 10
const Z_HIGHLIGHT = 5

# ─── CHESS BOARD COLORS (Classic) ───
const COLOR_LIGHT = Color("#EEEED2")  # Creamy white
const COLOR_DARK = Color("#769656")   # Classic green
const COLOR_HIGHLIGHT = Color.YELLOW
const COLOR_VALID_MOVE = Color(0.3, 0.8, 0.3, 0.5)  # Semi-transparent green
const COLOR_SELECTED = Color(0.9, 0.7, 0.2, 0.6)    # Golden

func _ready():
	_create_board()
	_spawn_pieces()
	_setup_camera()
	_draw_board_border()

func _setup_camera():
	camera = Camera2D.new()
	camera.name = "Camera2D"
	add_child(camera)
	camera.make_current()
	
	var board_size = BOARD_SIZE * TILE_SIZE
	camera.global_position = Vector2(board_size / 2.0, board_size / 2.0)
	
	update_camera_zoom()
	get_tree().root.size_changed.connect(_on_viewport_resized)

func _on_viewport_resized():
	await get_tree().create_timer(0.05).timeout
	update_camera_zoom()

func update_camera_zoom():
	var board_size = BOARD_SIZE * TILE_SIZE
	var viewport_size = get_viewport().get_visible_rect().size
	
	var zoom_x = viewport_size.x / board_size
	var zoom_y = viewport_size.y / board_size
	var zoom = min(zoom_x, zoom_y) * 0.92  # Slightly more padding
	
	camera.zoom = Vector2(zoom, zoom)

func _create_board():
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			var square = SquareScene.instantiate()
			
			# Position at TOP-LEFT of tile (not centered)
			# This assumes your Square scene has its origin at top-left
			square.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			square.board_pos = Vector2i(x, y)
			square.z_index = Z_SQUARES
			square.z_as_relative = false
			
			# Classic chess coloring: a1 is dark
			var is_light = (x + y) % 2 == 0
			square.base_color = COLOR_LIGHT if is_light else COLOR_DARK
			
			# IMPORTANT: Make sure square size matches TILE_SIZE exactly
			# If your Square uses ColorRect, set its size to TILE_SIZE x TILE_SIZE
			# If it uses Sprite2D, scale it so the texture fills TILE_SIZE
			
			if square.has_signal("square_clicked"):
				square.square_clicked.connect(_on_square_clicked)
			
			add_child(square)
			squares[Vector2i(x, y)] = square

func _draw_board_border():
	# Draw a subtle border around the entire board
	var border = Line2D.new()
	border.width = 3
	border.default_color = Color("#4A4A4A")
	
	var board_px = BOARD_SIZE * TILE_SIZE
	var points = [
		Vector2(-2, -2),
		Vector2(board_px + 2, -2),
		Vector2(board_px + 2, board_px + 2),
		Vector2(-2, board_px + 2),
		Vector2(-2, -2)
	]
	border.points = points
	border.z_index = -1
	add_child(border)
	
	# Optional: Add a subtle shadow
	var shadow = Polygon2D.new()
	shadow.color = Color(0, 0, 0, 0.15)
	shadow.polygon = [
		Vector2(4, board_px + 4),
		Vector2(board_px + 6, board_px + 4),
		Vector2(board_px + 8, board_px + 8),
		Vector2(6, board_px + 8)
	]
	shadow.z_index = -2
	add_child(shadow)

func _clear_highlights():
	for sq in highlighted_squares:
		if is_instance_valid(sq):
			sq.set_highlight(false)
			# Reset to base color
			var pos = sq.board_pos
			var is_light = (pos.x + pos.y) % 2 == 0
			sq.modulate = Color.WHITE
			sq.base_color = COLOR_LIGHT if is_light else COLOR_DARK
	highlighted_squares.clear()

func _get_square_at(pos: Vector2i) -> Node:
	return squares.get(pos, null)

func _get_piece_at(pos: Vector2i) -> Node:
	return pieces.get(pos, null)

func _spawn_pieces():
	# White pieces (rows 6-7, bottom of board)
	for x in range(8):
		_create_piece("pawn", "white", Vector2i(x, 6))
	
	_create_piece("rook",   "white", Vector2i(0, 7))
	_create_piece("knight", "white", Vector2i(1, 7))
	_create_piece("bishop", "white", Vector2i(2, 7))
	_create_piece("queen",  "white", Vector2i(3, 7))
	_create_piece("king",   "white", Vector2i(4, 7))
	_create_piece("bishop", "white", Vector2i(5, 7))
	_create_piece("knight", "white", Vector2i(6, 7))
	_create_piece("rook",   "white", Vector2i(7, 7))
	
	# Black pieces (rows 0-1, top of board)
	for x in range(8):
		_create_piece("pawn", "black", Vector2i(x, 1))
	
	_create_piece("rook",   "black", Vector2i(0, 0))
	_create_piece("knight", "black", Vector2i(1, 0))
	_create_piece("bishop", "black", Vector2i(2, 0))
	_create_piece("queen",  "black", Vector2i(3, 0))
	_create_piece("king",   "black", Vector2i(4, 0))
	_create_piece("bishop", "black", Vector2i(5, 0))
	_create_piece("knight", "black", Vector2i(6, 0))
	_create_piece("rook",   "black", Vector2i(7, 0))

func _create_piece(type: String, color: String, pos: Vector2i):
	var piece = PieceScene.instantiate()
	piece.piece_type = type
	piece.piece_color = color
	
	# ─── FIX: Bigger pieces ───
	# Adjust based on your Piece scene's original size
	# If your piece texture is ~100x100, scale 0.45 fills the tile nicely
	piece.scale = Vector2(0.45, 0.45)
	
	piece.z_index = Z_PIECES
	piece.z_as_relative = false
	
	# Center piece on the tile
	piece.position = Vector2(
		pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		pos.y * TILE_SIZE + TILE_SIZE / 2.0
	)
	
	pieces[pos] = piece
	piece.set_meta("board_pos", pos)
	
	add_child(piece)

func _move_piece(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var piece = pieces.get(from_pos)
	if piece == null:
		return false
	
	var target = pieces.get(to_pos)
	if target != null:
		target.queue_free()
		pieces.erase(to_pos)
	
	pieces.erase(from_pos)
	pieces[to_pos] = piece
	piece.set_meta("board_pos", to_pos)
	
	var target_pos = Vector2(
		to_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		to_pos.y * TILE_SIZE + TILE_SIZE / 2.0
	)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(piece, "position", target_pos, 0.2)
	
	return true

func _on_square_clicked(pos: Vector2i):
	print("Clicked:", pos)
	
	var clicked_piece = _get_piece_at(pos)
	
	# Deselect if clicking same piece
	if selected_piece != null and clicked_piece == selected_piece:
		_clear_highlights()
		selected_piece = null
		return
	
	# Move to empty square
	if selected_piece != null and clicked_piece == null:
		var from_pos = selected_piece.get_meta("board_pos")
		_move_piece(from_pos, pos)
		_clear_highlights()
		selected_piece = null
		return
	
	# Capture enemy piece
	if selected_piece != null and clicked_piece != null:
		if clicked_piece.piece_color != selected_piece.piece_color:
			var from_pos = selected_piece.get_meta("board_pos")
			_move_piece(from_pos, pos)
		_clear_highlights()
		selected_piece = null
		return
	
	# Select a piece
	if clicked_piece != null:
		_clear_highlights()
		selected_piece = clicked_piece
		
		var sq = _get_square_at(pos)
		if sq:
			sq.modulate = COLOR_SELECTED
			highlighted_squares.append(sq)
		
		_highlight_valid_moves(pos)
	else:
		_clear_highlights()
		selected_piece = null

func _highlight_valid_moves(pos: Vector2i):
	var piece = _get_piece_at(pos)
	if piece == null:
		return
	
	# TODO: Implement real chess move logic
	# For now, highlight adjacent squares as placeholder
	var directions = [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1)
	]
	
	for dir in directions:
		var check_pos = pos + dir
		if check_pos.x >= 0 and check_pos.x < BOARD_SIZE and \
		   check_pos.y >= 0 and check_pos.y < BOARD_SIZE:
			var sq = _get_square_at(check_pos)
			if sq:
				sq.modulate = COLOR_VALID_MOVE
				highlighted_squares.append(sq)
