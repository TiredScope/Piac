@tool
class_name RadarChart
extends Control

@export var values: Array[float] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]:
	set(value):
		values = value
		queue_redraw()

@export var icons: Array[Texture2D] = [preload("res://icon.svg")]

@export var min_value: float = 0
@export var max_value: float = NAN
@export var filled_color: Color = Color.LIME_GREEN
@export var outline_color: Color = Color.WHITE
@export var icon_offset: int = 8
@export var icon_size: Vector2 = Vector2(32, 32)

func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if len(values) < 3:
		return

	var icon_radius: float = max(icon_size.x, icon_size.y) / 2 # Technically more correct, but looks worse in practice: icon_size.length() / 2
	var radius: float = min((size.x - icon_offset - icon_radius * 2) / 2, size.y / 2 - icon_offset - icon_radius * 2)
	var offset: Vector2 = size / 2
	var angle_per_element: float = 2 * PI / len(values)

	var local_min: float = values.min()
	var local_max: float = values.max()

	if not is_nan(min_value):
		local_min = min_value

	if not is_nan(max_value):
		local_max = max_value

	var points: Array[Vector2] = []
	var outline_points: Array[Vector2] = []
	for i: int in range(len(values)):
		var v: float = values[i]
		var angle: float = i * angle_per_element - PI / 2
		var norm_value: float = 0.0 if local_max == local_min else clampf((v - local_min) / (local_max - local_min), 0, 1)
		var pos_vec: Vector2 = Vector2.RIGHT.rotated(angle)
		var point_pos: Vector2 = pos_vec * radius
		points.push_back((point_pos * norm_value) + offset)
		outline_points.push_back(point_pos + offset)

		if i < len(icons) and icons[i] != null:
			var icon_pos: Vector2 = pos_vec * (radius + icon_radius + icon_offset) + offset
			var rect: Rect2 = Rect2(
				icon_pos - icon_size / 2.0,
				icon_size
			)
			draw_texture_rect(icons[i], rect, false)

	outline_points.push_back(outline_points[0])

	draw_polygon(points, [filled_color])
	draw_polyline(outline_points, outline_color, 1)
