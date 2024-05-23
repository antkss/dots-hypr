
import gdb
import struct

class TISCommand(gdb.Command):
    """Display stack in a custom format."""
    
    YELLOW = '\033[93m'
    GREEN = '\033[92m'
    BLUE = '\033[94m'
    RESET = '\033[0m'
    
    def __init__(self):
        super(TISCommand, self).__init__("tis", gdb.COMMAND_USER)
    
    def invoke(self, arg, from_tty):
        if arg:
            args = gdb.string_to_argv(arg)
            if len(args) == 1:
                start_address = self.parse_start_address(args[0])
                if start_address is None:
                    print("Invalid address format.")
                    return
                lines = 12  # Default count
            elif len(args) == 2:
                start_address = self.parse_start_address(args[0])
                if start_address is None:
                    print("Invalid address format.")
                    return
                try:
                    lines = int(args[1])
                except ValueError:
                    print("Invalid number of lines.")
                    return
            else:
                print("Usage: tis <start_address> [lines]")
                return
        else:
            rsp_val = int(gdb.parse_and_eval("$rsp"))
            start_address = max(rsp_val - 0x30, 0)  # Minimum address is 0
            lines = 12
        
        self.display_stack(start_address, lines)
    
    def display_stack(self, start_address, lines):
        for i in range(lines):
            addr = start_address + i * 0x10
            try:
                data = gdb.inferiors()[0].read_memory(addr, 0x10).tobytes()
                values = struct.unpack("QQ", data)
                ascii_rep = ''.join(chr(b) if 32 <= b <= 126 else '.' for b in data)
                register_name = self.get_register_name(addr)
                if register_name:
                    address_str = f" -> {register_name}"
                else:
                    address_str = ""
                address_str = address_str.ljust(8)
                hex_str = f"{self.GREEN}0x{values[0]:016x}\t0x{values[1]:016x}{self.RESET}"
                ascii_str = f"{self.BLUE}{ascii_rep}{self.RESET}"
                print(f"{self.YELLOW}{addr:016x}\t{hex_str}\t{ascii_str}{self.RESET}{address_str}")
            except gdb.error as e:
                print(f"Error reading memory at 0x{addr:016x}: {e}")
                break
            except Exception as e:
                print(f"Unexpected error: {e}")
                break
    
    def get_register_name(self, address):
        frame = gdb.selected_frame()
        arch = frame.architecture()
        if arch is None:
            return None
        
        for reg_desc in arch.registers():
            try:
                reg_val = frame.read_register(reg_desc.name)
                if int(reg_val) == address:
                    return reg_desc.name
            except gdb.error:
                continue
        return None
    
    def parse_start_address(self, arg):
        if '-' in arg:
            parts = arg.split('-')
            if len(parts) == 2:
                try:
                    address = int(parts[0], 16)
                    offset = int(parts[1], 16)
                    return address - offset
                except ValueError:
                    return None
        try:
            return int(arg, 16)
        except ValueError:
            return None

TISCommand()

