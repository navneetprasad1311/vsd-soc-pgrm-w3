import networkx as nx
import matplotlib.pyplot as plt
import re

# Replace with your OpenSTA report_path output file
report_file = "report_path.txt"

# Initialize directed graph
G = nx.DiGraph()

# Regular expression to parse lines like:
# 0.27    0.27 ^ _9501_/Q (sky130_fd_sc_hd__dfxtp_1)
line_regex = re.compile(r"^\s*([\d\.\-]+)\s+[\d\.\-]+\s+[\^v]\s+(\S+)")

# Read the report file and extract edges
prev_node = None
prev_delay = 0
with open(report_file, "r") as f:
    for line in f:
        match = line_regex.match(line)
        if match:
            delay = float(match.group(1))
            node = match.group(2).split("/")[0]  # remove /Q or /D suffix
            if prev_node is not None:
                G.add_edge(prev_node, node, delay=delay)
            prev_node = node
            prev_delay = delay

# Draw the graph
pos = nx.spring_layout(G)
nx.draw(G, pos, with_labels=True, node_color='lightblue', node_size=2000, arrowsize=20)

# Draw edge labels (delays)
edge_labels = nx.get_edge_attributes(G, 'delay')
nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels)

plt.title("Timing Graph from OpenSTA report_path")
plt.show()

