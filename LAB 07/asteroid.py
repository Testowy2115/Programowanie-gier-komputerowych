import math
import raylibpy as rl
import random
from utils import ghost_positions, SCREENW, SCREENH, rotate_point

class Asteroid:
    def __init__(self, position, radius):
        self.position = position
        self.radius = radius
        self.alive = True
        self.angle = 0.0
        self.rot_speed = random.uniform(-2.0, 2.0)
        
        speed = max(50.0 - radius * 5, 10)
        move_angle = math.radians(rl.get_random_value(0, 360))
        self.velocity = (math.cos(move_angle) * speed, math.sin(move_angle) * speed)
        
        num_points = 9
        self.local_vertices = []
        for i in range(num_points):
            a = (i / num_points) * 2 * math.pi
            r = radius * random.uniform(0.7, 1.3)
            self.local_vertices.append((math.cos(a) * r, math.sin(a) * r))

    def draw(self):
        positions = ghost_positions(self.position[0], self.position[1], self.radius)

        for px, py in positions:
            screen_vertices = []
            for v in self.local_vertices:
                rx, ry = rotate_point(v, self.angle)
                screen_vertices.append((px + rx, py + ry))
                
            for i in range(len(screen_vertices)):
                p1 = screen_vertices[i]
                p2 = screen_vertices[(i + 1) % len(screen_vertices)]
                color = rl.Color(
                    int(127 + 128 * math.cos(self.angle + i)),
                    int(127 + 128 * math.cos(self.angle + i + 2)),
                    int(127 + 128 * math.cos(self.angle + i + 4)),
                    255
                )
                
                rl.draw_line(int(p1[0]), int(p1[1]), int(p2[0]), int(p2[1]), color)
    
    def update(self, dt):
        self.angle += self.rot_speed * dt
        self.position = (
            self.position[0] + self.velocity[0] * dt,
            self.position[1] + self.velocity[1] * dt
        )
        
    def wrap(self):
        x, y = self.position
        x = x % SCREENW
        y = y % SCREENH
        self.position = (x, y)