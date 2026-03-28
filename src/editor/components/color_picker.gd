extends ColorPickerButton
class_name CustomColorPicker

## Increment used for lighten/darken actions.
const CHANGE_MAGNITUDE := 0.1

# TODO: Move Action enum to a separate file.
## Keyboard actions supported by the picker.
enum Action {
	DARKER = 0,
	LIGHTER = 1,
	LAST_COLOR = 2,
	COPY = 3,
}

## Maps each action enum to the corresponding input action name.
const ACTION_STRINGS := {
	Action.DARKER: "darker",
	Action.LIGHTER: "lighter",
	Action.LAST_COLOR: "last_color",
	Action.COPY: "copy",
}

## Shared clipboard-like color for quick reuse.
static var _last_color := Color.WHITE


func _ready() -> void:
	color_changed.connect(set_last_color)

	for action in CustomColorPicker.ACTION_STRINGS.values():
		if not InputMap.has_action(action):
			push_warning(
				"Input action '%s' is not defined. Define it in Project Settings → Input Map." % action
			)


func _gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		return
	
	if event.is_action_released(ACTION_STRINGS[Action.DARKER]):
		color = _darken_color(color)
	elif event.is_action_released(ACTION_STRINGS[Action.LIGHTER]):
		color = _lighten_color(color)
	elif event.is_action_released(ACTION_STRINGS[Action.LAST_COLOR]):
		color = _last_color
	elif event.is_action_released(ACTION_STRINGS[Action.COPY]):
		set_last_color(color)
	else:
		# Ignore unrelated input actions.
		return

	# Emit the color_changed signal after updating the color.
	color_changed.emit(color)


## Returns a darker variant of the given color.
func _darken_color(c: Color) -> Color:
	return c.darkened(CHANGE_MAGNITUDE)


## Returns a lighter variant of the given color.
func _lighten_color(c: Color) -> Color:
	return c.lightened(CHANGE_MAGNITUDE)


## Stores the last selected color for reuse actions.
func set_last_color(c: Color) -> void:
	if _last_color != c:
		_last_color = c
