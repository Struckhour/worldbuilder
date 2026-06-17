extends Control

### HOW TO USE BBCODE
### https://docs.godotengine.org/en/3.5/tutorials/ui/bbcode_in_richtextlabel.html#reference

### CUSTOM TEXT EFFECTS:
### [end] cuts off the dialogue without input (good for interruptions)
### [delay=1.0] delays the printing based on a float value
### [input] waits for input before continuing printing
### [var=index] displays an element of the vars argument.
### [speed=1.0] changes the delay between each character while printing based on a float value
### [sound=sfxpath] plays a sound effect
### [stopsound] stops sound effects being played by [sound]

### you can use [lb] and [rb] to print [ and ] respectively

### JSON PERAMETERS
### text: the text which will be written (required)
### name: the name in the box above the main textbox. Hides the name box if not declared.
### image_path: the path of the face sheet used in the face box. Hides face box if not decaled.
### image_coords: the coordinates on the image. Face sheets must be a set of 128x128 pixel face sprites. a coordinate of 1 means 128 pixels. Defaults to (0, 0) if not declared.
### sound_path: the path of the sound to play when a character is printed. Uses whatever is set in the default_sound variable if not decaled.

### set the default_path variables below to the places that files are commonly stored (dialogue, face sprites, and sounds) and you can type ./ in any path of those types to
### use them.

@onready var audioplayer = $PrintSoundPlayer
@onready var textbox = $TextBox
@onready var namebox = $NameBox
@onready var faceimage = $FaceImage

# use ./ in json path when calling display() to get
@export var default_dialogue_path = "res://dialogue/"
# use ./ in image path to get
@export var default_face_path = ""
# use ./ in sound effect path to get
@export var default_sound_path = ""
# default sound played while printing if it is not declared in the json.
@export var default_sound = ""
#delay between each character while printing
@export var default_print_speed = 0.05

# when true, instantly prints dialogue. turns on when select button is pressed
var proceed = false

# emits when select button is pressed, to close dialogue or continue after [input]
signal progress_dialogue
# new variables for choice selection

@onready var choice_box: HBoxContainer = $ChoiceBox
@onready var choice_buttons := [
	$ChoiceBox/Choice0,
	$ChoiceBox/Choice1,
	$ChoiceBox/Choice2,
]
var choosing := false
var choice_index := 0
var current_choices := []
var selected_choice_value = null

signal choice_selected(value)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	textbox.clear()
	namebox.clear()
	choice_box.visible = false
	# display("./test_text.json", "text_0", [3, "five"])

func _process(delta: float) -> void:
	if choosing:
		if Input.is_action_just_pressed("move_left"):
			set_choice_index(choice_index - 1)

		if Input.is_action_just_pressed("move_right"):
			set_choice_index(choice_index + 1)

		if Input.is_action_just_pressed("select") or Input.is_action_just_pressed("attack"):
			var chosen_value = current_choices[choice_index].get("value", choice_index)
			choice_selected.emit(chosen_value)

		return
	if Input.is_action_just_pressed("back") or Input.is_action_just_pressed("spin"):
		proceed = true
		progress_dialogue.emit()
	if Input.is_action_just_pressed("select") or Input.is_action_just_pressed("attack"):
		progress_dialogue.emit()
		

