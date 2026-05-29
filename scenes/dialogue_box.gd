extends CanvasLayer

signal dialogue_started
signal dialogue_finished
@onready var portrait: TextureRect = $RootMargin/Panel/InnerMargin/Portrait
@onready var name_label: Label = $RootMargin/Panel/InnerMargin/TextColumn/NameLabel
@onready var dialogue_label: RichTextLabel = $RootMargin/Panel/InnerMargin/TextColumn/DialogueLabel
@onready var continue_label: Label = $RootMargin/Panel/InnerMargin/TextColumn/ContinueLabel
@onready var choices_container: VBoxContainer = $RootMargin/Panel/InnerMargin/TextColumn/ChoicesContainer

var pages: Array[String] = []
var page_index := 0

func _ready() -> void:
	hide_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		advance_dialogue()
		get_viewport().set_input_as_handled()

func show_dialogue(speaker_name: String, text: String, portrait_texture: Texture2D = null) -> void:
	dialogue_started.emit()
	name_label.text = speaker_name
	portrait.texture = portrait_texture
	portrait.visible = portrait_texture != null

	pages = paginate_text(text, 75)
	page_index = 0

	visible = true
	_show_current_page()

func advance_dialogue() -> void:
	if page_index < pages.size() - 1:
		page_index += 1
		_show_current_page()
	else:
		hide_dialogue()

func _show_current_page() -> void:
	dialogue_label.text = pages[page_index]

	continue_label.visible = true

	if page_index < pages.size() - 1:
		continue_label.text = "Next..."
	else:
		continue_label.text = "Done"

func hide_dialogue() -> void:
	dialogue_finished.emit()
	visible = false
	pages.clear()
	page_index = 0

func paginate_text(text: String, max_chars := 120) -> Array[String]:
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
