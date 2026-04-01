import math

SCREENW = 800
SCREENH = 600

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