func display(json, id, vars = [], pause_game := true):
	Dlg.in_dialogue = true
	var paused_by_dialogue := false

	if pause_game and not get_tree().paused:
		get_tree().paused = true
		paused_by_dialogue = true
	# reset dialogue box visibility
	visible = true
	faceimage.visible = false
	namebox.visible = false
	
	var print_speed = default_print_speed
	
	# set default values for json perameters
	var dialogue = ""
	var sound = default_sound
	var image = ""
	var namelabel = ""
	var imagecoords = [0, 0]
	
	# get data of the json file
	if json[0] + json[1] == "./":
		json = default_dialogue_path + "".join(json.split().slice(2, json.length()))
		
	json = read_json(json)
	
	# set variables to values from json perameters
	dialogue = json[id]["text"]
	if "sound_path" in json[id]:
		sound = json[id]["sound_path"]
	if "name" in json[id]:
		namelabel = json[id]["name"]
		namebox.visible = true
	if "image_path" in json[id]:
		image = json[id]["image_path"]
		faceimage.visible = true
	if "image_coords" in json[id]:
		imagecoords = json[id]["image_coords"].split(", ")
	
	faceimage.region_rect.position.x = int(imagecoords[0]) * 128
	faceimage.region_rect.position.y = int(imagecoords[1]) * 128
	
	var printing = true
	var tag = []
	
	# set name, face texture, and print sound
	if image[0] + image[1] == "./":
		image = default_face_path + "".join(image.split().slice(2, image.length()))
	faceimage.texture = load(image)
	
	if sound[0] + sound[1] == "./":
		sound = default_sound_path + "".join(sound.split().slice(2, sound.length()))
	audioplayer.stream = load(sound)
	namebox.text = namelabel
	
	# turn dialogue into a list
	var character_list = dialogue.split()
	
	# printing loop
	for chara in character_list:
		$MoveonSprite.visible = false
		
		# stop tags from being printed
		if chara == "[":
			printing = false
		
		# handle normal characters
		if printing:
			audioplayer.play()
			textbox.append_text(chara)
			# makes dialogue skippable
			if !proceed and not chara == " ":
				await get_tree().create_timer(print_speed).timeout
		# get characters in a tag
		else:
			tag.append(chara)
		
		# handle all tags
		if chara == "]":
			printing = true
			var string_tag = "".join(tag)
			
			# stop printing when [end]
			if string_tag == "[end]":
				print(textbox.text)
				textbox.clear()
				visible = false
				proceed = false

				if paused_by_dialogue:
					get_tree().paused = false

				return
			
			# delay printing when [delay]
			elif "delay=" in string_tag:
				if !proceed:
					await get_tree().create_timer(float("".join(tag.slice(7, tag.find("]"))))).timeout
			
			# await input when [input]
			elif string_tag == "[input]":
				$MoveonSprite.visible = true
				await progress_dialogue
				proceed = false
			
			# print variable data from the vars argument (by index)
			elif "var=" in string_tag:
				#print("".join(tag.slice(5, tag.find("]"))))
				var varvalue = vars[int("".join(tag.slice(5, tag.find("]"))))]
				for c in str(varvalue):
					audioplayer.play()
					textbox.append_text(c)
					# makes dialogue skippable
					if !proceed and not chara == " ":
						await get_tree().create_timer(print_speed).timeout
			
			# set delay between characters to 4 digit float
			elif "speed=" in string_tag:
				print_speed = float("".join(tag.slice(7, tag.find("]"))))
			
			# play a sound effect during printing
			elif "sound=" in string_tag:
				var sfx = "".join(tag.slice(7, tag.find("]")))
				if sfx[0] + sfx[1] == "./":
					sfx = default_sound_path + "".join(sfx.split().slice(2, sfx.length()))
				
				$SoundEffectPlayer.stream = load(sfx)
				$SoundEffectPlayer.play()
				
			# stop a sound effect being played
			elif string_tag == "[stopsound]":
				$SoundEffectPlayer.stop()
			
			# add BBCode tags to text
			else:
				textbox.append_text(string_tag)
			tag = []
			
	
	
	# If this dialogue has choices, show them and return the selected value.
	if "choices" in json[id]:
		$MoveonSprite.visible = false

		var result = await show_choices(json[id]["choices"])

		textbox.clear()
		visible = false
		proceed = false
		Dlg.in_dialogue = false

		if paused_by_dialogue:
			get_tree().paused = false

		return result


	# Normal dialogue ending.
	$MoveonSprite.visible = true
	await progress_dialogue
	textbox.clear()
	visible = false
	proceed = false
	Dlg.in_dialogue = false

	if paused_by_dialogue:
		get_tree().paused = false

	return null
	
	
func read_json(json):
	var json_as_text = FileAccess.get_file_as_string(json)
	return JSON.parse_string(json_as_text)

func show_choices(choices: Array):
	choosing = true
	current_choices = choices
	choice_index = 0

	choice_box.visible = true

	for i in choice_buttons.size():
		var button = choice_buttons[i]

		if i < choices.size():
			button.visible = true
			button.text = choices[i].get("text", str(i))
		else:
			button.visible = false

	set_choice_index(0)

	var chosen_value = await choice_selected

	choice_box.visible = false
	choosing = false

	return chosen_value


func set_choice_index(new_index: int) -> void:
	if current_choices.is_empty():
		return

	choice_index = wrapi(new_index, 0, current_choices.size())

	for i in choice_buttons.size():
		if not choice_buttons[i].visible:
			continue

		var choice_text = current_choices[i].get("text", str(i))

		if i == choice_index:
			choice_buttons[i].text = "▶ " + choice_text
		else:
			choice_buttons[i].text = "   " + choice_text
