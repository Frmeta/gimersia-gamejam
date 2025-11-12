# AudioManager.gd
extends Node

## --- CONFIGURATION ---
const SFX_PLAYERS_COUNT := 8    # Max number of simultaneous SFX that can play
const MIN_VOLUME_DB := -80.0    # Equivalent to Mute (used for safety and silence)

## --- PRIVATE MEMBERS (Declared at the top level to avoid scope errors) ---

# For Sound Effects (SFX)
var _sfx_available: Array[AudioStreamPlayer] = []
var _sfx_queue: Array[Dictionary] = [] # Stores: {"path": String, "volume": float, "pitch": float}

# For Music
var _music_player: AudioStreamPlayer = AudioStreamPlayer.new()

# Global Bus Indices (Cached from AudioServer)
var _music_bus_idx: int = -1
var _sfx_bus_idx: int = -1


## ====================================================================
##                        INITIALIZATION & SETUP
## ====================================================================

func _ready() -> void:
	# Get bus indices once for fast access later
	_music_bus_idx = AudioServer.get_bus_index("Music")
	_sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	if _music_bus_idx == -1 or _sfx_bus_idx == -1:
		push_error("Audio Buses 'Music' and/or 'SFX' not found. Set them up!")
		set_process(false)
		return
		
	# 1. Initialize the pool of AudioStreamPlayer nodes for SFX
	for i in SFX_PLAYERS_COUNT:
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % i
		player.bus = &"SFX" 
		add_child(player)
		_sfx_available.append(player)
		player.finished.connect(_on_sfx_player_finished.bind(player))
		
	# 2. Initialize the single music player
	_music_player.name = "MusicPlayer"
	_music_player.bus = &"Music"
	add_child(_music_player)


## ====================================================================
##                            SFX POOL LOGIC
## ====================================================================

func _process(_delta: float) -> void:
	# Play a queued sound if a player is available
	if not _sfx_queue.is_empty() and not _sfx_available.is_empty():
		var player = _sfx_available.pop_front()
		var sound_data: Dictionary = _sfx_queue.pop_front()
		
		# Apply the per-sound volume
		var volume_db = _get_db_from_linear(sound_data.volume)
		player.volume_db = volume_db
		
		# Apply pitch
		player.pitch_scale = sound_data.pitch
		
		player.stream = load(sound_data.path)
		player.play()

func _on_sfx_player_finished(player: AudioStreamPlayer) -> void:
	# Return the player to the available pool
	_sfx_available.append(player)
	player.stream = null
	# Reset custom properties to prevent carry-over
	player.volume_db = 0.0
	player.pitch_scale = 1.0


## --- PUBLIC SFX METHOD ---

## Queues a sound effect to be played.
## volume_linear is a multiplier for the sound's default volume (0.0 to 1.0)
func play_sfx(path: String, pitch: float = 1.0, volume_linear: float = 1.0) -> void:
	if not is_processing():
		return
		
	_sfx_queue.append({
		"path": path,
		"volume": clampf(volume_linear, 0.0, 1.0),
		"pitch": pitch,
	})


## ====================================================================
##                            MUSIC CONTROL
## ====================================================================

## Plays a music track instantly.
## volume_linear adjusts the track's default volume.
func play_music(path: String, volume_linear: float = 1.0) -> void:
	# Avoid restarting the same track if it's already playing
	if _music_player.stream == load(path) and _music_player.is_playing():
		return
	
	var target_db = _get_db_from_linear(clampf(volume_linear, 0.0, 1.0))
	
	_music_player.stop()
	_music_player.stream = load(path)
	
	# Apply the per-track volume instantly
	_music_player.volume_db = target_db 
	_music_player.play()
	
	
func stop_music() -> void:
	_music_player.stop()
	_music_player.stream = null


## ====================================================================
##                            BUS VOLUME CONTROL
## ====================================================================

## Sets the master volume for all sound effects (SFX Bus). (0.0 to 1.0)
func set_sfx_volume(volume_normalized: float) -> void:
	var volume_db = _get_db_from_linear(volume_normalized) 
	AudioServer.set_bus_volume_db(_sfx_bus_idx, volume_db)

## Gets the current SFX volume (Normalized 0.0 to 1.0)
func get_sfx_volume() -> float:
	var volume_db = AudioServer.get_bus_volume_db(_sfx_bus_idx)
	return _get_linear_from_db(volume_db)

## Sets the master volume for all background music (Music Bus). (0.0 to 1.0)
func set_music_volume(volume_normalized: float) -> void:
	var volume_db = _get_db_from_linear(volume_normalized)
	AudioServer.set_bus_volume_db(_music_bus_idx, volume_db)

## Gets the current Music volume (Normalized 0.0 to 1.0)
func get_music_volume() -> float:
	var volume_db = AudioServer.get_bus_volume_db(_music_bus_idx)
	return _get_linear_from_db(volume_db)


## ====================================================================
##                            VOLUME CONVERSION HELPERS
## ====================================================================

## Converts linear volume (0.0 to 1.0) to decibels (dB).
func _get_db_from_linear(linear: float) -> float:
	if linear <= 0.0001: 
		return MIN_VOLUME_DB
	# Correctly uses the built-in Godot global function
	return linear_to_db(linear) 

## Converts decibels (dB) to linear volume (0.0 to 1.0).
func _get_linear_from_db(db: float) -> float:
	# Correctly uses the built-in Godot global function
	return db_to_linear(db)
