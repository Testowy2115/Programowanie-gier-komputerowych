import math
import raylibpy as rl
from utils import SCREENW, SCREENH

class Bullet:
    def __init__(self, position, angle):
        self.position = list(position)
        speed = 500.0
        
        dir_x = math.sin(angle)
        dir_y = -math.cos(angle)
        self.velocity = [dir_x * speed, dir_y * speed]
        
        self.radius = 1.0
        self.ttl = 1
        self.alive = True

    def update(self, dt):
        self.position[0] += self.velocity[0] * dt
        self.position[1] += self.velocity[1] * dt
        
        self.position[0] %= SCREENW
        self.position[1] %= SCREENH
        
        self.ttl -= dt
        if self.ttl <= 0:
            self.alive = False

    def draw(self):
        rl.draw_circle(int(self.position[0]), int(self.position[1]), self.radius, rl.WHITE)
