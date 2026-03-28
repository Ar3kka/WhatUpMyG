class_name God extends Node3D

var SPAWN_QUANTITY_SUBCOMMAND := Command.new(
	"QUANTITY",
	["q", "quantity"],
	"SPECIFY THE TIMES THE PIECE WILL SPAWN",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var SPAWN_NAME_SUBCOMMAND := Command.new(
	"NAME",
	["n", "name"],
	"SPECIFY THE PIECE TO SPAWN USING ITS NAME",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var SPAWN_TEAM_SUBCOMMAND := Command.new(
	"TEAM",
	["t", "team"],
	"SPECIFY THE TEAM FOR THE PIECE TO SPAWN (NAME or ID)",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var SPAWN_COORDS_SUBCOMMAND := Command.new(
	"COORDINATES",
	["c", "coords", "at", "coordinates"],
	"SPECIFY COORDINATES OF THE PIECE TO SPAWN (VERTICAL, HORITONTAL, \"F\" TO FORCE AND REPLACE)",
	3, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[spawn_coords_prompt],
)
var SPAWN_HEALTH_SUBCOMMAND := Command.new(
	"HEALTH",
	["h", "health"],
	"SPECIFY THE HEALTH OF THE PIECE TO SPAWN",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var SPAWN_COMMAND := Command.new(
	"SPAWN",
	["spawn", "s"],
	"SPAWN A QUANTITY OF PIECES WITH THE GIVEN TEAM, NAME, COORDINATES OR HEALTH",
	0, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[spawn_prompt],
	[SPAWN_QUANTITY_SUBCOMMAND, SPAWN_NAME_SUBCOMMAND, SPAWN_TEAM_SUBCOMMAND, SPAWN_COORDS_SUBCOMMAND, SPAWN_HEALTH_SUBCOMMAND]
)

var RESTART_COMMAND := Command.new(
	"RESTART",
	["reload", "reset", "restart"],
	"RELOAD CURRENT LEVEL",
	0, #ARGUMENTS
	false, #PRIVATE
	false, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[restart_prompt],
)

var PASS_FORCE_SUBCOMMAND := Command.new(
	"FORCE",
	["f", "force"],
	"FORCE PASS THE CURRENT TURN",
	0, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var PASS_COMMAND := Command.new(
	"PASS",
	["pass", "p"],
	"PASS YOUR CURRENT TURN IF IN THE TURN'S TEAM",
	0, #ARGUMENTS
	false, #PRIVATE
	false, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[pass_prompt],
	[PASS_FORCE_SUBCOMMAND]
)

var TEAM_INFO_SUBCOMMAND := Command.new(
	"INFO",
	["i", "info"],
	"SHOW INFORMATION OF GIVEN TEAM (NAME or ID)",
	1, #ARGUMENTS
	false, #PRIVATE
	false, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var TEAM_CHANGE_SUBCOMMAND := Command.new(
	"CHANGE",
	["c", "change"],
	"CHANGE YOUR CURRENT TEAM TO THE GIVEN (NAME or ID)",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[team_change_prompt]
)
var TEAM_ACTIONS_SUBCOMMAND := Command.new(
	"ACTIONS",
	["a", "actions"],
	"CHANGE THE ACTIONS PER TURN OF THE GIVEN TEAM (ACTIONS, TEAM)",
	2, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[team_actions_prompt]
)
var TEAM_COMMAND := Command.new(
	"TEAM",
	["team", "t"],
	"GENERAL TEAM ACTIONS AND INFORMATION",
	0, #ARGUMENTS
	false, #PRIVATE
	false, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[team_prompt],
	[TEAM_INFO_SUBCOMMAND, TEAM_CHANGE_SUBCOMMAND, TEAM_ACTIONS_SUBCOMMAND]
)

var BOARD_ADD_ROW_SUBCOMMAND := Command.new(
	"ROWS",
	["r", "rows"],
	"NUMBER OF ROWS TO ADD, IF NOT GIVEN, ONE ROW IS ADDED",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var BOARD_ADD_TILES_SUBCOMMAND := Command.new(
	"TILES",
	["t", "tiles"],
	"NUMBER OF TILES TO ADD PER ROW, IF NOT GIVEN, THE BOARD'S HORIZONTAL SIZE IS TAKEN INSTEAD",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var BOARD_ADD_SUBCOMMAND := Command.new(
	"ADD",
	["a", "add"],
	"ADD A GIVEN NUMBER OF ROWS WITH A GIVEN NUMBER OF TILES TO YOUR CURRENT BOARD, 1 ROW WITH BOARD'S SIZE IF NO ARGUMENTS PROVIDED",
	2, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[board_add_prompt],
	[BOARD_ADD_ROW_SUBCOMMAND, BOARD_ADD_TILES_SUBCOMMAND]
)
var BOARD_RESET_SIZE_SUBCOMMAND := Command.new(
	"SIZE",
	["size"],
	"SET THE INITIAL DIMENSIONS FOR THE NEW BOARD (HORIZONTAL, VERTICAL)",
	2, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var BOARD_RESET_SET_SUBCOMMAND := Command.new(
	"SET",
	["set"],
	"SET THE INITIAL SET FOR THE NEW BOARD",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var BOARD_RESET_SEED_SUBCOMMAND := Command.new(
	"SEED",
	["seed"],
	"SET THE SEED FOR THE NEW BOARD",
	1, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
)
var BOARD_RESET_SUBCOMMAND := Command.new(
	"RESET",
	["r", "reset"],
	"RESET CURRENT BOARD WITH THE GIVEN THE DIMENSIONS, INITIAL SET AND SEED",
	0, #ARGUMENTS
	false, #PRIVATE
	true, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[board_reset_prompt],
	[BOARD_RESET_SEED_SUBCOMMAND, BOARD_RESET_SET_SUBCOMMAND, BOARD_RESET_SIZE_SUBCOMMAND]
)
var BOARD_COMMAND := Command.new(
	"BOARD",
	["board", "b"],
	"GENERAL BOARD ACTIONS AND INFORMATION \n*SHOWS INFORMATION OF CURRENT BOARD IF NO ARGUMENTS ARE GIVEN*",
	0, #ARGUMENTS
	false, #PRIVATE
	false, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[board_prompt],
	[BOARD_ADD_SUBCOMMAND, BOARD_RESET_SUBCOMMAND]
)

var SIZE_COMMAND := Command.new(
	"SIZE",
	["s", "size"],
	"SHOWS CURRENT'S BOARD SIZE",
	0, #ARGUMENTS
	false, #PRIVATE
	false, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[size_prompt]
)

var SEED_COMMAND := Command.new(
	"SEED",
	["seed"],
	"DISPLAYS THE CURRENT BOARD'S SEED",
	0, #ARGUMENTS
	false, #PRIVATE
	false, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[seed_prompt], )

var HELP_COMMAND := Command.new(
	"HELP",
	["help", "h"],
	"SHOWS ALL AVAILABLE COMMANDS, DETAILS OF WHAT THEY DO AND THEIR ARGUMENTS NEEDED",
	0, #ARGUMENTS
	false, #PRIVATE
	false, #PRIVILEGE
	true, #VISIBLE WITH PRIVILEGES
	[help_prompt] )

var MOD_COMMAND := Command.new(
	"MOD",
	["lakitiu", "qdubidu", "arekka", "anheru", "ksunset", "ksimerin", "lock", "zherson"],
	"THIS COMMAND WELCOMES YOU INTO THE PULGOSOS GANG",
	0, #ARGUMENTS
	true, #PRIVATE
	false, #PRIVILEGE
	false, #VISIBLE WITH PRIVILEGES
	[mod_prompt] )

var global := GeneralKnowledge.new()

@export var board : Board
var _board_to_restart_to : Board
@export var command_trigger : String = GeneralKnowledge.new().DEFAULT_COMMAND_TRIGGER
var prayers : Array[Mouth] :
	get() :
		var final_prayers : Array[Mouth] = []
		if board == null : return final_prayers
		for manipulator in board.manipulators :
			if manipulator.mouth : final_prayers.append(manipulator.mouth)
		return final_prayers

var miracle := RandomNumberGenerator.new()
var piece_dna : PieceDNA :
	get() :
		if board == null || board.grid == null : return
		return board.pieces_node.dna

var last_message : Message :
	get() :
		if !message_history.is_empty() : return message_history[message_history.size() - 1]
		return
var message_history : Array[Message]
var input_history : PackedStringArray = []

var grid : TileGrid :
	get() :
		if board == null : return
		return board.grid
var teams : TeamsHandler :
	get() :
		if board == null : return
		return board.teams_node
var womb : PieceGenerator :
	get() :
		if board == null : return
		return board.pieces_node
var turn_node : TurnHandler :
	get() :
		if board == null : return
		return board.turn_node

var command_map: Array[Command] = [
	SPAWN_COMMAND,
	RESTART_COMMAND,
	PASS_COMMAND,
	TEAM_COMMAND,
	BOARD_COMMAND,
	SIZE_COMMAND,
	SEED_COMMAND,
	HELP_COMMAND,
	MOD_COMMAND,
]

func _ready() -> void:
	if board == null : board = get_parent()

func clone_to(new_god : God) -> God :
	new_god.input_history.clear()
	new_god.input_history.append_array(input_history)
	new_god.message_history.clear()
	new_god.message_history.append_array(message_history)
	return new_god

func get_command(trigger : String) -> Command :
	for command in command_map :
		if command.triggers.has(trigger) :
			return command 
	return

func print_lines(lines : PackedStringArray, moderated : bool = false) :
	var _prayers : Array[Mouth] = prayers
	for prayer in _prayers :
		var output : RichTextLabel = prayer.output
		if output == null || ( moderated && !prayer.privileges ) : break
		for line in lines :
			prayer.output.append_text("%s\n" % line)
			print("SYSTEM: ", line)

func print_to(lines : PackedStringArray, receiver : Mouth) :
	if !receiver.output : return
	for line in lines :
		receiver.output.append_text("%s\n" % line)
		print("OUTPUT: ", line)

func print_message(message : Message = last_message) :
	var _prayers : Array[Mouth] = prayers
	if _prayers.is_empty() == null : return
	
	for prayer in _prayers :
		var output : RichTextLabel = prayer.output
		if output == null || message.all_output.is_empty() : message.error.append(global._ERROR_OUTPUT) ; break
		
		## PRINT OUTPUT
		for output_line in message.output :
			var final_output : String = ""
			final_output += "%s - %s: " % [message.time, message.username]
			# IF the message's input is not empty
			# AND ( the message is not private
			# OR it's private
			# AND the user is the sender or the receiver )
			if ( !message.input_text.is_empty() &&
			( !message.private ||
			( message.private &&
			( prayer == message.sender || prayer == message.receiver )))) :
				final_output += message.input_text
				if message.command_processed : final_output += " > %s" % output_line 
				output.append_text("%s\n" % final_output)
			print("OUTPUT: ", final_output)
		
		## PRINT SYSTEM
		for system_line in message.system :
			output.append_text("%s\n" % system_line)
			print("SYSTEM: ", system_line)
		
		## PRINT ERROR
		if prayer != message.sender : break
		for error_line in message.error :
			var final_error : String =  "%s > %s%s" % [message.input_text, global._ERROR, error_line]
			output.append_text("%s\n" % final_error)
			print("ERROR: ", final_error)

func prompt(message : Message, print_result : bool = true) -> Message :
	message.god = self
	var enter_in_history : bool = true
	
	if !message.sender : message.error.append(global._ERROR_SENDER) ; enter_in_history = false
	if message.input_text.is_empty() : message.error.append(global._ERROR_INPUT) 
	else : input_history.append(message.input_text)
	if message.private && !message.receiver && !message.is_command : message.error.append(global._ERROR_PRIVATE_RECEIVER)
	
	if message.is_command :
		var command : Command = get_command(message.command_input)
		if command :
			command.run(message)
			if message.all_output.is_empty(): 
				if message.has_subcommands : message.error.append(global._ERROR_RESULT)
				elif command.has_subcommands() : message.error.append(global._ERROR_ARGUMENTS)
		else : message.error.append(global._ERROR_COMMAND)
	else : message.output.append(message.input_text)
	
	if print_result : print_message(message)
	
	if enter_in_history : message_history.append(message)
	if _board_to_restart_to : board.replace(message.sender_body, _board_to_restart_to)
	return message

func spawn_coords_prompt( message : Message, decoded_input : Array = []) -> Array :
	var coordinates : Vector2i = grid.get_random_coordinates()
	if decoded_input.size() <= 1 : return [coordinates]
	
	var x : int = coordinates.x
	var random_x : bool = true
	var y : int = coordinates.y
	var random_y : bool = true
	
	if decoded_input.size() > 1 && decoded_input[1] is int : x = decoded_input[1] ; random_x = false
	if decoded_input.size() > 2 && decoded_input[2] is int : y = decoded_input[2] ; random_y = false
	var force_connect : bool = false
	if decoded_input.size() > 3 && decoded_input[3] is String && decoded_input[3] == "f" : force_connect = true
	if !random_x || !random_y :
		if random_x && !random_y : x = grid.get_random_x( y )
		else : if random_y && !random_x : y = grid.get_random_y( x )
	coordinates = Vector2i( x , y )
	
	return [coordinates, force_connect]
 
func spawn_prompt( message : Message, decoded_input : Array = [], sub_output : Array = [] ) -> Message :
	if board == null : message.error.append(global._ERROR_BOARD) ; return message
	
	var quantity : int = decoded_input[1][1] if decoded_input[1].size() > 1 && decoded_input[1][1] is int else 1
	
	for i in quantity :
		var dna : PackedScene = piece_dna.get_dna(decoded_input[2][1]) if decoded_input[2].size() > 1 && decoded_input[2][1] is String else piece_dna.get_random_dna()
		
		var team_id : int = decoded_input[3][1] if decoded_input[3].size() > 1 && decoded_input[3][1] is int else teams.get_random_team().id
		
		var coordinates : Vector2i = sub_output[3][0] if sub_output.size() > 2 && !sub_output[3].is_empty() else grid.get_random_coordinates()
		var force_connect : bool = sub_output[3][1] if sub_output.size() > 2 && sub_output[3].size() > 1 else false
		
		var generated_piece : Piece = womb.generate_piece(dna, team_id, coordinates, force_connect)
		
		var initial_health : int = decoded_input[5][1] if decoded_input[5].size() > 1 && decoded_input[5][1] is int else 1
		
		generated_piece.initial_health = initial_health
	
		womb.add_specific_piece( generated_piece, true )
		message.output.append("SPAWNED A %s, WITH %s HEALTH, IN TEAM %s, AT [ X:%s, Y:%s ]" % [piece_dna.get_dna_name(dna).to_upper(), str(initial_health), str(team_id), str(coordinates.x), str(coordinates.y)])
	womb.update_pieces()
	if message.output.size() > 1 : message.output.append("FINISHED SPAWNING %s PIECES" % str(quantity))
	return message

func restart_prompt( message : Message ) -> Message :
	get_tree().reload_current_scene() ; message.output.append("FORCED ROOM RESTART")
	return message

func pass_prompt( message : Message, decoded_input : Array = [], sub_output : Array = [] ) -> Message :
	if turn_node == null : message.error.append(global._ERROR_TURN_HANDLER) ; return message
	if !message.sender_body : message.error.append(global._ERROR_SENDER) ; return message
	
	var force : bool = sub_output[0] if !sub_output.is_empty() else false
	
	if force : turn_node.pass_turn() ; message.output.append("HAS FORCED PASSING TURN [%s] " % str(turn_node.turn -1))
	elif !turn_node.pass_turn( message.sender_body ) : message.error.append("CURRENT TEAM [%s ID: %s] CAN'T PASS CURRENT TURN" % 
	[str(turn_node.team.team_name), str(turn_node.team.id)]) ; return message
	message.output.append("TURN [%s] ENDED BY TEAM [%s] ID: %s, NEW TEAM [%s] ID: %s, NEW TURN [%s]" % 
	[str(turn_node.turn - 1), str(turn_node.prev_team.team_name), str(turn_node.prev_team.id), str(turn_node.team.team_name), str(turn_node.team.id), str(turn_node.turn)])
	return message

func team_change_prompt( message : Message, decoded_input : Array = [] ) -> int :
	var sender_body : Manipulator = message.sender_body
	
	if decoded_input.is_empty() || !sender_body : return sender_body.current_team.id if sender_body else -1
	
	var previous_team_id : int = sender_body.team_id
	var submitted_id = decoded_input[1] if decoded_input.size() > 1 else "NULL"
	var id_int : int = submitted_id if submitted_id is int else submitted_id.to_int() if submitted_id is String && submitted_id.is_valid_int() else -1 
	var final_team : Team = teams.get_team(submitted_id, false)
	var final_id : int = final_team.id if final_team else -1 if id_int != 0 else 0
	
	if final_id == -1 && id_int != 0 : 
		message.error.append(global._ERROR_VALID_TEAM % str(submitted_id))
		return -1
	
	if final_id == sender_body.team_id :
		message.error.append("CAN'T CHANGE TO THE SAME TEAM WITH ID \"%s\"" % str(sender_body.team_id))
		return -1

	sender_body.team_id = final_id
	message.output.append("CHANGED FROM TEAM ID: [%s], TO TEAM ID: [%s]" % [str(previous_team_id), str(sender_body.team_id)])
	
	return final_id

func team_actions_prompt( message : Message, decoded_input : Array = [] ) -> int :
	var sender_body : Manipulator = message.sender_body
	
	if decoded_input.is_empty() || !sender_body : return -1
	var new_actions_per_turn : int = decoded_input[1] if decoded_input.size() > 1 else 1
	
	var final_team : Team = teams.get_team(decoded_input[2]) if decoded_input.size() > 2 else sender_body.current_team if sender_body else null
	if !final_team : 
		if sender_body.team_id == 0 : message.error.append("NO CURRENT TEAM ASSIGNED") ; return -1
		message.error.append(global._ERROR_VALID_TEAM) ; return new_actions_per_turn
	
	final_team.actions_per_turn = new_actions_per_turn
	message.output.append("NEW ACTIONS PER TURN: [%s] FOR TEAM ID: [%s]" % [str(final_team.actions_per_turn), str(final_team.id)])
	
	return new_actions_per_turn

func team_prompt( message : Message, decoded_input : Array = [] ) -> Message :
	if board == null : message.error.append(global._ERROR_BOARD) ; return message
	var sender_body : Manipulator = message.sender_body
	if !sender_body : message.error.append(global._ERROR_SENDER) ; return message
	
	var current_team : Team = sender_body.current_team
	var info_team : Team = teams.get_team(decoded_input[1][1]) if decoded_input[1].size() > 1 else current_team
	
	if !message.all_output.is_empty() : return message
	
	if sender_body.team_id == 0 :
		message.output.append("YOUR TEAM ID IS [0], YOU HAVE NO CURRENT TEAM AND CAN ONLY INTERACT WITH PIECES THAT DON'T HAVE ANY CURRENT TEAM ASSIGNED")
		return message
	
	var temp_prompt : String = "INFORMATION "
	if current_team == info_team : temp_prompt += "CURRENT "
	temp_prompt += "TEAM ID: [%s], NAME: [%s], ACTIONS PER TURN: [%s]" % [str(info_team.id), info_team.team_name, str(info_team.actions_per_turn)]
	if info_team : message.output.append(temp_prompt)
	else : message.error.append(global._ERROR_CURRENT_TEAM)
	return message

func board_add_prompt( message : Message, decoded_input : Array = [] ) -> Vector2i :
	if !grid || decoded_input.is_empty() : message.error.append(global._ERROR_NO_GRID) ; return Vector2i.ZERO
	
	var final_rows : int = decoded_input[1] if decoded_input[1] is int else 1
	var final_tiles : int = decoded_input[2] if decoded_input[2] is int else grid.generation_grid_size.x
	var final_vector := Vector2i(final_tiles, final_rows)
	
	grid.generate_rows(final_vector)
	message.output.append("GENERATED [%s] ROWS WITH [%s] TILES" % [str(final_vector.y), str(final_vector.x)])
	
	return final_vector

func board_reset_prompt( message : Message, decoded_input : Array = [], sub_output : Array = [] ) -> Array :
	if decoded_input.is_empty() || decoded_input[0] is not String : return []
	
	if board == null :
		var sender_body : Manipulator = message.sender_body
		if !sender_body : return []
		var new_board : Board = Board.new().instantiate()
		sender_body.current_board = new_board
		sender_body.get_parent().add_child(new_board)
		message.output.append("GENERATED BRAND NEW BOARD")
	
	var initial_seed : String = decoded_input[1][1] if decoded_input[1].size() > 1 else "random"
	
	var set_name : String = decoded_input[2][1] if decoded_input[2].size() > 1 else "default"
	var final_set = board.set_node.generate(set_name)
	
	var final_size : Vector2i = Vector2i(decoded_input[3][1], decoded_input[3][2]) if !decoded_input[3].is_empty() else Vector2i.ZERO
	
	return [board.instantiate(initial_seed, final_set, final_size), set_name, initial_seed, final_size, final_set]

func board_prompt( message : Message, decoded_input : Array = [], sub_output : Array = [] ) -> Message :
	if !message.sender_body : message.error.append(global._ERROR_SENDER) ; return message
	
	_board_to_restart_to = sub_output[0][0] if !sub_output.is_empty() && !sub_output[0].is_empty() else null
	var set_name : String = sub_output[0][1] if !sub_output.is_empty() && sub_output[0].size() > 1 else ""
	
	if !message.all_output.is_empty() : return message
	if _board_to_restart_to && !sub_output.is_empty() : message.output.append("GENERATED NEW BOARD > SET: %s | SEED NAME: %s | DIMENSIONS: [ X: %s, Y: %s ]" % [sub_output[0][1], sub_output[0][2], str(sub_output[0][3].x if sub_output[0][3].x != 0 else 8), str(sub_output[0][3].x if sub_output[0][3].y != 0 else 8)])
	else : message.output.append("SET: %s | SEED NAME: %s | SEED ID: %s | DIMENSIONS: [ X: %s, Y: %s ]" % [set_name.to_upper(), board.initial_seed, str(board.seed), str(grid.grid_size.x ), str(grid.grid_size.y)])
	return message

func size_prompt( message : Message ) -> Message :
	if board == null : message.error.append(global._ERROR_BOARD) ; return message
	message.output.append("DIMENSIONS: [ X: %s, Y: %s ]" % [str(grid.grid_size.x), str(grid.grid_size.y)])
	return message

func seed_prompt( message : Message ) -> Message :
	if board == null : message.error.append(global._ERROR_BOARD) ; return message
	message.output.append("SEED NAME: %s | SEED ID: %s" % [board.initial_seed, str(board.seed)])
	return message

func help_prompt( message : Message ) :
	var subcommands : PackedStringArray = message.subcommands_input
	var main_command : Command = get_command(subcommands[0]) if !subcommands.is_empty() else null
	var focus_command : Command = main_command
	if focus_command && subcommands.size() > 1 :
		var not_found : bool = false
		for sub in subcommands.slice(1) :
			if not_found : break
			focus_command = main_command.get_subcommand(sub)
			if !focus_command || !focus_command.has_subcommands() : not_found == true ; break
			main_command = focus_command
	 
	var command_list : Array[Command] = focus_command.sub_commands if focus_command else command_map
	
	if focus_command : message.output.append("%s %sCOMMAND:\n\nDESCRIPTION: \"%s\"\n%s%s" % 
	[ " > ".join(focus_command.full_name),
	"" if focus_command.is_main_command() else "SUB-",
	focus_command.info,
	"\nTRIGGERS: %s\n" % focus_command.triggers if focus_command.triggers else "",
	"\n*THIS COMMAND REQUIRES PRIVILEGES*\n" if focus_command.needs_privileges else ""])
	else : message.output.append("MAIN COMMANDS:\n")
	
	if command_list.is_empty() : message.output.append("*THIS COMMAND DOESN'T HAVE ANY SUB-COMMANDS*\n")
	elif focus_command : message.output.append("SUB-COMMANDS:\n")
	for command in command_list :
		if !command.private || ( command.only_visible_with_privileges && message.moderated ) :
			message.output.append("- %s: %s" % [command.cmd_name, command.triggers])
	
	message.output.append(" ")
	if !focus_command : message.output.append("*USE A COMMAND NAME FOR MORE INFORMATION*")
	
	message.connected = true
	message.connect_separator = "\n"
	return message

func mod_prompt( message : Message ) -> Message :
	if message.sender == null : message.error.append("THE USER DOESN'T HAVE WHAT IT TAKES") ; return message
	message.sender.privileges = !message.sender.privileges
	if message.moderated : message.output.append("BECAME A MODERATOR")
	else : message.output.append("IS NO LONGER A MODERATOR")
	return message
