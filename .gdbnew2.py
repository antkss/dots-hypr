
import gdb
import struct
import re
import os
import json
import pwndbg
import argparse
from pwndbg.commands import CommandCategory
# from pwndbg.enhance import enhance
from pwndbg.color.memory import get_len
parser = argparse.ArgumentParser(description="show memory")
parser.add_argument("address", nargs="?", type=str, default=None,help="entry address")
parser.add_argument("ranges", nargs="?", type=int, default= 13,help="ranges")
COLORS = [
    '\033[33m',  # Yellow
    '\033[32m',  # Green
    '\033[34m',  # Blue
    '\033[31m',  # Red
    '\033[35m',  # Magenta
    '\033[36m',  # Cyan
    '\033[0m',
]
RESET = '\033[0m'
last_address = 0
@pwndbg.commands.ArgparsedCommand(parser, category=CommandCategory.MEMORY)
def tis(address=None, ranges=13):
    start_address = 0
    if tis.repeat:
        display_memory(last_address,ranges,False)
        return
    if address is not None:
        if address.strip() == "heap":
            # try:
            display_heap(ranges)
            return
        else:
            lines = ranges
            start_address = parse_address(address)
            if start_address is None:
                gdb.write("Invalid address format.\n")
                return
            display_memory(start_address-0x30, lines,False)
            return
    else:
        rsp_val = int(gdb.parse_and_eval("$rsp"))
        start_address = max(rsp_val, 0)  # Minimum address is 0
        lines = 12
    try:
        gdb.selected_inferior().read_memory(start_address-0x30, 0x10)
        display_memory(start_address-0x30, lines,False)
        return
    except gdb.MemoryError as e:
        gdb.selected_inferior().read_memory(start_address, 0x10)
        display_memory(start_address, lines, False)
        return


def display_memory(start_address, lines ,isHeap=True,head=False):
    global last_address
    # block_color_index = 6
    # heapcolor = 0
    for i in range(lines):
        addr = start_address + i * 0x10
        data = gdb.selected_inferior().read_memory(addr, 0x10)
        values = struct.unpack("QQ", bytes(data))
        last_address = addr
    for i in range(lines):
        addr = start_address + i * 0x10
        offset = addr - start_address
        address_str = ""
        offaddr = f"{hex(offset)} | {hex(addr)}{RESET}"
        data = gdb.selected_inferior().read_memory(addr, 0x10)
        values = struct.unpack("QQ", bytes(data))
        ascii_rep = ''.join(chr(b) if 32 <= b <= 126 else '.' for b in bytes(data))
        register_name = get_register_name(addr)
        if register_name:
            address_str += f" -> {register_name}"
        if addr == start_address+0x30:
            offaddr = f"{COLORS[1]}{hex(offset)} | {hex(addr)}{RESET}"
            address_str += f"{COLORS[1]} <- here{RESET}"
        hex_str = f"{get_len(values[0])}\t{get_len(values[1])}{RESET}"
        ascii_str = f"{ascii_rep}{RESET}"

        if isHeap:
            gdb.write(f"{offaddr} | {hex_str}\t{ascii_str}{RESET}{address_str}\n")
                
        else:
            gdb.write(f"{offaddr} | {hex_str}\t{ascii_str}{address_str}\n")

def display_heap(lines = 0):
    try:
        # Assume the heap boundaries can be determined from the heap segment in the memory mappings
        mappings = gdb.execute("info proc mappings", to_string=True)
        for line in mappings.splitlines():
            if "[heap]" in line:
                parts = line.split()
                start_address = int(parts[0], 16)
                if lines == 0:
                    lines = 500
                display_memory(start_address, lines,False,True)
                return
        gdb.write("Heap segment not found.\n")
    except gdb.error as e:
        gdb.write(f"Error retrieving heap segment: {e}\n")
def get_register_name(address):
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

def parse_address(arg):
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
                if nexti in point:
                    gdb.execute(f"ni {i+1}")
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
            n = eval(args[2])
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
last_address = 0
