from Instruction import Instruction
from Generator import Generator
import os

class Program:
    def __init__(self, generator):
        self.generator = generator
        self.instructions = []


    def generate(self, IC = 10, type = None):
        try:
            for i in range(IC): # IC is Instruction Count
                instruction = self.generator.random_instruction(type)
                self.instructions.append(instruction)
                self._write_asm()

        except Exception as e:
            print(f"Error Generating Program: {e}") 
            return       


    def _write_asm(self):
        try:
            script_dir = os.path.dirname(os.path.abspath(__file__))  # src/
            project_root = os.path.dirname(script_dir)
            folder = os.path.join(project_root, "tests")
            prefix = "Test_"

            if not os.path.exists(folder):
                os.makedirs(folder)

            existing_files = [file for file in os.listdir(folder) if file.startswith(prefix) and file.endswith(".asm")]
            existing_numbers = []

            for file in existing_files:
                num = int(file[len(prefix):-4])  # remove prefix and .asm
                existing_numbers.append(num)


            next_num = max(existing_numbers, default=0) + 1

            # create next file name
            filename = f"{prefix}{next_num:03d}.asm"
            filepath = os.path.join(folder, filename)

            # WRITE !
            with open(filepath, "w") as file:
                for instruction in self.instructions:
                    file.write(instruction.get_assembly() + "\n")

            print(f"Assembly file generated: {filepath}")

        except Exception as e:
            print(f"Error writing assembly file: {e}")    