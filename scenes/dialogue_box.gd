extends CanvasLayer

signal dialogue_started
signal dialogue_finished

@onready var portrait: TextureRect = $RootMargin/Panel/InnerMargin/ContentRow/Portrait
@onready var name_label: Label = $RootMargin/Panel/InnerMargin/ContentRow/TextColumn/NameLabel
@onready var dialogue_label: RichTextLabel = $RootMargin/Panel/InnerMargin/ContentRow/TextColumn/DialogueLabel
@onready var continue_label: Label = $RootMargin/Panel/InnerMargin/ContentRow/TextColumn/ContinueLabel
@onready var choices_container: VBoxContainer = $RootMargin/Panel/InnerMargin/ContentRow/TextColumn/ChoicesContainer

const MAX_CHARS_PER_PAGE := 75
const TYPE_SPEED := 45.0 # characters per second

var pages: Array[String] = []
var page_index := 0

var is_typing := false
var typing_time := 0.0
var current_page_text := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_dialogue()

func _process(delta: float) -> void:
	#if visible:
		#print("--- dialogue layout ---")
		#print("Panel: ", $RootMargin/Panel.size)
		#print("InnerMargin: ", $RootMargin/Panel/InnerMargin.size, " pos ", $RootMargin/Panel/InnerMargin.position)
		#print("ContentRow: ", $RootMargin/Panel/InnerMargin/ContentRow.size)
		#print("Portrait: ", portrait.size)
		#print("TextColumn: ", $RootMargin/Panel/InnerMargin/ContentRow/TextColumn.size)
		#print("NameLabel: ", name_label.size)
		#print("DialogueLabel: ", dialogue_label.size)
		#print("ChoicesContainer: ", choices_container.size, " visible ", choices_container.visible)
		#print("ContinueLabel: ", continue_label.size)
	if not is_typing:
		return

	typing_time += delta
	var chars_to_show := int(typing_time * TYPE_SPEED)

	dialogue_label.visible_characters = chars_to_show

	if chars_to_show >= current_page_text.length():
		finish_typing()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("skip_typing"):
		if is_typing:
			finish_typing()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		if not is_typing:
			advance_dialogue()
			get_viewport().set_input_as_handled()
		return

func show_dialogue(speaker_name: String, text: String, portrait_texture: Texture2D = null) -> void:
	blocking_world_interaction = true

	name_label.text = speaker_name
	portrait.texture = portrait_texture
	portrait.visible = portrait_texture != null

	pages = paginate_text(text, MAX_CHARS_PER_PAGE)
	page_index = 0

	visible = true
	dialogue_started.emit()

	_show_current_page()

func advance_dialogue() -> void:
	if page_index < pages.size() - 1:
		page_index += 1
		_show_current_page()
	else:
		hide_dialogue()

func _show_current_page() -> void:
	current_page_text = pages[page_index]
	dialogue_label.text = current_page_text

	dialogue_label.visible_characters = 0
	typing_time = 0.0
	is_typing = true

	continue_label.text = ""

func finish_typing() -> void:
	is_typing = false
	dialogue_label.visible_characters = -1

	if page_index < pages.size() - 1:
		continue_label.text = "Next..."
	else:
		continue_label.text = "Done"

func hide_dialogue() -> void:
	visible = false
	is_typing = false
	dialogue_label.visible_characters = -1
	pages.clear()
	page_index = 0
	dialogue_finished.emit()

	_release_world_interaction_later()
	
func _release_world_interaction_later() -> void:
	await get_tree().process_frame
	await get_tree().create_timer(0.15).timeout
	blocking_world_interaction = false

func paginate_text(text: String, max_chars := 75) -> Array[String]:
	var words := text.split(" ")
	var result: Array[String] = []
	var current := ""

	for word in words:
		var test := word if current == "" else current + " " + word

		if test.length() > max_chars:
			result.append(current)
			current = word
		else:
			current = test

	if current != "":
		result.append(current)

	return result

var blocking_world_interaction := false

func is_blocking_world_interaction() -> bool:
	return visible or blocking_world_interaction
