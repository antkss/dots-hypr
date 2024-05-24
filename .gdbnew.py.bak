import gdb
import struct

class TISCommand(gdb.Command):
    """Display stack in a custom format."""

    COLORS = [
        '\033[93m',  # Yellow
        '\033[92m',  # Green
        '\033[94m',  # Blue
        '\033[91m',  # Red
        '\033[95m',  # Magenta
        '\033[96m',  # Cyan
    ]
    RESET = '\033[0m'

    def __init__(self):
        super(TISCommand, self).__init__("tis", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        if arg:
            args = gdb.string_to_argv(arg)
            if len(args) == 1:
                start_address = self.parse_address(args[0])
                if start_address is None:
                    print("Invalid address format.")
                    return
                lines = 12  # Default count
            elif len(args) == 2:
                start_address = self.parse_address(args[0])
                if start_address is None:
                    print("Invalid address format.")
                    return
                try:
                    lines = int(args[1])
                except ValueError:
                    print("Invalid number of lines.")
                    return
            else:
                print("Usage: tis <address> [lines]")
                return
        else:
            rsp_val = int(gdb.parse_and_eval("$rsp"))
            start_address = max(rsp_val - 0x30, 0)  # Minimum address is 0
            lines = 12

        self.display_stack(start_address, lines)

    def display_stack(self, start_address, lines):
        block_color_index = 0
        for i in range(lines):
            addr = start_address + i * 0x10
            try:
                data = gdb.selected_inferior().read_memory(addr, 0x10)
                values = struct.unpack("QQ", bytes(data))
                ascii_rep = ''.join(chr(b) if 32 <= b <= 126 else '.' for b in bytes(data))
                register_name = self.get_register_name(addr)
                if register_name:
                    address_str = f" -> {register_name}"
                else:
                    address_str = ""
                address_str = address_str.ljust(8)
                hex_str = f"{self.COLORS[block_color_index]}0x{values[0]:016x}\t0x{values[1]:016x}{self.RESET}"
                ascii_str = f"{self.COLORS[block_color_index]}{ascii_rep}{self.RESET}"
                print(f"{self.COLORS[block_color_index]}0x{addr:016x}\t{hex_str}\t{ascii_str}{self.RESET}{address_str}")
            except gdb.MemoryError as e:
                print(f"Error reading memory at 0x{addr:016x}: {e}")
                break
            except Exception as e:
                print(f"Unexpected error: {e}")
                break

            if (i + 1) % 5 == 0:
                block_color_index = (block_color_index + 1) % len(self.COLORS)

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

    def parse_address(self, arg):
        try:
            if '+' in arg:
                base, offset = arg.split('+')
                base_val = int(gdb.parse_and_eval(base))
                offset_val = int(gdb.parse_and_eval(offset))
                return base_val + offset_val
            else:
                return int(gdb.parse_and_eval(arg))
        except gdb.error:
            return None
        except ValueError:
            return None

TISCommand()
