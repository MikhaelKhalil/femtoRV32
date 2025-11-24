class RegisterTracker:
    def __init__(self):
        self.registers_initialized = [False] * 32
        self.registers_initialized[0] = True 


    def is_initialized(self, index):
        return self.registers_initialized[index]
    
    def mark_initialized(self, index):
        self.registers_initialized[index] = True


    def get_valid_sources(self):
        return [0] + [i for i in range(1, 32) if self.registers_initialized[i]]
        

    def get_all_registers(self):
        return self.registers_initialized

