extends MenuButton
func _ready() -> void:
	#get_popup().menu_changed.connect(test_func)
	get_popup().index_pressed.connect(select_item)
	
#func _process(delta: float) -> void:
	#var focused = get_popup().get_focused_item()
	#if focused >= 0:
	#get_popup().activate_item_by_event()

func select_item(id) -> void:
	print("resolution changing!")
	get_popup().set_item_checked(id, true)
	text = get_popup().get_item_text(id)
	print(id)
