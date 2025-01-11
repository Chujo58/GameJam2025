import random

class Room:
    def __init__(self, x, y, width, height):
        self.x = x
        self.y = y
        self.width = width
        self.height = height

    def center(self):
        return (self.x + self.width // 2, self.y + self.height // 2)

    def intersects(self, other):
        return not (self.x + self.width <= other.x or
                    self.x >= other.x + other.width or
                    self.y + self.height <= other.y or
                    self.y >= other.y + other.height)

class BSPNode:
    def __init__(self, x, y, width, height):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.left = None
        self.right = None
        self.room = None

    def split(self, min_size):
        if self.left or self.right:
            return False  # Already split

        split_horizontally = random.choice([True, False])

        if self.width > self.height and self.width / self.height >= 1.25:
            split_horizontally = False
        elif self.height > self.width and self.height / self.width >= 1.25:
            split_horizontally = True

        if split_horizontally:
            max_split = self.height - min_size
            if max_split <= min_size:
                return False

            split = random.randint(min_size, max_split)
            self.left = BSPNode(self.x, self.y, self.width, split)
            self.right = BSPNode(self.x, self.y + split, self.width, self.height - split)
        else:
            max_split = self.width - min_size
            if max_split <= min_size:
                return False

            split = random.randint(min_size, max_split)
            self.left = BSPNode(self.x, self.y, split, self.height)
            self.right = BSPNode(self.x + split, self.y, self.width - split, self.height)

        return True

    def create_room(self):
        if self.left or self.right:
            if self.left:
                self.left.create_room()
            if self.right:
                self.right.create_room()

            if self.left and self.right:
                self.create_hallway(self.left.get_room(), self.right.get_room())
        else:
            room_width = random.randint(3, self.width - 2)
            room_height = random.randint(3, self.height - 2)
            room_x = random.randint(self.x + 1, self.x + self.width - room_width - 1)
            room_y = random.randint(self.y + 1, self.y + self.height - room_height - 1)
            self.room = Room(room_x, room_y, room_width, room_height)

    def get_room(self):
        if self.room:
            return self.room
        elif self.left or self.right:
            left_room = self.left.get_room() if self.left else None
            right_room = self.right.get_room() if self.right else None
            if left_room and right_room:
                return random.choice([left_room, right_room])
            return left_room or right_room
        return None

    def create_hallway(self, room1, room2):
        x1, y1 = room1.center()
        x2, y2 = room2.center()

        if random.choice([True, False]):
            self.create_horizontal_tunnel(x1, x2, y1)
            self.create_vertical_tunnel(y1, y2, x2)
        else:
            self.create_vertical_tunnel(y1, y2, x1)
            self.create_horizontal_tunnel(x1, x2, y2)

    def create_horizontal_tunnel(self, x1, x2, y):
        for x in range(min(x1, x2), max(x1, x2) + 1):
            dungeon[y][x] = '.'

    def create_vertical_tunnel(self, y1, y2, x):
        for y in range(min(y1, y2), max(y1, y2) + 1):
            dungeon[y][x] = '.'

def generate_bsp_dungeon(width, height, min_size):
    global dungeon
    dungeon = [['#' for _ in range(width)] for _ in range(height)]

    root = BSPNode(0, 0, width, height)
    nodes = [root]
    
    while nodes:
        node = nodes.pop(0)
        if node.width > min_size * 2 or node.height > min_size * 2:
            if node.split(min_size):
                nodes.append(node.left)
                nodes.append(node.right)

    root.create_room()

    for y in range(height):
        for x in range(width):
            if any(room.x <= x < room.x + room.width and room.y <= y < room.y + room.height for node in nodes for room in [node.get_room()] if room):
                dungeon[y][x] = '.'

    return dungeon

# Example usage
if __name__ == "__main__":
    width, height, min_size = 50, 50, 6
    dungeon = generate_bsp_dungeon(width, height, min_size)

    for row in dungeon:
        print("".join(row))