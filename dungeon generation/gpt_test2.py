import numpy as np
import matplotlib.pyplot as plt

class BSPNode:
    def __init__(self, x, y, width, height):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.left = None
        self.right = None

class Room:
    def __init__(self, x, y, width, height):
        self.x = x
        self.y = y
        self.width = width
        self.height = height

def create_bsp_tree(node, min_width, min_height):
    if node.width > min_width and node.height > min_height:
        # Randomly choose horizontal or vertical split
        if np.random.rand() < 0.5:
            # Horizontal split
            split = np.random.randint(node.y, node.y + node.height)
            node.left = BSPNode(node.x, node.y, node.width, split - node.y)
            node.right = BSPNode(node.x, split, node.width, node.y + node.height - split)
        else:
            # Vertical split
            split = np.random.randint(node.x, node.x + node.width)
            node.left = BSPNode(node.x, node.y, split - node.x, node.height)
            node.right = BSPNode(split, node.y, node.x + node.width - split, node.height)

        create_bsp_tree(node.left, min_width, min_height)
        create_bsp_tree(node.right, min_width, min_height)

def create_rooms(node, min_width, min_height, rooms):
    if node.left is None and node.right is None:
        # Create room within the leaf node
        room_width = np.random.randint(min_width, node.width)
        # room_height = np.random.randint(min_height, node.height)
        room_height = np.random.randint(min(node.height, min_height + 1), min_height)
        room_x = np.random.randint(node.x, node.x + node.width - room_width)
        room_y = np.random.randint(node.y, node.y + node.height - room_height)
        rooms.append(Room(room_x, room_y, room_width, room_height))
    else:
        create_rooms(node.left, min_width, min_height, rooms)
        create_rooms(node.right, min_width, min_height, rooms)

def connect_rooms(rooms):
    """
    Connects rooms with hallways, ensuring no overlaps and creating 
    more interesting connections.

    Args:
        rooms: A list of Room objects.

    Returns:
        None
    """

    def create_hallway(x1, y1, x2, y2):
        """
        Generates a list of coordinates for a hallway between two points.

        Args:
            x1, y1: Coordinates of the first point.
            x2, y2: Coordinates of the second point.

        Returns:
            A list of (x, y) coordinates for the hallway.
        """

        if x1 == x2:  # Vertical hallway
            return [(x1, y) for y in range(min(y1, y2), max(y1, y2) + 1)]
        else:  # Horizontal hallway
            return [(x, y1) for x in range(min(x1, x2), max(x1, x2) + 1)]

    def check_hallway_overlap(hallway_points, rooms):
        """
        Checks if the hallway overlaps with any existing rooms.

        Args:
            hallway_points: A list of (x, y) coordinates for the hallway.
            rooms: A list of Room objects.

        Returns:
            True if there is an overlap, False otherwise.
        """

        for room in rooms:
            for point in hallway_points:
                if room.x <= point[0] < room.x + room.width and room.y <= point[1] < room.y + room.height:
                    return True
        return False

    # Connect rooms using a depth-first search approach
    def connect_room(current_room, connected_rooms):
        for other_room in rooms:
            if other_room != current_room and other_room not in connected_rooms:
                center1 = (current_room.x + current_room.width // 2, current_room.y + current_room.height // 2)
                center2 = (other_room.x + other_room.width // 2, other_room.y + other_room.height // 2)

                # Try connecting horizontally and vertically
                for direction in [(True, False), (False, True)]:
                    if direction[0]:  # Connect horizontally first
                        hallway_x = center1[0]
                        hallway_y1 = center1[1]
                        hallway_y2 = center2[1]
                    else:  # Connect vertically first
                        hallway_x1 = center1[0]
                        hallway_x2 = center2[0]
                        hallway_y = center1[1]

                    hallway_points = create_hallway(hallway_x1, hallway_y1, hallway_x2, hallway_y2)
                    if not check_hallway_overlap(hallway_points, rooms):
                        connected_rooms[current_room] = other_room
                        connect_room(other_room, connected_rooms)
                        return

    connected_rooms = {}
    connect_room(rooms[0], connected_rooms)

def generate_dungeon(width, height, min_width, min_height):
    root = BSPNode(0, 0, width, height)
    create_bsp_tree(root, min_width, min_height)
    rooms = []
    create_rooms(root, min_width, min_height, rooms)
    connect_rooms(rooms)
    return rooms

def plot_dungeon(rooms, width, height):
    fig, ax = plt.subplots()
    ax.set_xlim(0, width)
    ax.set_ylim(0, height)

    for room in rooms:
        rect = plt.Rectangle((room.x, room.y), room.width, room.height, fill=False)
        ax.add_patch(rect)

    # Visualize hallways
    for i in range(len(rooms) - 1):
        room1 = rooms[i]
        room2 = rooms[i + 1]
        center1 = (room1.x + room1.width // 2, room1.y + room1.height // 2)
        center2 = (room2.x + room2.width // 2, room2.y + room2.height // 2)

        # Choose a random direction for the hallway
        if np.random.rand() < 0.5:
            # Horizontal hallway
            hallway_y = center1[1]
            ax.plot([center1[0], center2[0]], [hallway_y, hallway_y], color='gray', linestyle='--')
        else:
            # Vertical hallway
            hallway_x = center1[0]
            ax.plot([hallway_x, hallway_x], [center1[1], center2[1]], color='gray', linestyle='--')

    plt.show()

# Example usage
dungeon_width = 80
dungeon_height = 50
min_room_width = 5
min_room_height = 5

rooms = generate_dungeon(dungeon_width, dungeon_height, min_room_width, min_room_height)
plot_dungeon(rooms, dungeon_width, dungeon_height)