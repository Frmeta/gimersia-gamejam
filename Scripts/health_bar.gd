extends TextureRect

@export var textures : Array[Texture]


func set_value(a):
	a = clamp(a, 0, textures.size()-1)
	texture = textures[a]
