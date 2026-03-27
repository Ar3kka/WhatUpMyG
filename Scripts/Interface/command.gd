class_name Command extends RefCounted

var global := GeneralKnowledge.new()

var active : bool = true
var main_command : Command
var cmd_name : String
var full_name : PackedStringArray :
	get() :
		if !main_command : return [cmd_name]
		var _main : Command = self
		var final_name : PackedStringArray = []
		var loop : bool = true
		var count : int = 0
		while loop :
			if !_main.main_command || count >= 100 : loop = false
			final_name.insert(0, _main.cmd_name)
			_main = _main.main_command
			count += 1
		return final_name
var triggers : PackedStringArray :
	get() :
		var lower_case_triggers : PackedStringArray = []
		for trigger in triggers :
			lower_case_triggers.append(trigger.to_lower())
		return lower_case_triggers
var sub_triggers : PackedStringArray :
	get() :
		var final_array : PackedStringArray = []
		for sub in sub_commands :
			final_array.append_array(sub.triggers)
		return final_array
var info : String
var actions : Array[Callable]
var index : int = -1
var subcommand_index : int :
	get() : return index - 1 if index >= 0 else -1 
var private : bool = false
var needs_privileges : bool = false
var only_visible_with_privileges : bool = true 
var expected_arguments : int = 0
var pass_command_as_argument : bool = false
var decode_to_int : bool = true
var sub_commands : Array[Command]
var output_history : Array = []

func _init(
	_cmd_name : String,
	_triggers : PackedStringArray,
	_info : String = "NO INFO PROVIDED",
	_expected_arguments : int = 0,
	_private : bool = false,
	_needs_privileges : bool = false,
	_only_visible_with_privileges : bool = false,
	_actions : Array[Callable] = [func () : print(cmd_name, ": NO ACTION SET TO CALL")],
	_sub_commands : Array[Command] = []
) -> void :
	cmd_name = _cmd_name
	triggers = _triggers
	info = _info
	expected_arguments = _expected_arguments
	private = _private
	needs_privileges = _needs_privileges
	only_visible_with_privileges = _only_visible_with_privileges
	actions = _actions
	sub_commands = _sub_commands
	_set_sub_commands()

func decode(input : PackedStringArray, from : int = 0, to_int : bool = decode_to_int) -> Array :
	var _index : int = find_trigger(input, from)
	if _index == -1 : return []
	
	var final_result : Array = [input[_index]]
	if expected_arguments < 1 : return final_result
	
	for i in expected_arguments :
		var _sub_index : int = _index + (i + 1)
		if _sub_index <= input.size() - 1 : 
			var argument = input[_sub_index]
			final_result.append(argument.to_int() if argument.is_valid_int() && to_int else argument)
	return final_result

func find_trigger(input : PackedStringArray, from : int = 0) -> int :
	var _index : int = -1
	for trigger in triggers :
		_index = input.find(trigger, from)
		index = _index
		if index != -1 : return _index
		# Check if it's an already executed command, 
		#if it is, return as if it's not found (-1)
		"""if _index == -1 : continue
		for cmd in message.command_history : 
			if cmd.triggers.find(trigger) == -1 : continue 
			#Check if there's a repeated command after the one executed, 
			#if it is, show the error to let the user know there's a duplicate command.
			if cmd_name == "NAME" : print("DNA:", _index)
			_index = -1
			if ( cmd.index + 1 > input.size() - 1 
			|| input.slice(cmd.index + 1).find(trigger) == -1 ) : continue
			message.error.append("%s \"%s\" WHEN EXECUTING COMMAND [%s]" % [global._ERROR_DUPLICATE_COMMAND, trigger, cmd_name])
		return _index """
	return _index

func run_specific(message : Message, action : Callable, run_subcommands : bool = true, add : bool = false) -> Variant :
	if !active : print("current command with name [%s] is not active" % cmd_name) ; return
	if !message.is_command && message.error.find(global._ERROR_COMMAND) == -1 : message.error.append(global._ERROR_COMMAND) ; return
	
	var decoded_input : Array = decode(message.full_command_input)
	if decoded_input.is_empty() : return #print("[%s] no triggers: %s found" % [cmd_name, triggers]) ; return
	
	if needs_privileges && !message.moderated && message.error.find(global._ERROR_PRIVILEGE % decoded_input[0]) == -1 : 
		message.error.append(global._ERROR_PRIVILEGE % decoded_input[0]) ; return

	if add && !actions.has(action) : actions.append(action)
	
	var decoded_subcommands : Array = []
	var sub_output : Array = []
	if run_subcommands :
		for sub in sub_commands :
			decoded_subcommands.append(sub.decode(message.subcommands_input))
			sub_output.append_array(sub.run(message))
		decoded_input = decoded_input
		decoded_input.append_array(decoded_subcommands)
	
	var output
	match action.get_argument_count() :
		0 : output = action.call()
		1 : output = action.call(message)
		2 : output = action.call(message, decoded_input)
		3 : output = action.call(message, decoded_input, sub_output)
		4 : output = action.call(message, decoded_input, sub_output, self)
	
	if !output :
		if needs_privileges && message.moderated : return true 
		return
	
	message.command_history[message.command_history.size()] = [cmd_name, [decoded_input], [output], self]
	output_history.append([output, sub_output])
	
	return output

func run_at(message : Message, _index = 0) -> Variant :
	if actions.is_empty() : print("NO ACTIONS SET FOR THIS COMMAND") ; return
	
	if _index > actions.size() - 1 : _index = actions.size() - 1
	elif _index < 0 : _index = 0
	
	return run_specific(message, actions[_index])

func run(message : Message) -> Array : 
	var output : Array = []
	var input_index : int = 0
	for action in actions :
		var current_output = run_specific(message, action)
		if current_output : output.append(current_output)
	return output

func run_subcommand(message : Message, trigger : String) -> Array :
	var subcommand : Command = get_subcommand(trigger)
	if !subcommand : return []
	return subcommand.run(message)

func get_subcommand(trigger : String) -> Command :
	for command in sub_commands :
		if command.triggers.has(trigger) :
			return command 
	return

func run_subcommand_by_name(message : Message, sub_name : String) -> Array :
	var subcommand : Command = get_subcommand_by_name(sub_name)
	if !subcommand : return []
	return subcommand.run(message)

func get_subcommand_by_name(sub_name : String) -> Command :
	for sub in sub_commands : if sub.cmd_name == sub_name : return sub 
	return

func _set_sub_commands() :
	for sub_command in sub_commands :
		if sub_command is Command : sub_command.main_command = self 

func is_main_command() -> bool :
	return has_subcommands() && !is_subcommand()

func is_subcommand() -> bool :
	if main_command : return true
	return false
	
func has_subcommands() -> bool :
	return !sub_commands.is_empty()
