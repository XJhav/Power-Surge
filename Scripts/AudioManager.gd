extends Node

func play_sound(sound : Sound):
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sound.sound_file
	audio_player.volume_db = sound.volume
	get_tree().root.add_child(audio_player)
	audio_player.play(0)
	await audio_player.finished
	audio_player.queue_free()
