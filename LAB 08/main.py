import math
import raylibpy as rl
from enum import Enum
from ship import Ship
from asteroid import Asteroid
from bullet import Bullet
from explosion import Explosion
from utils import SCREENW, SCREENH, FPS, check_collision, filter_alive

class GameState(Enum):
    MENU = 1
    GAME = 2
    GAME_OVER = 3

def draw_hud(score, best):
	rl.draw_text(f"Score: {score}", 10, 10, 20, rl.WHITE)
	rl.draw_text(f"Best: {best}", 10, 30, 20, rl.YELLOW)

class GameManager:
    def __init__(self):
        self.state = GameState.MENU
        self.score = 0
        self.best = 0
        self.ship = None
        self.bullets = []
        self.explosions = []
        self.asteroids = []
        self.victory = False
        
        self.shoot_sound = rl.load_sound("assets/shoot.wav")
        self.explosion_sound = rl.load_sound("assets/explosion.wav")
        self.bg_texture = rl.load_texture("assets/stars.png")

    def init_game(self):
        self.score = 0
        self.victory = False
        self.ship = Ship(position=(SCREENW/2, SCREENH/2), angle=math.pi/4)
        self.bullets = []
        self.explosions = []
        self.asteroids = [
            Asteroid(position=(200, 100), level=1),
            Asteroid(position=(100, 400), level=2),
            Asteroid(position=(200, 300), level=3),
            Asteroid(position=(400, 500), level=3),
            Asteroid(position=(500, 500), level=3),
            Asteroid(position=(10, 300), level=3)
        ]

    def update_menu(self, dt):
        if rl.is_key_pressed(rl.KEY_ENTER):
            self.init_game()
            self.state = GameState.GAME
            
    def draw_menu(self):
        rl.draw_text("ASTEROIDS", SCREENW//2 - 100, SCREENH//2 - 50, 40, rl.WHITE)
        rl.draw_text("Press ENTER to Start", SCREENW//2 - 100, SCREENH//2 + 20, 20, rl.LIGHTGRAY)
        rl.draw_text("Press R to Reset", SCREENW//2 - 100, SCREENH//2 + 50, 20, rl.LIGHTGRAY)

    def update_game(self, dt):
        if rl.is_key_pressed(rl.KEY_SPACE):
            nose_x = self.ship.position[0] + math.sin(self.ship.angle) * 20
            nose_y = self.ship.position[1] - math.cos(self.ship.angle) * 20
            self.bullets.append(Bullet((nose_x, nose_y), self.ship.angle))
            rl.play_sound(self.shoot_sound)
            
        self.ship.update(dt)
        self.ship.wrap()
        
        for bullet in self.bullets:
            bullet.update(dt)
            
        for asteroid in self.asteroids:
            asteroid.update(dt)
            asteroid.wrap()

        for explosion in self.explosions:
            explosion.update(dt)

        self.handle_collisions()

        self.bullets = filter_alive(self.bullets)
        self.asteroids = filter_alive(self.asteroids)
        self.explosions = filter_alive(self.explosions)

        if not self.asteroids:
            self.victory = True
            self.state = GameState.GAME_OVER

        for asteroid in self.asteroids:
            if check_collision(self.ship.position, 20.0, asteroid.position, asteroid.radius):
                self.explosions.append(Explosion(self.ship.position, 40.0))
                rl.play_sound(self.explosion_sound)
                self.victory = False
                self.state = GameState.GAME_OVER
                break

    def handle_collisions(self):
        new_asteroids = []
        for bullet in self.bullets:
            for asteroid in self.asteroids:
                if bullet.alive and asteroid.alive and check_collision(bullet.position, bullet.radius, asteroid.position, asteroid.radius):
                    bullet.alive = False
                    asteroid.alive = False
                    points = {1: 100, 2: 50, 3: 20}
                    self.score += points.get(asteroid.level, 0)
                    if self.score > self.best:
                        self.best = self.score
                    self.explosions.append(Explosion(asteroid.position, asteroid.radius))
                    new_asteroids.extend(asteroid.split())
                    rl.play_sound(self.explosion_sound)
            
        self.asteroids.extend(new_asteroids)

    def draw_game(self):
        self.ship.draw()
        for bullet in self.bullets:
            bullet.draw()
        for asteroid in self.asteroids:
            asteroid.draw()
        for explosion in self.explosions:
            explosion.draw()
        
        draw_hud(self.score, self.best)

    def update_game_over(self, dt):
        for explosion in self.explosions:
            explosion.update(dt)
        self.explosions = filter_alive(self.explosions)
            
        if rl.is_key_pressed(rl.KEY_ENTER):
            if self.score > self.best:
                self.best = self.score
            self.state = GameState.MENU

    def draw_game_over(self):
        self.draw_game()
        
        if self.victory:
            rl.draw_text("VICTORY!", SCREENW//2 - 80, SCREENH//2 - 50, 40, rl.GREEN)
        else:
            rl.draw_text("GAME OVER", SCREENW//2 - 100, SCREENH//2 - 50, 40, rl.RED)
            
        rl.draw_text(f"Score: {self.score}", SCREENW//2 - 30, SCREENH//2 + 10, 20, rl.WHITE)
        rl.draw_text("Press ENTER to Menu", SCREENW//2 - 90, SCREENH//2 + 50, 20, rl.LIGHTGRAY)
        
def main():
    rl.init_window(SCREENW, SCREENH, "Asteroids")
    rl.set_target_fps(FPS)
    
    rl.init_audio_device()
    
    game = GameManager()

    while not rl.window_should_close():
        dt = rl.get_frame_time()
        
        if rl.is_key_pressed(rl.KEY_R):
            if game.score > game.best:
                game.best = game.score
            game.state = GameState.MENU
        
        if game.state == GameState.MENU:
            game.update_menu(dt)
        elif game.state == GameState.GAME:
            game.update_game(dt)
        elif game.state == GameState.GAME_OVER:
            game.update_game_over(dt)
            
        rl.begin_drawing()
        rl.clear_background(rl.BLACK)
        
        rl.begin_blend_mode(rl.BLEND_ADDITIVE)
        rl.draw_texture(game.bg_texture, 0, 0, rl.WHITE)
        rl.draw_texture(game.bg_texture, 0, 0, rl.WHITE)
        rl.end_blend_mode()
        
        if game.state == GameState.MENU:
            game.draw_menu()
        elif game.state == GameState.GAME:
            game.draw_game()
        elif game.state == GameState.GAME_OVER:
            game.draw_game_over()
            
        rl.end_drawing()

    rl.unload_texture(game.bg_texture)
    rl.unload_sound(game.shoot_sound)
    rl.unload_sound(game.explosion_sound)
    rl.close_audio_device()
    rl.close_window()

if __name__ == "__main__":
    main()