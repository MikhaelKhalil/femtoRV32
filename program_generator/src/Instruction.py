class Instruction:
    def __init__(self, name, type, encoding_json, rd = None, rs1 = None, rs2 = None, imm = None):
        self.name = name
        self.type = type
        self.rd = rd
        self.rs1 = rs1
        self.rs2 = rs2
        self.imm = imm 
        self.assembly = None

        self.imm_decimal = None
        self.rd_decimal = None
        self.rs1_decimal = None
        self.rs2_decimal = None

        self.encoding_json = encoding_json


    def get_assembly(self):
        try:

            self._imm_to_decimal()
            self._reg_to_decimal()

            if self.type == "R_TYPE":
                self.assembly = f"{self.name}  x{self.rd_decimal}, x{self.rs1_decimal}, x{self.rs2_decimal}"

            elif self.type == "I_TYPE":
                self.assembly = f"{self.name}  x{self.rd_decimal}, x{self.rs1_decimal}, {self.imm_decimal}"

            elif self.type == "S_TYPE":
                self.assembly = f"{self.name} x{self.rs2_decimal}, {self.imm_decimal}(x{self.rs1_decimal})"

            elif self.type == "B_TYPE":
                self.assembly = f"{self.name} x{self.rs1_decimal}, x{self.rs2_decimal}, {self.imm_decimal}"

            elif self.type == "U_TYPE":
                self.assembly = f"{self.name} x{self.rd_decimal}, {self.imm_decimal}"

            elif self.type == "J_TYPE":
                self.assembly = f"{self.name} x{self.rd_decimal}, {self.imm_decimal}"

            elif self.type == "SYSTEM":
                if self.name in ["ecall", "ebreak", "fence", "fence.tso", "pause"]:
                    self.assembly = f"{self.name}"
                else:
                    raise ValueError(f"Unknown System Instruction: {self.name}")

            return self.assembly

        except Exception as e:
            print(f"Error Generating Assembly: {e}")
            return None
        

    def _imm_to_decimal(self):
        # Converts binary immediate to decimal
        if self.imm is None:
            self.imm_decimal = 0
            return

        encoding = self.encoding_json[self.type][self.name]
        imm_slices = encoding.get("imm_bits", [])

        imm_binary = ""
        for slice_range in imm_slices:
            start, end = slice_range
            imm_binary += str(self.imm[31 - start : 32 - end])

        self.imm_decimal = int(imm_binary, 2)

        if imm_binary and imm_binary[0] == '1': # negative
            self.imm_decimal -= 2**len(imm_binary) # to hamdle signed immediates
    

    def _reg_to_decimal(self):
        if self.rd is None:
            self.rd_decimal = 0
        else:
            self.rd_decimal = int(self.rd, 2)

        if self.rs1 is None:
            self.rs1_decimal = 0
        else:
            self.rs1_decimal = int(self.rs1, 2)

        if self.rs2 is None:
            self.rs2_decimal = 0
        else:
            self.rs2_decimal = int(self.rs2, 2)