import random
from Instruction import Instruction
from RegisterTracker import RegisterTracker
from MemoryTracker import MemoryTracker

class Generator:
    def __init__(self, encoding_json):
        self.encoding_json = encoding_json 
        self.registers = RegisterTracker()
        self.memory = MemoryTracker()
        self.pc = 0
        self.IC = 0


    def set_IC(self, IC):
        self.IC = IC


    def random_instruction(self, instruction_index, type =  None):
        try:
            if not type: # Randomize type if not user-specified
                type = random.choice(list(self.encoding_json.keys()))

            # Pick an instruction from the generated Type
            name = random.choice(list(self.encoding_json[type].keys()))
            encoding = self.encoding_json[type][name]

            instruction = Instruction(name, type, encoding)

            # Pick registers
            instruction.rd = self._random_destination_register()
            instruction.rs1 = self._random_source_register()
            instruction.rs2 = self._random_source_register()

            self.registers.mark_initialized(instruction.rd)
            
            instruction.rd = f"{instruction.rd:05b}"
            instruction.rs1 = f"{instruction.rs1:05b}"
            instruction.rs2 = f"{instruction.rs2:05b}"
            
            # Generate immediate if neded
            if "imm_bits" in encoding:
                imm_value = 0

                if type == "I_TYPE" and name in ["lw", "lh", "lb", "lhu", "lbu"]:
                    valid_addr = self._random_memory_address()
                    if valid_addr is None:
                        valid_addr = 0
                        self.memory.mark_valid(valid_addr)

                    imm_value = valid_addr

                elif type == "S_TYPE" and name in ["sw", "sh", "sb"]:
                    addr = random.randint(-2048, 2047)
                    self.memory.mark_valid(addr)
                    imm_value = addr

                elif type == "B_TYPE":
                    min_offset = max((-instruction_index) * 4, -4096)
                    max_offset = min((self.IC - instruction_index) * 4, 4094)
                    offset = random.randrange(min_offset, max_offset+1, 2)
                    # print(min_offset)
                    # print(max_offset)
                    # print(offset)
                    # imm_value = offset >> 1
                    imm_value = offset

                elif type == "J_TYPE":
                    # min_offset = max((-instruction_index) * 4, -(1 << 19)) # 20 bit unsigned
                    # max_offset = min((self.IC - instruction_index) * 4, (1 << 19) - 1)
                    # offset = random.randrange(min_offset, max_offset+1, 2)
                    # # imm_value = offset >> 1
                    # imm_value = offset 

                    min_offset = -instruction_index * 4
                    max_offset = (self.IC - instruction_index - 1) * 4

                    if min_offset % 2 != 0:
                        min_offset += 1
                    if max_offset % 2 != 0:
                        max_offset -= 1
                    if min_offset > max_offset:
                        min_offset = max_offset = 0

                    offset = random.randrange(min_offset, max_offset + 1, 2)
                    print(min_offset)
                    print(max_offset)
                    print(offset)
                    imm_value = offset

                    instruction.imm = self._jal_imm_to_bin(imm_value)
                    return instruction

                instruction.imm = self._imm_to_bin(imm_value)

                
            return instruction
        

        
        except Exception as e:
            print(f"Error Generating Random Instructions: {e}")
            return None

    def _random_source_register(self):
        valid = self.registers.get_valid_sources()
        return random.choice(valid)
    

    def _random_destination_register(self):
        return random.randint(1, 31)
    

    def _random_memory_address(self):
        valid = list(self.memory.get_valid_addresses())
        return random.choice(valid)
    

    def _imm_to_bin(self, imm, width = None):
        if width is not None:
            imm &= (1 << width) - 1

        if imm < 0:
            imm = (1 << 32) + imm 

        return f"{imm:032b}"

    def _jal_imm_to_bin(self, imm):
        # imm >>= 1 
        # if imm < 0:
        #     imm = (1 << 20) + imm  # twos complement 

        # imm_bin = f"{imm:020b}" 

        # binary = ["0"] * 32
        # binary[31] = imm_bin[0]
        # # binary[21:31] = list(imm_bin[10:20])
        # # binary[20] = imm_bin[10]
        # # binary[12:20] = list(imm_bin[1:9])
        # binary[30:20] = list(imm_bin[10:0:-1])  # imm[10:1], careful with order
        # binary[20] = imm_bin[10]       # imm[11]
        # binary[19:12] = list(imm_bin[1:9])  # imm[19:12]

        # return "".join(binary)

        if imm % 2 != 0:
            imm = imm - (imm & 1)

        imm_field = imm >> 1

        imm_field &= (1 << 20) - 1

        bit_20 = (imm_field >> 19) & 0x1
        bits_10_1 = imm_field & ((1 << 10) - 1)
        bits_11 = (imm_field >> 10) & 0x1
        bits_19_12 = (imm_field >> 11) & ((1 << 8) - 1)

        binary = ["0"] * 32

        binary[0] = str(bit_20)

        bits_10_1_str = f"{bits_10_1:010b}"

        for i, ch in enumerate(bits_10_1_str):
            binary[1 + i] = ch

        binary[11] = str(bits_11)

        bits_19_12_str = f"{bits_19_12:08b}"

        for i, ch in enumerate(bits_19_12_str):
            binary[12 + i] = ch 


        return "".join(binary)
