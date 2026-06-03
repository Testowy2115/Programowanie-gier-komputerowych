extends RefCounted
class_name ProjectileFactory

const ENEMY_BULLET_LAYER := 1 << 3
const PLAYER_BULLET_MASK := 1 << 1
const PLAYER_LAYER_MASK := 1 << 0

static func spawn_bullet(owner: Node, bullet_scene: PackedScene, start_position: Vector3, direction: Vector3, collision_layer: int = 0, collision_mask: int = 0) -> Node3D:
	if bullet_scene == null or direction.length() < 0.001:
		return null

	var bullet := bullet_scene.instantiate() as Node3D
	if bullet == null:
		return null

	owner.get_tree().root.add_child(bullet)
	bullet.global_position = start_position
	bullet.direction = direction.normalized()

	if collision_layer != 0 or collision_mask != 0:
		_configure_collision(bullet, collision_layer, collision_mask)

	return bullet

static func _configure_collision(bullet: Node3D, collision_layer: int, collision_mask: int) -> void:
	if bullet is CollisionObject3D:
		var collision_object := bullet as CollisionObject3D
		collision_object.collision_layer = collision_layer
		collision_object.collision_mask = collision_mask
		return

	var area := bullet.get_node_or_null("Area3D") as CollisionObject3D
	if area != null:
		area.collision_layer = collision_layer
		area.collision_mask = collision_mask
