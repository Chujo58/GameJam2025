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
        super().plot(axs, 'darkred','darkgrey','-')    

class BSPNode(DungeonArea):
    def __init__(self, x, y, width, height):
        super().__init__(x, y, width, height)
        self.left = None
        self.right = None
        self.room = None

    def __str__(self):
        return f"Node at ({self.x},{self.y}) with size ({self.width},{self.height})"

    def __repr__(self):
        return f"Node at ({self.x},{self.y}) with size ({self.width},{self.height})"
        
    def plot(self, axs):
        super().plot(axs,'grey','white','--')
        if self.room:
            self.room.plot(axs)
        if self.left:
            self.left.plot(axs)
        if self.right:
            self.right.plot(axs)

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

    def has_two_levels(self):
        if self.left and self.right:
            if (self.left.left and self.left.right) or (self.right.left and self.right.right):
                return True
        return False
    
    def create_hallway(self, room1: Room, room2: Room):
        mid1 = room1.center()
        edge1 = room1.get_edges()

        mid2 = room2.center()
        edge2 = room2.get_edges()

        horizontal_cut = self.left.x == self.right.x
        hallway = None

        # def check_hallway_overlap(x1, y1, x2, y2):
        #     """
        #     Checks if the proposed hallway overlaps with any existing rooms or hallways.

        #     Args:
        #         x1, y1: Coordinates of the starting point of the hallway.
        #         x2, y2: Coordinates of the ending point of the hallway.

        #     Returns:
        #         True if overlap exists, False otherwise.
        #     """
        #     for y in range(min(y1, y2), max(y1, y2) + 1):
        #         for x in range(min(x1, x2), max(x1, x2) + 1):
        #             if dungeon[y][x] != '#':  # Check if the cell is already occupied
        #                 return True
        #     return False

        # if horizontal_cut:
        #     hallway_x = mid1[0]
        #     hallway_y1 = edge1[3]
        #     hallway_y2 = edge2[2]
        #     if not check_hallway_overlap(hallway_x, hallway_y1, hallway_x, hallway_y2): 
        #         hallway = Hallway(hallway_x, hallway_y1, 1, abs(edge1[3] - edge2[2]), room1, room2) 
        # else:
        #     hallway_x1 = edge1[1]
        #     hallway_x2 = edge2[0]
        #     hallway_y = mid1[1]
        #     if not check_hallway_overlap(hallway_x1, hallway_y, hallway_x2, hallway_y):
        #         hallway = Hallway(hallway_x1, hallway_y, abs(edge1[1] - edge2[0]), 1, room1, room2)

        # if hallway:
        #     room1.connect_hallway(hallway)
        #     room2.connect_hallway(hallway)
    
    # def create_hallway(self, room1: Room, room2: Room):
    #     mid1 = room1.center()
    #     edge1 = room1.get_edges()
        
    #     mid2 = room2.center()
    #     edge2 = room2.get_edges()
        
    #     horizontal_cut = self.left.x == self.right.x
    #     hallway = None
        
    #     # if self.has_two_levels():
    #     #     one_hallway = random.choice([True, False])
    #     #     first_room = random.choice([True, False])
    #     #     if one_hallway:
    #     #         if first_room:
                    
    #     #             pass
    #     #             # hallway = Hallway()
        

    #     if horizontal_cut:
    #         hallway = Hallway(mid1[0], edge1[3], hallway_size, abs(edge1[3] - edge2[2]), room1, room2)
    #     else:
    #         hallway = Hallway(edge1[1], mid1[1], abs(edge1[1] - edge2[0]), hallway_size, room1, room2)
        
    #     room1.connect_hallway(hallway)
    #     room2.connect_hallway(hallway)

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

    return dungeon, root


def print_tree(root, level=0, prefix="Root: "):
    """Prints a binary tree in a structured way."""
    if root is not None:
        print(" " * (level * 4) + prefix + str(root))
        if root.left or root.right:  # Print children if they exist
            print_tree(root.left, level + 1, "L--- ")
            print_tree(root.right, level + 1, "R--- ")
            
# Example usage
if __name__ == "__main__":
    map_size = 35
    width, height, min_size = map_size, map_size, 5
    hallway_size = 1
    dungeon, root = generate_bsp_dungeon(width, height, min_size)

    # for row in dungeon:
    #     print("".join(row))
    fig, axs = plt.subplots(1,1)
    root.plot(axs)
    plt.xlim(0,map_size)
    plt.ylim(0,map_size)
    print_tree(root)
    plt.show(block=True)