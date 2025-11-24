class MemoryTracker:
    def __init__(self, size = 256):
        self.size = size
        self.valid_addresses = set(range(self.size))

    def mark_valid(self, address):
        self.valid_addresses.add(address)


    def get_valid_addresses(self):
        return self.valid_addresses

