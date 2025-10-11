# Timing graphs for OpenSTA

**Step 1: Prepare OpenSTA**

1. Open your terminal and start OpenSTA:

2. Load your synthesized netlist and timing libraries

3. (Optional) Read SPEF for parasitic delays

**Step 2: Generate Timing Reports**

- Max paths (setup-critical)

```bash
report_checks -path_delay max > max_paths.txt
```

- Min paths (hold-critical)
```bash
report_checks -path_delay min > min_paths.txt
```

These commands will create max_paths.txt and min_paths.txt in your current working directory.

**Step 3: Install Python Dependencies**

Ensure Python has the required packages:

```bash
pip3 install networkx matplotlib
```

**Step 4: Prepare the Python Script**

Save the following as `timing_graph.py`:

```python
import networkx as nx
import matplotlib.pyplot as plt
import re

# Replace with your report file (max_paths.txt or min_paths.txt)
report_file = "max_paths.txt"

G = nx.DiGraph()
line_regex = re.compile(r"^\s*([\d\.\-]+)\s+[\d\.\-]+\s+[\^v]\s+(\S+)")

prev_node = None
with open(report_file, "r") as f:
    for line in f:
        match = line_regex.match(line)
        if match:
            delay = float(match.group(1))
            node = match.group(2).split("/")[0]
            if prev_node:
                G.add_edge(prev_node, node, delay=delay)
            prev_node = node

pos = nx.spring_layout(G)
nx.draw(G, pos, with_labels=True, node_color='lightblue', node_size=2000, arrowsize=20)
edge_labels = nx.get_edge_attributes(G, 'delay')
nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels)
plt.title("Timing Graph from OpenSTA")
plt.show()
```

**Step 5: Run the Script**

```bash
python3 timing_graph.py
```

**Step 6: Optional Improvements**

- Run the script separately for max_paths.txt and min_paths.txt to see setup and hold paths.
- Color critical paths differently by checking slack values in the report.
- Combine multiple paths in a single graph for an overview.

This was an interesting side-plot (Pun intended!).

---