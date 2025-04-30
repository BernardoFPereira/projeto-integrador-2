extends MenuButton

func _ready() -> void:
	var window_size = get_window().size
	print(window_size)
	#get_popup().menu_changed.connect(test_func)
	get_popup().index_pressed.connect(select_item)
	

func select_item(id) -> void:
	print("resolution changing!")
	for idx in (get_popup().item_count):
		get_popup().set_item_checked(idx, false)
		pass
	get_popup().set_item_checked(id, true)
	text = get_popup().get_item_text(id)
	change_window_size(text)

func change_window_size(size: String) -> void:
	var split_size = size.split(" x ")
	var window_x = int(split_size[0])
	var window_y = int(split_size[1])
	
	get_window().size = Vector2i(window_x, window_y)

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")
