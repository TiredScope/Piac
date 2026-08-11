class_name Inventory
extends GridContainer

const INVENTORY_SIZE: int = 9

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i: int in range(INVENTORY_SIZE):
		var item: Item = get_children()[i] as Item
		item.item_data = null

	for i: int in range(min(INVENTORY_SIZE, len(PVPConstants.ITEMS.items))):
		var item: Item = get_children()[i] as Item
		item.item_data = PVPConstants.ITEMS.items[i]
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_selected(index: int, selected: bool) -> void:
	if index < 0 or index >= INVENTORY_SIZE:
		return

	var item: Item = get_children()[index] as Item
	item.selected = selected

func highlight_item(index: int) -> void:
	if index != -1 and (index < 0 or index >= INVENTORY_SIZE):
		return

	for child: Item in get_items():
		child.highlighted = false

	if index != -1:
		var item: Item = get_item(index)
		item.highlighted = true

func get_selected_items() -> Array[int]:
	var result: Array[int] = []
	for i: int in range(INVENTORY_SIZE):
		var item: Item = get_item(i)
		if item.selected:
			result.push_back(i)

	return result

func get_highlighted_item() -> int:
	for i: int in range(INVENTORY_SIZE):
		var item: Item = get_item(i)
		if item.highlighted:
			return i

	return -1

func get_items() -> Array[Item]:
	var items: Array[Item] = []
	for n: Node in  get_children():
		if not n is Item:
			continue

		items.append(n as Item)
	return items

func get_item(slot: int) -> Item:
	var items: Array[Item] = get_items()

	if slot < 0 or slot >= len(items):
		return null

	return items[slot]
