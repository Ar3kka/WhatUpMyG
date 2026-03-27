class_name Message extends Node3D

var god : God
var sender : Mouth
var sender_body : Manipulator :
	get() :
		if sender : return sender.manipulator
		return
var username : String :
	get() :
		if sender_body == null : return "[NULL]"
		return "[" + sender_body.username + "]"
var receiver : Mouth
var input_text : String = ""
var input_line : PackedStringArray :
	get() : return input_text.to_lower().split(" ")

var sent : bool = false :
	set(new_value) :
		sent = new_value
		if sent : date = Time.get_datetime_dict_from_system()
var private : bool = false
var only_mods : bool = false
var moderated : bool :
	get() : 
		if sender : return sender.privileges
		return false
var connected : bool = false
var connect_separator : String = ""

var time : String :
	get() :
		if !sent : return ""
		var final_hour : String = str(date.hour) if date.hour >= 10 else "0" + str(date.hour)
		var final_minutes : String = str(date.minute) if date.minute >= 10 else "0" + str(date.minute)
		return final_hour + ":" + final_minutes
var date := {}
var command_trigger : String :
	get() :
		if god : return god.command_trigger
		return GeneralKnowledge.new().DEFAULT_COMMAND_TRIGGER
var is_command : bool :
	get() :
		if input_line.size() >= 1 : return input_line[0].find(command_trigger, 0) == 0
		return false
var full_command_input : PackedStringArray :
	get() :
		if is_command :
			var line : PackedStringArray = [command_input]
			line.append_array(subcommands_input)
			return line
		return []
var command_input : String :
	get() :
		if is_command : return input_line[0].substr(1)
		return ""
var has_subcommands : bool :
	get() : return is_command && input_line.size() > 1
var subcommands_input : PackedStringArray :
	get() :
		if has_subcommands : return input_line.slice(1)
		return []
var command_processed : bool :
	get() : return god && is_command && !output.is_empty()

var command_history : Dictionary = {}

var output : PackedStringArray = [] :
	get() :
		if !connected || output.is_empty() : return output
		return [connect_separator.join(output)]
var error : PackedStringArray = [] :
	get() :
		if !connected || error.is_empty() : return error
		return [connect_separator.join(error)]
var system : PackedStringArray = [] :
	get() :
		if !connected || system.is_empty() : return system
		return [connect_separator.join(system)]

var all_output : PackedStringArray :
	get() : return output + error + system
