extends MeshInstance3D



func _ready():
	Global.settings_changed.connect(on_settings_changed)
	change_effect(Global.pixelization)

func on_settings_changed():
	change_effect(Global.pixelization)

func change_effect(num):
	var mat = get_surface_override_material(0)
	mat.set("shader_parameter/pixel_size",num)
