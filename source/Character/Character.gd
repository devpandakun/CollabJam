extends KinematicBody2D
class_name Character

signal damaged(amount)
signal health_updated(health)
signal killed()

export (float) var max_health = 5
export (float) var move_speed_units = 2 setget _set_move_speed_units
export (float) var move_weight = 0.1

onready var state_machine = $StateMachine
onready var body = $Body
onready var status_animation_player = $StatusAnimation
onready var immunity_timer = $Timers/ImmunityTimer
var weapon = null
var animation_player = null

onready var health = max_health setget _set_health

export (String) var faction = ""
var velocity = Vector2.ZERO
onready var move_speed = move_speed_units * 16 setget _set_move_speed

func _ready():
	assert(faction != "")
	add_to_group(faction)

func _apply_movement():
	velocity = move_and_slide(velocity)

func damage(amount):
	var amount_damaged = 0
	if immunity_timer.is_stopped():
		immunity_timer.start()
		var prev_health = health
		_set_health(health - amount)
		amount_damaged = prev_health - health
		emit_signal("damaged", amount)
		status_animation_player.play("damage")
		if health != 0:
			status_animation_player.queue("immunity")
	return amount_damaged

func attack():
	if weapon != null:
		weapon.attack()

func kill():
	emit_signal("killed")
	queue_free()

func _update_facing():
	if velocity.x != 0:
		body.get_node("Sprite").flip_h = true if sign(velocity.x) > 0 else false
#		weapon.scale.x = sign(velocity.x)
	pass

func check_is_attacking():
	var is_attacking = false
	if weapon != null:
		is_attacking = weapon.is_attacking
	return is_attacking

func _set_move_speed_units(value):
	move_speed = value * 16
	move_speed_units = value

func _set_move_speed(value):
	move_speed = value
	move_speed_units = value / 16.0

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, max_health)
	emit_signal("health_updated", health)
	if health != prev_health:
		if health == 0:
			kill()

func _on_ImmunityTimer_timeout():
	status_animation_player.play("rest")

func _set_weapon(value : Weapon):
	weapon = value
#	weapon.damage_area.add_faction_exception(faction)
	weapon.aim_at_target(Vector2.RIGHT)