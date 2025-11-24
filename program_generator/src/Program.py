from Instruction import Instruction
from Generator import Generator
import os

class Program:
    def __init__(self, generator, IC = 10):
        self.generator = generator
        self.generator.set_IC(IC)
        self.IC = IC
        self.instructions = []


    def generate(self, type = None):
        try:
            for i in range(self.IC): # IC is Instruction Count
                instruction = self.generator.random_instruction(i, type)
                self.instructions.append(instruction)
            
            self._write()

        except Exception as e:
            print(f"Error Generating Program: {e}") 
            return       


    def _write(self):
        try:
            script_dir = os.path.dirname(os.path.abspath(__file__))  
            project_root = os.path.dirname(script_dir)
            folder = os.path.join(project_root, "tests")
            prefix = "Test_"

            if not os.path.exists(folder):
                os.makedirs(folder)

            existing_files = [
                file for file in os.listdir(folder)
                if file.startswith(prefix) and file.endswith(".asm")
            ]
            existing_numbers = []
            for file in existing_files:
                num = int(file[len(prefix):-4])
                existing_numbers.append(num)

            next_num = max(existing_numbers, default=0) + 1

            asm_filename = f"{prefix}{next_num:03d}.asm"
            bin_filename = f"{prefix}{next_num:03d}.bin"
            mem_filename = f"{prefix}{next_num:03d}_mem.txt"

            asm_path = os.path.join(folder, asm_filename)
            bin_path = os.path.join(folder, bin_filename)
            mem_path = os.path.join(folder, mem_filename)

            # Write assembly
            with open(asm_path, "w") as asm_file:
                for instruction in self.instructions:
                    asm_file.write(instruction.get_assembly() + "\n")

            # Write binary
            with open(bin_path, "w") as bin_file:
                for instruction in self.instructions:
                    bin_file.write(instruction.get_binary() + "\n")

            # Write memory format
            mem_index = 0
            with open(mem_path, "w") as mem_file:
                for instr in self.instructions:
                    binary = instr.get_binary()  # 32-bit string
                    # Little-endian byte order for mem[0..3]
                    b0 = binary[24:32]
                    b1 = binary[16:24]
                    b2 = binary[8:16]
                    b3 = binary[0:8]

                    line = f"{{mem[{mem_index+3}], mem[{mem_index+2}], mem[{mem_index+1}], mem[{mem_index}]}} = 32'b{b3}{b2}{b1}{b0};"
                    if instr.assembly:
                        line += f"      // {instr.assembly}"

                    mem_file.write(line + "\n")
                    mem_index += 4

            print(f"Assembly file generated: {asm_path}")
            print(f"Binary file generated:   {bin_path}")
            print(f"Memory file generated:   {mem_path}")

        except Exception as e:
            print(f"Error writing files: {e}")
