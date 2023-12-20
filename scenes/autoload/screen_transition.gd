extends CanvasLayer

signal transitioned_halfway

func transition():
	$AnimationPlayer.play("default")
	await transitioned_halfway
	$AnimationPlayer.play_backwards("default")

func transition_to_scene(scene: String):
	transition()
	await transitioned_halfway
	get_tree().change_scene_to_file(scene)

func emit_transition_halfway():	
	transitioned_halfway.emit()
