
import gdb
import struct
import re
import os
import json
# import pwndbg

class TISCommand(gdb.Command):
    """Display stack or heap in a custom format."""

    COLORS = [
        '\033[33m',  # Yellow
        '\033[32m',  # Green
        '\033[34m',  # Blue
        '\033[31m',  # Red
        '\033[35m',  # Magenta
        '\033[36m',  # Cyan
    ]
    RESET = '\033[0m'

    def __init__(self):
        super(TISCommand, self).__init__("tis", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        if arg:
            args = gdb.string_to_argv(arg)
            if len(args) == 1:
                if args[0] == "heap":
                    self.display_heap()  # Default to 40 lines if no number is provided
                    return
                else:
                    try:
                        lines = int(args[0])
                        rsp_val = int(gdb.parse_and_eval("$rsp"))
                        start_address = max(rsp_val, 0)  # Minimum address is 0
                        self.display_memory(start_address-0x30, lines,False)
                        return
                    except ValueError:
                        gdb.write("show with another format:\n")
                start_address = self.parse_address(args[0])
                if start_address is None:
                    gdb.write("Invalid address format.\n")
                    return
                lines = 12  # Default count
            elif len(args) == 2:
                if args[0] == "heap":
                    try:
                        lines = int(args[1])
                        self.display_heap(lines)
                    except ValueError:
                        gdb.write("Invalid number of lines.\n")
                    return
                start_address = self.parse_address(args[0])
                if start_address is None:
                    gdb.write("Invalid address format.\n")
                    return
                try:
                    lines = int(args[1])
                except ValueError:
                    gdb.write("Invalid number of lines.\n")
                    return
            else:
                gdb.write("Usage: tis <address> [lines] or tis heap [lines]\n")
                return
        else:
            rsp_val = int(gdb.parse_and_eval("$rsp"))
            start_address = max(rsp_val, 0)  # Minimum address is 0
            lines = 12
        try:
            gdb.selected_inferior().read_memory(start_address-0x30, 0x10)
            self.display_memory(start_address-0x30, lines,False)
            return
        except gdb.MemoryError as e:
            gdb.selected_inferior().read_memory(start_address, 0x10)
            self.display_memory(start_address, lines,False)
            return
        except gdb.MemoryError as e:
            gdb.write(f"Error reading memory at 0x{start_address:016x}: {e}\n")
            return


    def display_memory(self, start_address, lines,isheap=True,head=False):
        block_color_index = 0
        heapcolor = 0
        headl = []
        for i in range(lines):
            addr = start_address + i * 0x10
            data = gdb.selected_inferior().read_memory(addr, 0x10)
            values = struct.unpack("QQ", bytes(data))
            # print(f"value: {hex(values[1])}")
            if values[1]:
                headl.append(addr)
        for i in range(lines):
            addr = start_address + i * 0x10
            offset = addr - start_address
            try:
                address_str = ""
                data = gdb.selected_inferior().read_memory(addr, 0x10)
                values = struct.unpack("QQ", bytes(data))
                ascii_rep = ''.join(chr(b) if 32 <= b <= 126 else '.' for b in bytes(data))
                register_name = self.get_register_name(addr)
                if register_name:
                    address_str += f" -> {register_name}"
                # address_str = address_str.ljust(16)
                if addr == start_address+0x30:
                    address_str += f" <- here"
                hex_str = f"0x{values[0]:016x}\t0x{values[1]:016x}{self.RESET}"
                ascii_str = f"{ascii_rep}{self.RESET}"
                offaddr = f"0x{offset:05x} | {hex(addr)}"

                if isheap:
                    gdb.write(f"{self.COLORS[heapcolor]}{offaddr} | {hex_str}\t{ascii_str}{self.RESET}{address_str}\n")
                    if values[1]:
                        heapcolor = (heapcolor + 1) % len(self.COLORS)
                        
                else:
                    hex_str = f"{self.COLORS[block_color_index]}0x{values[0]:016x}\t0x{values[1]:016x}{self.RESET}"
                    ascii_str = f"{self.COLORS[block_color_index]}{ascii_rep}{self.RESET}"
                    offaddr = f"{self.COLORS[block_color_index]}0x{offset:05x} | {hex(addr)}"
                    gdb.write(f"{offaddr} | {hex_str}\t{ascii_str}{self.RESET}{address_str}\n")
                if head:
                    if addr == headl[len(headl)-1]+16:
                        return
            except gdb.MemoryError as e:
                gdb.write(f"Error reading memory at 0x{addr:016x}: {e}\n")
                break
            except Exception as e:
                gdb.write(f"Unexpected error: {e}\n")
                break
            if (i + 1) % 5 == 0:
                block_color_index = (block_color_index + 1) % len(self.COLORS)


    def display_heap(self, lines=0):
        try:
            # Assume the heap boundaries can be determined from the heap segment in the memory mappings
            mappings = gdb.execute("info proc mappings", to_string=True)
            for line in mappings.splitlines():
                if "[heap]" in line:
                    parts = line.split()
                    start_address = int(parts[0], 16)
                    end_address = int(parts[1], 16)
                    # actual_lines = min((end_address - start_address) // 0x10, lines)
                    if lines == 0:
                        lines = 500
                    self.display_memory(start_address, lines,True,True)
                    # self.count_heap_chunks(start_address, start_address + actual_lines * 0x10)
                    return
            gdb.write("Heap segment not found.\n")
        except gdb.error as e:
            gdb.write(f"Error retrieving heap segment: {e}\n")
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
# class NeCommand(gdb.Command):
#     def __init__(self):
#         super(NeCommand, self).__init__("jc", gdb.COMMAND_USER)
#     def Nefunction(self):
#         try:
#             count = 20  # Number of instructions to disassemble
#             frame = gdb.selected_frame()
#             arch = frame.architecture()
#             pc = frame.pc()
#             instructions = []
#             current_pc = pc
#             # point = [
#             # "call",
#             # ]
#             # Disassemble until we have enough instructions
#             while len(instructions) < count:
#                 next_instructions = arch.disassemble(current_pc, current_pc + 16)
#                 if not next_instructions:
#                     break
#                 instructions.extend(next_instructions)
#                 current_pc = next_instructions[-1]['addr'] + next_instructions[-1]['length']
#             for i in range(count-1):
#                 nexti = instructions[i+1]['asm'].split()[0]
#                 # print(instructions[i]['asm'])
#                 if nexti == "call":
#                     gdb.execute(f"si {i+1}")
#                     # print(i+1)
#                     # print(instructions[i+1]['asm'])
#                     return
#             gdb.execute(f"si")
#         except:
#             gdb.write("program is stopped !!\n")
#                 
#
#
#         # for ins in instructions[1:count+1]:  # Start from the second instruction and limit to 'count' instructions
#         #     asm_parts = ins['asm'].split()
#         #     asm = asm_parts[0] if asm_parts else ""  # Extract the mnemonic instruction
#         #     marker = "=>" if ins['addr'] == pc else "  "
#         #     gdb.write(f"{marker} {asm}\n")
#
#
#     def invoke(self, arg, from_tty):
#         self.Nefunction()
#
# NeCommand()
class NeCommand(gdb.Command):
    def __init__(self):
        super(NeCommand, self).__init__("ne", gdb.COMMAND_USER)
    def Nefunction(self):
        try:
            count = 10  # Number of instructions to disassemble
            frame = gdb.selected_frame()
            arch = frame.architecture()
            pc = frame.pc()
            instructions = []
            current_pc = pc

            point = [
                # unconditional branch
                "b",       # branch
                "bl",      # branch with link
                "bx",      # branch and exchange
                "blx",     # branch with link and exchange
                
                # conditional branches
                "beq",     # branch if equal
                "bne",     # branch if not equal
                "bgt",     # branch if greater
                "blt",     # branch if less
                "bge",     # branch if greater or equal
                "ble",     # branch if less or equal
                "bhi",     # branch if higher
                "bls",     # branch if lower or same

                # pc-relative addressing
                "adr",     # load pc-relative address
                "ldr_pc",  # load address into pc for jump
                
                # table-based branching
                "tbh",     # table branch halfword
                "tbb",     # table branch byte

                # stack operations (function calls and returns)
                "push",    # save registers to stack
                "pop",     # restore registers from stack
                "stmfd",   # store multiple full descending (push)
                "ldmfd"    # load multiple full descending (pop)
            ]

            # Disassemble until we have enough instructions
            while len(instructions) < count:
                next_instructions = arch.disassemble(current_pc, current_pc + 16)
                if not next_instructions:
                    break
                instructions.extend(next_instructions)
                current_pc = next_instructions[-1]['addr'] + next_instructions[-1]['length']
            for i in range(count-1):
                nexti = instructions[i+1]['asm'].split()[0]
                # print(instructions[i]['asm'])
                if nexti in point:
                    gdb.execute(f"ni {i+1}")
                    # print(i+1)
                    # print(instructions[i+1]['asm'])
                    return
            gdb.execute(f"ni")
        except:
            gdb.write("program is stopped !!\n")
                


        # for ins in instructions[1:count+1]:  # Start from the second instruction and limit to 'count' instructions
        #     asm_parts = ins['asm'].split()
        #     asm = asm_parts[0] if asm_parts else ""  # Extract the mnemonic instruction
        #     marker = "=>" if ins['addr'] == pc else "  "
        #     gdb.write(f"{marker} {asm}\n")


    def invoke(self, arg, from_tty):
        self.Nefunction()

NeCommand()

class breakoffset(gdb.Command):
    def __init__(self):
        super(breakoffset, self).__init__("bb", gdb.COMMAND_USER)
    def invoke(self, arg, from_tty):
        inferior = gdb.selected_inferior()
        # Get the base address of the executable
        a = gdb.execute("info proc",to_string=True)
        b = gdb.execute("info proc map",to_string=True)
        path = a.split("=")[1].split("\n")[0].strip()[1:-1]
        maps = b.splitlines()
        found = ""
        for i in range(len(maps)):
            if path in maps[i]:
                found = maps[i]
                break
        base_address = int(found.split()[0],16)
        offset = 0
        if arg:
            try:
                offset = int(arg,16)
            except ValueError:
                offset = int(arg)
            gdb.execute(f"b*{hex(base_address+offset)}")
        else:
            gdb.write(f"usage: bb <offset>\n")
        # base_address = inferior.read_var('__executable_start').address
        # print(hex(base_address))
        
        # if arg:
        #     args = gdb.string_to_argv(arg)
        #     if len(args) == 1:
        #         start_address = self.parse_address(args[0])
breakoffset()
class setr(gdb.Command):
    def __init__(self):
        super(setr, self).__init__("setr", gdb.COMMAND_USER)
    def invoke(self, arg, from_tty):
        if arg:
            args = gdb.string_to_argv(arg)
            if(len(args) != 4):
                print("usage: setr <address> <value> <range> <mode>")
                print("mode: 32 or 64 bit")
                return
            addr = self.parse_address(args[0])
            value = args[1]
            n = int(args[2])
            if int(args[3]) == 64:
                for i in range(n):
                    if value == "nums":
                        gdb.execute(f"set *(long int*){hex(addr+i*8)}  = {0x1000000000000000+i}")
                    else:
                        gdb.execute(f"set *(long int*){hex(addr+i*8)}  = {value}")
                    # print(hex(addr+i*8))
            elif int(args[3]) == 32:
                for i in range(n):
                    if value == "nums":
                        gdb.execute(f"set *(int*){hex(addr+i*4)}  = {0x100000000+i}")
                    else:
                        gdb.execute(f"set *(int*){hex(addr+i*4)}  = {value}")
            else:
                print("usage: setr <address> <value> <range> <mode>")
                print("mode: 64 or 32 bit")
                return
        else:
            print("usage: setr <address> <value> <range> <mode>")
            print("mode: 64 or 32 bit")
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
setr()

class ripva(gdb.Command):
    def __init__(self):
        super(ripva, self).__init__("ripva", gdb.COMMAND_USER)
    def invoke(self, arg, from_tty):
        inferior = gdb.selected_inferior()
        # Get the base address of the executable
        a = gdb.execute("info proc",to_string=True)
        b = gdb.execute("info proc map",to_string=True)
        path = a.split("=")[1].split("\n")[0].strip()[1:-1]
        maps = b.splitlines()
        found = ""
        for i in range(len(maps)):
            if path in maps[i]:
                found = maps[i]
                break
        base_address = int(found.split()[0],16)
        offset = 0
        if arg:
            try:
                offset = int(arg,16)
            except ValueError:
                offset = int(arg)
            gdb.execute(f"set $rip={hex(base_address+offset)}")
            gdb.execute("context")
        else:
            gdb.write(f"usage: ripva <offset>\n")
        # base_address = inferior.read_var('__executable_start').address
        # print(hex(base_address))
        
        # if arg:
        #     args = gdb.string_to_argv(arg)
        #     if len(args) == 1:
        #         start_address = self.parse_address(args[0])
ripva()
