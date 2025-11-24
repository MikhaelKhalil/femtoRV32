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
                if self.name in ["lb", "lh", "lw", "lbu", "lhu"]:
                    self.assembly = f"{self.name} x{self.rd_decimal}, {self.imm_decimal}(x{self.rs1_decimal})"
                else:
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
        

    


    def get_binary(self):
        try:
            enc = self.encoding_json
            opcode = enc["opcode"]

            if self.type == "SYSTEM":
                return opcode.zfill(32)

            funct3 = enc.get("funct3", "")
            funct7 = enc.get("funct7", "")

            rd = self.rd or "00000"
            rs1 = self.rs1 or "00000"
            rs2 = self.rs2 or "00000"

            if self.type == "R_TYPE":
                return (
                    funct7 +
                    rs2 +
                    rs1 +
                    funct3 +
                    rd +
                    opcode
                )

            if self.type == "I_TYPE":
                imm = self.imm[-12:]  # lower 12 bits
                return (
                    imm +
                    rs1 +
                    funct3 +
                    rd +
                    opcode
                )

            if self.type == "S_TYPE":
                imm = self.imm[-12:]
                imm_11_5 = imm[:7]
                imm_4_0 = imm[7:]
                return (
                    imm_11_5 +
                    rs2 +
                    rs1 +
                    funct3 +
                    imm_4_0 +
                    opcode
                )

            if self.type == "B_TYPE":
                imm = self.imm[-13:]  # 12-bit + sign
                bit12 = imm[0]
                bit10_5 = imm[1:7]
                bit4_1 = imm[7:11]
                bit11 = imm[11]
                return (
                    bit12 +
                    bit10_5 +
                    rs2 +
                    rs1 +
                    funct3 +
                    bit4_1 +
                    bit11 +
                    opcode
                )


            if self.type == "U_TYPE":
                imm = self.imm[:20]
                return (
                    imm +
                    rd +
                    opcode
                )


            if self.type == "J_TYPE":
                imm = self.imm[-21:] 
                bit20 = imm[0]
                bits10_1 = imm[1:11]
                bit11 = imm[11]
                bits19_12 = imm[12:20]
                return (
                    bit20 +
                    bits19_12 +
                    bit11 +
                    bits10_1 +
                    rd +
                    opcode
                )

            raise ValueError(f"Unknown type in get_binary(): {self.type}")

        except Exception as e:
            print(f"Error in converting to binary: {e}")
            return None



    def _imm_to_decimal(self):
        # try:
        #     # Converts binary immediate to decimal
        #     if self.imm is None:
        #         self.imm_decimal = 0
        #         return

        #     imm_slices = self.encoding_json.get("imm_bits", [])

        #     imm_binary = ""
        #     for slice_range in imm_slices:
        #         start, end = slice_range
        #         imm_binary += str(self.imm[31 - start : 32 - end])

        #     self.imm_decimal = int(imm_binary, 2)

        #     if imm_binary and imm_binary[0] == '1': # negative
        #         self.imm_decimal -= 2**len(imm_binary) # to hamdle signed immediates

        # except Exception as e:
        #     print(f"Error Converting Immediate to Decimal: {e}")

        try:
            # Converts binary immediate to decimal
            if self.imm is None:
                self.imm_decimal = 0
                return

            imm_slices = self.encoding_json.get("imm_bits", [])

            imm_binary = ""
            for slice_range in imm_slices:
                start, end = slice_range
                imm_binary += self.imm[31 - start : 32 - end + 1]

            value = int(imm_binary or "0", 2)

            if imm_binary and imm_binary[0] == '1': # negative
                value -= (1 << len(imm_binary))


            if self.type in ("B_TYPE", "J_TYPE"):
                value = value << 1

            self.imm_decimal = value    

        except Exception as e:
            print(f"Error Converting Immediate to Decimal: {e}")
    

    def _reg_to_decimal(self):
        try:
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

        except Exception as e:
            print(F"Error Converting Reg to Decimal: {e}")    