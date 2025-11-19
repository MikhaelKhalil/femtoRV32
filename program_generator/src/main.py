from Instruction import Instruction
from Generator import Generator
from Program import Program
import json
import os

def main():

    script_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(script_dir, "encoding.json")

    with open(json_path, "r") as f:
        encoding = json.load(f)

        generator = Generator(encoding)

        program = Program(generator)

        program.generate()




if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}")      