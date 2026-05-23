extends CanvasLayer

@onready var portrait: TextureRect = $RootMargin/Panel/InnerMargin/Portrait
@onready var name_label: Label = $RootMargin/Panel/InnerMargin/TextColumn/NameLabel
@onready var dialogue_label: RichTextLabel = $RootMargin/Panel/InnerMargin/TextColumn/DialogueLabel
@onready var choices_container: VBoxContainer = $RootMargin/Panel/InnerMargin/TextColumn/ChoicesContainer

func _ready() -> void:
	hide_dialogue()

	# temporary test
	show_dialogue(
		"Mage",
		"You should not have come here. You should not have come here. You should not have come here. You should not have come here. You should not have come here. You should not have come here.",
		null
	)

func show_dialogue(speaker_name: String, text: String, portrait_texture: Texture2D = null) -> void:
	name_label.text = speaker_name
	dialogue_label.text = text
	portrait.texture = portrait_texture
	visible = true

func hide_dialogue() -> void:
	visible = false
