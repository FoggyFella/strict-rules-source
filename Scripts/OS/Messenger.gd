extends Panel

@onready var other_screens = get_parent().get_children()
var drag_position = null

func _ready():
	self.pivot_offset = Vector2(self.size.x/2,self.size.y/2)
	self.scale = Vector2(0,0)
	self.show()
	if !get_parent().visible:
		get_parent().show()
	var close_button = get_node("TopPart/Close")
	close_button.pressed.connect(on_closed)
	gui_input.connect(on_gui_input)
	for message in $Messages.get_children():
		message.hide()

func open():
	for child in other_screens:
		child.z_index = 0
	self.z_index = 1
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"scale",Vector2(1,1),0.2)

func on_closed():
	close()

func close():
	self.z_index = 0
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self,"scale",Vector2(0,0),0.2)

func on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drag_position = get_global_mouse_position() - global_position
			for child in other_screens:
				child.z_index = 0
			z_index = 1
		else:
			drag_position = null
	if event is InputEventMouseMotion and drag_position:
		self.global_position = get_global_mouse_position() - drag_position

func add_contact(name,image):
	pass

func add_message(contact,message):
	pass

func add_history(contact,text):
	pass

func display_messages_from(contact):
	for message in $Messages.get_children():
		message.hide()
	$Messages.get_node(contact).show()


func _on_contacts_pressed():
	$Panel/History.hide()
	$Panel/Contacts.show()

func _on_history_pressed():
	$Panel/Contacts.hide()
	for message in $Messages.get_children():
		message.hide()
	$Panel/History.show()
