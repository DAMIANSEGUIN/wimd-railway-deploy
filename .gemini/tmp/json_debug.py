import json
from pathlib import Path

file_path = Path(".ai-agents/test_data/TRIGGER_TEST_DATASET.json")

try:
    with open(file_path) as f:
        content = f.read()
    data = json.loads(content)
    print("JSON parsed successfully!")
except json.JSONDecodeError as e:
    print(f"JSON Decode Error: {e}")
    print(f"Error at line: {e.lineno}, column: {e.colno}, character index: {e.pos}")
    # Print the line where the error occurred
    lines = content.splitlines()
    if e.lineno and e.lineno <= len(lines):
        print(f"Problematic line ({e.lineno}): {lines[e.lineno - 1]}")
        # Attempt to print the problematic character if column info is available
        if e.colno and e.colno <= len(lines[e.lineno - 1]):
            print(f"Problematic character: '{lines[e.lineno - 1][e.colno - 1]}'")
        else:
            print("Problematic character location could not be precisely identified.")
    else:
        print("Problematic line number out of bounds.")
except Exception as e:
    print(f"An unexpected error occurred: {e}")
