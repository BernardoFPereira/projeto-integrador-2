extends Node2D

@onready var particles: GPUParticles2D = $GPUParticles2D

func _ready() -> void:
	particles.emitting = true

func _on_gpu_particles_2d_finished() -> void:
	self.queue_free()
