import math
import raylibpy as rl
from ship import Ship
from asteroid import Asteroid
from bullet import Bullet
from explosion import Explosion
from utils import SCREENW, SCREENH, check_collision

def main():
	rl.init_window(SCREENW, SCREENH, "Asteroids")
	rl.set_target_fps(60)
	
	rl.init_audio_device()
	shoot_sound = rl.load_sound("assets/shoot.wav")
	explosion_sound = rl.load_sound("assets/explosion.wav")
	bg_texture = rl.load_texture("assets/stars.png")
	#boss = rl.load_texture("assets/boss.png")
	
	ship = Ship(position=(400, 300), angle=math.pi/4)

	bullets = []
	explosions = []
	asteroids = [
		Asteroid(position=(100, 100), radius=10),
		Asteroid(position=(200, 200), radius=20),
		Asteroid(position=(300, 300), radius=30),
		Asteroid(position=(400, 400), radius=40),
		Asteroid(position=(500, 500), radius=50),
		Asteroid(position=(10, 300), radius=150)
	]

	while not rl.window_should_close():
		dt = rl.get_frame_time()
		
		if rl.is_key_pressed(rl.KEY_SPACE):
			nose_x = ship.position[0] + math.sin(ship.angle) * 20
			nose_y = ship.position[1] - math.cos(ship.angle) * 20
			bullets.append(Bullet((nose_x, nose_y), ship.angle))
			rl.play_sound(shoot_sound)
			
		ship.update(dt)
		ship.wrap()
		
		for bullet in bullets:
			bullet.update(dt)
			
		for asteroid in asteroids:
			asteroid.update(dt)
			asteroid.wrap()

		for explosion in explosions:
			explosion.update(dt)

		for b in bullets:
			for a in asteroids:
				if b.alive and a.alive and check_collision(b.position, b.radius, a.position, a.radius):
					b.alive = False
					a.alive = False
					explosions.append(Explosion(a.position, a.radius))
					rl.play_sound(explosion_sound)
			
		bullets = [b for b in bullets if b.alive]
		asteroids = [a for a in asteroids if a.alive]
		explosions = [e for e in explosions if e.alive]
			
		rl.begin_drawing()
		rl.clear_background(rl.BLACK)
		
		rl.begin_blend_mode(rl.BLEND_ADDITIVE)
		rl.draw_texture(bg_texture, 0, 0, rl.WHITE)
		rl.draw_texture(bg_texture, 0, 0, rl.WHITE)
		rl.end_blend_mode()
			
		rl.draw_text(f"Asteroids: {len(asteroids)}", 10, 10, 20, rl.WHITE)
		ship.draw()
		for bullet in bullets:
			bullet.draw()
		for asteroid in asteroids:
			asteroid.draw()
		for explosion in explosions:
			explosion.draw()
		rl.end_drawing()

	rl.unload_texture(bg_texture)
	rl.unload_sound(shoot_sound)
	rl.unload_sound(explosion_sound)
	rl.close_audio_device()
	rl.close_window()

if __name__ == "__main__":
	main()
