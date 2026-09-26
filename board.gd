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
var current_turn: String = "white"

const Z_SQUARES = 0
const Z_PIECES = 10

const COLOR_LIGHT = Color("#EEEED2")
const COLOR_DARK = Color("#769656")
const COLOR_VALID_MOVE = Color(0.3, 0.8, 0.3, 0.6)
const COLOR_SELECTED = Color(1.0, 0.8, 0.0, 0.7)

func _ready():
	_create_board()
	_spawn_pieces()
	_setup_camera()

# ================= مهم‌ترین تغییر: کلیک اینجا مدیریت می‌شود =================
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		var pos = _pixel_to_board(get_global_mouse_position())
		if pos != Vector2i(-1, -1):
			_on_square_clicked(pos)
			get_viewport().set_input_as_handled()

func _pixel_to_board(world_pos: Vector2) -> Vector2i:
	var x = int(floor(world_pos.x / TILE_SIZE))
	var y = int(floor(world_pos.y / TILE_SIZE))
	if x < 0 or x >= BOARD_SIZE or y < 0 or y >= BOARD_SIZE:
		return Vector2i(-1, -1)
	return Vector2i(x, y)
# ============================================================================

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
	var zoom = min(zoom_x, zoom_y) * 0.92
	camera.zoom = Vector2(zoom, zoom)

func _create_board():
	for y in range(BOARD_SIZE):
		for x in range(BOARD_SIZE):
			var square = SquareScene.instantiate()
			square.position = Vector2(x * TILE_SIZE, y * TILE_SIZE)
			square.board_pos = Vector2i(x, y)
			square.z_index = Z_SQUARES
			square.z_as_relative = false
			var is_light = (x + y) % 2 == 0
			square.base_color = COLOR_LIGHT if is_light else COLOR_DARK
			# اتصال سیگنال حذف شد — کلیک‌ها حالا در _input مدیریت می‌شوند
			add_child(square)
			squares[Vector2i(x, y)] = square

func _clear_highlights():
	for sq in highlighted_squares:
		if is_instance_valid(sq):
			if sq.has_method("set_highlight"):
				sq.set_highlight(false)
			sq.modulate = Color.WHITE  # ریست تینتِ رنگ
	highlighted_squares.clear()

func _get_square_at(pos: Vector2i) -> Node:
	return squares.get(pos, null)

func _get_piece_at(pos: Vector2i) -> Node:
	return pieces.get(pos, null)

func _spawn_pieces():
	for x in range(8):
		_create_piece("pawn", "white", Vector2i(x, 6))
	_create_piece("rook", "white", Vector2i(0, 7))
	_create_piece("knight", "white", Vector2i(1, 7))
	_create_piece("bishop", "white", Vector2i(2, 7))
	_create_piece("queen", "white", Vector2i(3, 7))
	_create_piece("king", "white", Vector2i(4, 7))
	_create_piece("bishop", "white", Vector2i(5, 7))
	_create_piece("knight", "white", Vector2i(6, 7))
	_create_piece("rook", "white", Vector2i(7, 7))
	
	for x in range(8):
		_create_piece("pawn", "black", Vector2i(x, 1))
	_create_piece("rook", "black", Vector2i(0, 0))
	_create_piece("knight", "black", Vector2i(1, 0))
	_create_piece("bishop", "black", Vector2i(2, 0))
	_create_piece("queen", "black", Vector2i(3, 0))
	_create_piece("king", "black", Vector2i(4, 0))
	_create_piece("bishop", "black", Vector2i(5, 0))
	_create_piece("knight", "black", Vector2i(6, 0))
	_create_piece("rook", "black", Vector2i(7, 0))

func _create_piece(type: String, color: String, pos: Vector2i):
	var piece = PieceScene.instantiate()
	piece.piece_type = type
	piece.piece_color = color
	piece.scale = Vector2(0.45, 0.45)
	piece.z_index = Z_PIECES
	piece.z_as_relative = false
	# جلوگیری از بلعیدن کلیک‌ها توسط مهره‌ها
	if piece is CollisionObject2D:
		piece.input_pickable = false
	piece.position = Vector2(
		pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		pos.y * TILE_SIZE + TILE_SIZE / 2.0
	)
	pieces[pos] = piece
	piece.set_meta("board_pos", pos)
	piece.set_meta("has_moved", false)
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
	piece.set_meta("has_moved", true)
	
	var target_pos = Vector2(
		to_pos.x * TILE_SIZE + TILE_SIZE / 2.0,
		to_pos.y * TILE_SIZE + TILE_SIZE / 2.0
	)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(piece, "position", target_pos, 0.2)
	
	current_turn = "black" if current_turn == "white" else "white"
	print("Turn changed to:", current_turn)
	return true

