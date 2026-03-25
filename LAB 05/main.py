import math
import raylibpy as rl
from ship import Ship

def main():
	rl.init_window(800, 600, "Asteroids")
	rl.set_target_fps(30)
	ship = Ship(position=(400, 300), angle=math.pi/4)

	while not rl.window_should_close():
		dt = rl.get_frame_time()
		ship.update(dt)
		rl.begin_drawing()
		rl.clear_background(rl.BLACK)
		ship.draw()
		rl.end_drawing()
	rl.close_window()

if __name__ == "__main__":
	main()
