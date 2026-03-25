import math
import raylibpy as rl


THRUST = 200.0
FRICTION = 60.0
ROT_SPEED = 3.0 
MAX_SPEED = 350.0  

UP = rl.KEY_UP 
LEFT = rl.KEY_LEFT
RIGHT = rl.KEY_RIGHT

DEBUG = False

class Ship:
	def __init__(self, position, angle=0.0, speed=0.0):
		self.position = position
		self.angle = angle
		self.velocity = [0.0, 0.0]

		self.local_vertices = [
			(0, -20),
			(12, 10),
			(0, 5),
			(-12, 10)
		]

	@staticmethod
	def rotate_point(point, angle):
		x, y = point
		cos_a = math.cos(angle)
		sin_a = math.sin(angle)
		return (
			x * cos_a - y * sin_a,
			x * sin_a + y * cos_a
		)

	def draw(self):
		# Statek
		screen_vertices = []
		for v in self.local_vertices:
			rx, ry = self.rotate_point(v, self.angle)
			sx = self.position[0] + rx
			sy = self.position[1] + ry
			screen_vertices.append((sx, sy))
		rl.draw_line(int(screen_vertices[0][0]), int(screen_vertices[0][1]), int(screen_vertices[1][0]), int(screen_vertices[1][1]), rl.RAYWHITE)
		rl.draw_line(int(screen_vertices[1][0]), int(screen_vertices[1][1]), int(screen_vertices[2][0]), int(screen_vertices[2][1]), rl.RAYWHITE)
		rl.draw_line(int(screen_vertices[2][0]), int(screen_vertices[2][1]), int(screen_vertices[3][0]), int(screen_vertices[3][1]), rl.RAYWHITE)
		rl.draw_line(int(screen_vertices[3][0]), int(screen_vertices[3][1]), int(screen_vertices[0][0]), int(screen_vertices[0][1]), rl.RAYWHITE)

        # Płomień
		if rl.is_key_down(UP):
			flame_local = [
				(0, 15),
				(5, 5),
				(0, 25),  
				(-5, 5)
			]
			flame_screen = []
			for v in flame_local:
				rx, ry = self.rotate_point(v, self.angle)
				sx = self.position[0] + rx
				sy = self.position[1] + ry
				flame_screen.append((sx, sy))
			rl.draw_line(int(flame_screen[0][0]), int(flame_screen[0][1]), int(flame_screen[1][0]), int(flame_screen[1][1]), rl.ORANGE)
			rl.draw_line(int(flame_screen[1][0]), int(flame_screen[1][1]), int(flame_screen[2][0]), int(flame_screen[2][1]), rl.ORANGE)
			rl.draw_line(int(flame_screen[2][0]), int(flame_screen[2][1]), int(flame_screen[3][0]), int(flame_screen[3][1]), rl.ORANGE)
			rl.draw_line(int(flame_screen[3][0]), int(flame_screen[3][1]), int(flame_screen[0][0]), int(flame_screen[0][1]), rl.ORANGE)
			
		# Debug
		if DEBUG:
			vlen = math.hypot(self.velocity[0], self.velocity[1])
			scale = 1.0
			vx = self.position[0]
			vy = self.position[1]
			ex = vx + self.velocity[0] * scale
			ey = vy + self.velocity[1] * scale
			rl.draw_line(int(vx), int(vy), int(ex), int(ey), rl.GREEN)
			rl.draw_text(f"|v| = {vlen:.1f} px/s", 10, 10, 20, rl.LIME)

	def update(self, dt):
		
        # Sterowanie
		if rl.is_key_down(LEFT):
			self.angle -= ROT_SPEED * dt
		if rl.is_key_down(RIGHT):
			self.angle += ROT_SPEED * dt

		if rl.is_key_down(UP):
			dir_x = math.sin(self.angle)
			dir_y = -math.cos(self.angle)
			self.velocity[0] += dir_x * THRUST * dt
			self.velocity[1] += dir_y * THRUST * dt

        # Tarcie
		vlen = math.hypot(self.velocity[0], self.velocity[1])
		if vlen > 0:
			friction_force = FRICTION * dt
			if friction_force > vlen:

				self.velocity[0] = 0.0
				self.velocity[1] = 0.0
			else:
				self.velocity[0] -= self.velocity[0] / vlen * friction_force
				self.velocity[1] -= self.velocity[1] / vlen * friction_force
				
        # Ograniczenie prędkości
		vlen = math.hypot(self.velocity[0], self.velocity[1])
		if vlen > MAX_SPEED:
			scale = MAX_SPEED / vlen
			self.velocity[0] *= scale
			self.velocity[1] *= scale
			
        # Aktualizacja pozycji
		self.position = (
			self.position[0] + self.velocity[0] * dt,
			self.position[1] + self.velocity[1] * dt
		)
