import random
import matplotlib.pyplot as plt
import networkx as nx
import matplotlib.patches as patches

class Room:
    """
    Represents a room in the dungeon.
    """
    def __init__(self, name, x, y):
        self.name = name
        self.x = x
        self.y = y
        self.connections = {}  # Dictionary to store connected rooms and their directions

    def connect_to(self, other_room, direction, bidirectional=True):
        """
        Connects this room to another room in a specific direction.

        Args:
            other_room: The room to connect to.
            direction: The direction of the connection (e.g., 'north', 'south').
            bidirectional: Whether the connection should be bidirectional.
        """
        self.connections[direction] = other_room
        if bidirectional:
            other_room.connect_to(self, {'north': 'south', 'south': 'north', 'east': 'west', 'west': 'east'}[direction], False)

    def __str__(self):
        return f"Room: {self.name}"

def create_dungeon(depth, max_branches):
    """
    Creates a dungeon with a given depth and maximum number of branches per room.

    Args:
        depth: The maximum depth of the dungeon.
        max_branches: The maximum number of branches per room.

    Returns:
        A dictionary of rooms, keyed by their names.
    """
    rooms = {}
    rooms['Start'] = Room('Start', 0, 0)
    current_room = rooms['Start'] 

    def create_branch(current_room, depth, max_branches):
        """
        Recursively creates branches in the dungeon.
        """
        if depth == 0:
            return

        possible_directions = ['north', 'south', 'east', 'west']
        for _ in range(random.randint(1, max_branches)):
            direction = random.choice(possible_directions)
            if direction == 'north':
                new_x, new_y = current_room.x, current_room.y + 1
            elif direction == 'south':
                new_x, new_y = current_room.x, current_room.y - 1
            elif direction == 'east':
                new_x, new_y = current_room.x + 1, current_room.y
            elif direction == 'west':
                new_x, new_y = current_room.x - 1, current_room.y

            # Check for room overlap
            is_overlapping = False
            for existing_room_name, existing_room in rooms.items():
                if existing_room.x == new_x and existing_room.y == new_y:
                    is_overlapping = True
                    break

            if not is_overlapping:
                new_room_name = f"{current_room.name}_{direction}"
                rooms[new_room_name] = Room(new_room_name, new_x, new_y)
                current_room.connect_to(rooms[new_room_name], direction)
                create_branch(rooms[new_room_name], depth - 1, max_branches)

    create_branch(current_room, depth, max_branches)
    return rooms

def plot_dungeon(rooms):
    """
    Plots the dungeon graph using matplotlib and networkx.
    """
    G = nx.Graph()

    for room_name, room in rooms.items():
        G.add_node(room_name, pos=(room.x, room.y))
        for direction, connected_room in room.connections.items():
            G.add_edge(room_name, connected_room.name)

    pos = nx.get_node_attributes(G, 'pos') 

    plt.figure(figsize=(8, 6))

    # Draw rooms as squares
    for room_name in rooms:
        x, y = pos[room_name] 
        rect = patches.Rectangle((x - 0.5, y - 0.5), 1, 1, linewidth=1, edgecolor='black', facecolor='lightgray')
        plt.gca().add_patch(rect)

    # Draw connections between rooms
    nx.draw_networkx_edges(G, pos, width=1)

    # Label rooms
    nx.draw_networkx_labels(G, pos, font_size=8)

    plt.axis('equal')
    plt.grid(True)
    plt.title("Dungeon Map")
    plt.show()

# Example usage
dungeon_depth = 3
max_branches_per_room = 4
dungeon = create_dungeon(dungeon_depth, max_branches_per_room)
plot_dungeon(dungeon)