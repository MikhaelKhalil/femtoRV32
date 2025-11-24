from Instruction import Instruction
from Generator import Generator
from Program import Program
import json
import os
import argparse

def main():
    parser = argparse.ArgumentParser(description="Generate a random RISC-V test program.")
    parser.add_argument(
        "--IC", type=int, help="Number of instructions to generate"
    )
    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(script_dir, "encoding.json")
    with open(json_path, "r") as f:
        encoding = json.load(f)

    generator = Generator(encoding)

    if args.IC:
        program = Program(generator, args.IC)
    else:
        program = Program(generator)  # will use default IC = 10

    program.generate()


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}")
