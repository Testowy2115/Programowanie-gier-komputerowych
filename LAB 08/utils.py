import math

SCREENW = 800
SCREENH = 600
FPS = 60

def filter_alive(entities):
    return [e for e in entities if e.alive]

def ghost_positions(x, y, size):
    positions_x = [x]
    positions_y = [y]

    if x < size:
        positions_x.append(x + SCREENW)
    elif x > SCREENW - size:
        positions_x.append(x - SCREENW)

    if y < size:
        positions_y.append(y + SCREENH)
    elif y > SCREENH - size:
        positions_y.append(y - SCREENH)

    positions = []
    for px in positions_x:
        for py in positions_y:
            positions.append((px, py))
            
    return positions

def rotate_point(point, angle):
    x, y = point
    cos_a = math.cos(angle)
    sin_a = math.sin(angle)
    return (
        x * cos_a - y * sin_a,
        x * sin_a + y * cos_a
    )

def check_collision(pos1, r1, pos2, r2):
    return math.hypot(pos1[0] - pos2[0], pos1[1] - pos2[1]) <= (r1 + r2)

def check_circle_collision(pos1, radius1, pos2, radius2):
    distance = math.hypot(pos2[0] - pos1[0], pos2[1] - pos1[1])
    return distance < (radius1 + radius2)