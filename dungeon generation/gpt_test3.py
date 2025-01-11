from __future__ import annotations
import random
from typing import List
import matplotlib.pyplot as plt

class DungeonArea:
    def __init__(self, x, y, width, height):
        self.x = x
        self.y = y
        self.width = width
        self.height = height

    def __str__(self):
        return f"DungeonArea at ({self.x},{self.y}) with size ({self.width},{self.height})"

    def __repr__(self):
        return f"DungeonArea at ({self.x},{self.y}) with size ({self.width},{self.height})"

    def plot(self, axs, fc, ec, ls):
        axs.add_patch(plt.Rectangle((self.x, self.y), self.width, self.height, fc=fc, ec=ec, ls=ls))

class Room(DungeonArea):
    def __init__(self, x, y, width, height):
        super().__init__(x, y, width, height)
        self.hallways = []

    def __str__(self):
        return f"Room at ({self.x},{self.y}) with size ({self.width},{self.height})"

    def __repr__(self):
        return f"Room at ({self.x},{self.y}) with size ({self.width},{self.height})"

    def connect_hallway(self, hallway: 'Hallway'):
        self.hallways.append(hallway)

    def connect_hallways(self, hallways: List['Hallway']):
        self.hallways = hallways

    def get_edges(self):
        """
        Returns left x, right x, bottom y and top y
        """
        return self.x, self.x + self.width, self.y, self.y + self.height

    def plot(self, axs):
        super().plot(axs, 'black', 'darkgrey', '-')
        for hallway in self.hallways:
            hallway.plot(axs)

    def center(self):
        return (self.x + self.width // 2, self.y + self.height // 2)

    def intersects(self, other):
        return not (self.x + self.width <= other.x or
                    self.x >= other.x + other.width or
                    self.y + self.height <= other.y or
                    self.y >= other.y + other.height)

class Hallway(DungeonArea):
    def __init__(self, x, y, width, height, room1, room2):
        super().__init__(x, y, width, height)
        self.room1 = room1
        self.room2 = room2

    def __str__(self):
        return f"Hallway between {self.room1} and {self.room2}"

    def __repr__(self):
        return f"Hallway between {self.room1} and {self.room2}"

    def plot(self, axs):
        super().plot(axs, 'darkred', 'darkgrey', '-')

def generate_rooms(width, height, min_size, num_rooms):
    rooms = []
    for _ in range(num_rooms):
        room_width = random.randint(min_size, width // 3)
        room_height = random.randint(min_size, height // 3)
        room_x = random.randint(0, width - room_width)
        room_y = random.randint(0, height - room_height)
        new_room = Room(room_x, room_y, room_width, room_height)

        # Check for overlaps with existing rooms
        overlaps = False
        for room in rooms:
            if new_room.intersects(room):
                overlaps = True
                break

        if not overlaps:
            rooms.append(new_room)

    return rooms

def connect_rooms(rooms):
    global dungeon
    for i in range(len(rooms)):
        for j in range(i + 1, len(rooms)):
            room1 = rooms[i]
            room2 = rooms[j]
            distance_between_centers = ((room1.center()[0] - room2.center()[0]) ** 2 + 
                                        (room1.center()[1] - room2.center()[1]) ** 2) ** 0.5
            if distance_between_centers < 15:  # Adjust this distance threshold as needed
                # Attempt to create a hallway between the rooms
                mid1 = room1.center()
                mid2 = room2.center()

                # Determine hallway orientation (horizontal or vertical)
                if abs(mid1[0] - mid2[0]) > abs(mid1[1] - mid2[1]):  # Horizontal
                    hallway_x = (mid1[0] + mid2[0]) // 2
                    hallway_y1 = room1.y + room1.height
                    hallway_y2 = room2.y
                    if hallway_y1 > hallway_y2:
                        hallway_y1, hallway_y2 = hallway_y2, hallway_y1
                    if not check_hallway_overlap(hallway_x, hallway_y1, hallway_x, hallway_y2):
                        hallway = Hallway(hallway_x, hallway_y1, 1, hallway_y2 - hallway_y1, room1, room2)
                        room1.connect_hallway(hallway)
                        room2.connect_hallway(hallway)

                else:  # Vertical
                    hallway_x1 = room1.x + room1.width
                    hallway_x2 = room2.x
                    hallway_y = (mid1[1] + mid2[1]) // 2
                    if hallway_x1 > hallway_x2:
                        hallway_x1, hallway_x2 = hallway_x2, hallway_x1
                    if not check_hallway_overlap(hallway_x1, hallway_y, hallway_x2, hallway_y):
                        hallway = Hallway(hallway_x1, hallway_y, hallway_x2 - hallway_x1, 1, room1, room2)
                        room1.connect_hallway(hallway)
                        room2.connect_hallway(hallway)

def check_hallway_overlap(x1, y1, x2, y2):
    global dungeon
    for y in range(min(y1, y2), max(y1, y2) + 1):
        for x in range(min(x1, x2), max(x1, x2) + 1):
            if dungeon[y][x] != '#':  # Check if the cell is already occupied
                return True
    return False

def generate_dungeon(width, height, min_size, num_rooms):
    global dungeon
    dungeon = [['#' for _ in range(width)] for _ in range(height)]
    rooms = generate_rooms(width, height, min_size, num_rooms)
    connect_rooms(rooms)

    for room in rooms:
        for y in range(room.y, room.y + room.height):
            for x in range(room.x, room.x + room.width):
                dungeon[y][x] = '.'

    for hallway in [h for room in rooms for h in room.hallways]:
        for y in range(hallway.y, hallway.y + hallway.height):
            for x in range(hallway.x, hallway.x + hallway.width):
                dungeon[y][x] = '.'

    return dungeon, rooms

def plot_dungeon(dungeon, rooms):
    height = len(dungeon)
    width = len(dungeon[0])

    fig, ax = plt.subplots(figsize=(width / 5, height / 5))
    ax.imshow([[1 if cell == '#' else 0 for cell in row] for row in dungeon], cmap="binary", origin="upper")

    for room in rooms:
        rect = plt.Rectangle((room.x, room.y), room.width, room.height, fill=False, edgecolor='red', linewidth=1)
        ax.add_patch(rect)

    ax.set_xticks([])
    ax.set_yticks([])
    plt.show()

# Example usage
if __name__ == "__main__":
    map_size = 35
    width, height, min_size = map_size, map_size, 5
    num_rooms = 10

    dungeon, rooms = generate_dungeon(width, height, min_size, num_rooms)
    plot_dungeon(dungeon, rooms)