func _on_square_clicked(pos: Vector2i):
	print("Clicked:", pos, "Turn:", current_turn)
	var clicked_piece = _get_piece_at(pos)
	
	if selected_piece != null:
		var from_pos = selected_piece.get_meta("board_pos")
		var valid_moves = _get_valid_moves(from_pos)
		
		if pos in valid_moves:
			_move_piece(from_pos, pos)
			_clear_highlights()
			selected_piece = null
			return
		else:
			_clear_highlights()
			selected_piece = null
	
	if clicked_piece != null and clicked_piece.piece_color == current_turn:
		_clear_highlights()
		selected_piece = clicked_piece
		var sq = _get_square_at(pos)
		if sq:
			sq.modulate = COLOR_SELECTED
			highlighted_squares.append(sq)
		_highlight_valid_moves(pos)
		return
	
	_clear_highlights()
	selected_piece = null

func _highlight_valid_moves(pos: Vector2i):
	var piece = _get_piece_at(pos)
	if piece == null:
		return
	var valid_moves = _get_valid_moves(pos)
	for move_pos in valid_moves:
		var sq = _get_square_at(move_pos)
		if sq:
			sq.modulate = COLOR_VALID_MOVE
			highlighted_squares.append(sq)

func _get_valid_moves(pos: Vector2i) -> Array[Vector2i]:
	var piece = _get_piece_at(pos)
	if piece == null:
		return []
	var color = piece.piece_color
	var type = piece.piece_type
	match type:
		"pawn":   return _get_pawn_moves(pos, color)
		"rook":   return _get_sliding_moves(pos, color, [[1,0],[-1,0],[0,1],[0,-1]])
		"knight": return _get_knight_moves(pos, color)
		"bishop": return _get_sliding_moves(pos, color, [[1,1],[1,-1],[-1,1],[-1,-1]])
		"queen":  return _get_sliding_moves(pos, color, [[1,0],[-1,0],[0,1],[0,-1],[1,1],[1,-1],[-1,1],[-1,-1]])
		"king":   return _get_king_moves(pos, color)
	return []

func _is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < BOARD_SIZE and pos.y >= 0 and pos.y < BOARD_SIZE

func _can_move_to(pos: Vector2i, color: String) -> bool:
	if not _is_in_bounds(pos):
		return false
	var target = _get_piece_at(pos)
	return target == null or target.piece_color != color

func _get_pawn_moves(pos: Vector2i, color: String) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	var direction = -1 if color == "white" else 1
	var piece = pieces.get(pos)
	var has_moved = piece.get_meta("has_moved", false) if piece else false
	
	var forward = pos + Vector2i(0, direction)
	if _is_in_bounds(forward) and _get_piece_at(forward) == null:
		moves.append(forward)
		if not has_moved:
			var double = pos + Vector2i(0, direction * 2)
			if _is_in_bounds(double) and _get_piece_at(double) == null:
				moves.append(double)
	
	for dx in [-1, 1]:
		var diag = pos + Vector2i(dx, direction)
		if _is_in_bounds(diag):
			var target = _get_piece_at(diag)
			if target != null and target.piece_color != color:
				moves.append(diag)
	return moves

func _get_knight_moves(pos: Vector2i, color: String) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	for offset in [Vector2i(2,1),Vector2i(2,-1),Vector2i(-2,1),Vector2i(-2,-1),
				   Vector2i(1,2),Vector2i(1,-2),Vector2i(-1,2),Vector2i(-1,-2)]:
		var new_pos = pos + offset
		if _can_move_to(new_pos, color):
			moves.append(new_pos)
	return moves

func _get_king_moves(pos: Vector2i, color: String) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var new_pos = pos + Vector2i(dx, dy)
			if _can_move_to(new_pos, color):
				moves.append(new_pos)
	return moves

func _get_sliding_moves(pos: Vector2i, color: String, directions: Array) -> Array[Vector2i]:
	var moves: Array[Vector2i] = []
	for dir in directions:
		var current = pos + Vector2i(dir[0], dir[1])
		while _is_in_bounds(current):
			var target = _get_piece_at(current)
			if target == null:
				moves.append(current)
			elif target.piece_color != color:
				moves.append(current)
				break
			else:
				break
			current += Vector2i(dir[0], dir[1])
	return moves
