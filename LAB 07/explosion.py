import raylibpy as rl
class Explosion:
    def __init__(self, position, target_radius):
        self.position = position
        self.target_radius = target_radius
        self.current_radius = 0
        self.ttl = 0.5
        self.alive = True

    def update(self, dt):
        self.ttl -= dt
        if self.ttl <= 0:
            self.alive = False
            return
        
        progress = (0.5 - self.ttl) / 0.5
        self.current_radius = progress * self.target_radius

    def draw(self):
        if self.alive:
            rl.draw_circle_lines(int(self.position[0]), int(self.position[1]), int(self.current_radius), rl.RED)