class_name Mouth extends LineEdit

@export var manipulator : Manipulator
@export var privileges : bool :
	set(new_value) :
		if !manipulator : return
		manipulator.moderator = new_value
	get() :
		if manipulator : return manipulator.moderator
		return false
@export var background : ColorRect
@export var output : RichTextLabel
var message_history : Array[Message] = [] 
var _current_prompt_index : int = -1
var board : Board :
	get() :
		if manipulator == null : return
		return manipulator.current_board
var god : God :
	get() :
		if board == null : return
		return board.god
	
func _ready() -> void:
	if manipulator == null : manipulator = get_parent()
	_find_children()
	visible = false

func send_message(message_text : String, console : God = god):
	var new_message := Message.new()
	new_message.sender = self
	new_message.input_text = message_text
	new_message.sent = true
	if !message_text.is_empty() : message_history.append(new_message)
	if console : console.prompt(new_message)

func _input(event : InputEvent) -> void:
	if event is InputEventKey and event.pressed and !message_history.is_empty() :
		if _current_prompt_index == -1 : _current_prompt_index = message_history.size() - 1
		if event.keycode == KEY_UP :
			_current_prompt_index -= 1
			if _current_prompt_index < 0 : _current_prompt_index = 0 
			text = message_history[_current_prompt_index].input_text
		else : if event.keycode == KEY_DOWN :
			_current_prompt_index += 1
			if _current_prompt_index > message_history.size() - 1 : _current_prompt_index = message_history.size() - 1
			text = message_history[_current_prompt_index].input_text
		else : if event.keycode == KEY_ESCAPE : focus(false)

func _on_text_submitted(_input_text : String) -> void :
	send_message(_input_text)

func _find_children() :
	for child in get_children() :
		if child is ColorRect : background = child
		if child is RichTextLabel : output = child

func focus(visibility : bool = true) :
	visible = visibility
	if visible : grab_focus()
	else : release_focus()
