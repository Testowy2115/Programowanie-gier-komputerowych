import math
import raylibpy as rl
from ship import Ship
from asteroid import Asteroid
from utils import SCREENW, SCREENH

def main():
	rl.init_window(SCREENW, SCREENH, "Asteroids")
	rl.set_target_fps(30)
	ship = Ship(position=(400, 300), angle=math.pi/4)

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
		ship.update(dt)
		ship.wrap()
		
		for asteroid in asteroids:
			asteroid.update(dt)
			asteroid.wrap()
			
		rl.begin_drawing()
		rl.clear_background(rl.BLACK)
		ship.draw()
		for asteroid in asteroids:
			asteroid.draw()
		rl.end_drawing()
	rl.close_window()

if __name__ == "__main__":
	main()
