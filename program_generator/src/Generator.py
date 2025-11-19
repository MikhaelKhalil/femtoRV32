import random
from Instruction import Instruction

class Generator:
    def __init__(self, encoding_json):
        self.encoding_json = encoding_json 



    def random_instruction(self, type =  None):
        try:
            if not type: # Randomize type if not user-specified
                type = random.choice(list(self.encoding_json.keys()))

            # Pick an instruction from the generated Type
            name = random.choice(list(self.encoding_json[type].keys()))
            encoding = self.encoding_json[type][name]

            instruction = Instruction(name, type, encoding)

            # Pick registers
            instruction.rd = f"{random.randint(0,31):05b}"
            instruction.rs1 = f"{random.randint(0,31):05b}"
            instruction.rs2 = f"{random.randint(0,31):05b}"

            # Generate immediate if neded
            if "imm_bits" in encoding:
                imm_slices = encoding["imm_bits"]
                imm_binary = ["0"] * 32 

                for slice_range in imm_slices:
                    start, end = slice_range
                    width = start - end + 1
                    value = random.randint(0, 2**width - 1)
                    binary_value = f"{value:0{width}b}"

                    for i, bit in enumerate(range(end, start+1)):
                        imm_binary[31-bit] = binary_value[i] 


                instruction.imm = "".join(imm_binary)

            return instruction
        
        except Exception as e:
            print(f"Error Generating Random Instructions: {e}")
            return None
