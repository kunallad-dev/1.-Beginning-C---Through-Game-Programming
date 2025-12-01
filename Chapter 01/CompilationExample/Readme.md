# Readme for Compilation Example

## Overview
This document explains the full compilation and linking process using the two example files in this folder: `AssemblyFile.s` (assembly) and `LinkingExample01.cpp` (C++).

The goals are:
- Show the contents of both example files.
- Explain how the compiler turns source code into object code.
- Explain how the linker combines object files into an executable.
- Provide platform-specific build commands and important portability notes.

## Example files
1) `AssemblyFile.s` (32-bit x86, AT&T syntax)

```asm
.global _add_numbers
.def _add_numbers
_add_numbers:
    movl 4(%esp), %eax   # Load 'a' into EAX (EAX is the return register)
    addl 8(%esp), %eax   # Add 'b' to EAX

    ret                  # Return the result in EAX
2) `LinkingExample01.cpp`

```cpp
#include <iostream>

extern "C" int add_numbers(int a, int b);
int main() {
    int result = add_numbers(5,7);
    std::cout << "The result is: " << result << std::endl;
    return 0;
}
```
Notes:
- The assembly example uses the 32-bit stack-based calling convention (cdecl): arguments are passed on the stack, and the return value is in `EAX`.
- The symbol is declared as `_add_numbers` in the assembly file. Symbol naming (leading underscore or not) depends on the target platform and object format (ELF vs Mach-O vs PE/COFF).

## Why `extern "C"`?
In C++ the compiler performs name mangling to support overloading and other features. `extern "C"` tells the compiler to use C linkage for the named function (no C++ name mangling), so the linker can find the symbol produced by the assembly file.

If the assembly symbol and the C++ declaration disagree (for example, one uses `_add_numbers` and the other `add_numbers`), the linker will fail to resolve the reference.
## Calling conventions and platform differences

- x86 (32-bit, cdecl): arguments are pushed on the stack. First argument is at `4(%esp)`, second at `8(%esp)`. Return value in `EAX`.
- x86_64 (System V on Linux/macOS): first integer arguments are passed in `RDI`, `RSI`, `RDX`, `RCX`, `R8`, `R9` (for Linux System V: actually `RDI`, `RSI`, `RDX`, `RCX`, `R8`, `R9` on Windows is different). Return value in `RAX`.
- Windows x64: first integer arguments in `RCX`, `RDX`, `R8`, `R9`.
Because your assembly example uses stack offsets (`4(%esp)`, `8(%esp)`), it matches the 32-bit cdecl convention. To use it on x86_64 you'd need to write assembly that follows the 64-bit calling convention (register-based).

## Build and link commands
Below are recommended commands for common toolchains. Adjust filenames (`.o` vs `.obj`) as needed for your toolchain.

Linux (GCC/Clang, ELF, typical x86_64 or x86 development)
For a 32-bit build on Linux (if your assembly is 32-bit):

```bash
gcc -m32 -c AssemblyFile.s -o add.o       # assemble the .s file into add.o (32-bit)
g++ -m32 -c LinkingExample01.cpp -o main.o # compile C++ into main.o (32-bit)
g++ -m32 main.o add.o -o program           # link into an executable
./program
```

For a 64-bit program you must rewrite the assembly for x86_64 (register calling convention). The above 32-bit assembly will not work on x86_64 without translation.
macOS (clang, Mach-O)

Mach-O historically uses a leading underscore on symbol names. The `AssemblyFile.s` shown here already uses `_add_numbers`, which matches traditional macOS conventions.
```bash
clang -c AssemblyFile.s -o add.o
clang++ -c LinkingExample01.cpp -o main.o
clang++ main.o add.o -o program
./program
```

Windows (MinGW-w64 with GCC)
MinGW typically accepts GNU-style assembly and produces `.o` files. If you are using MSVC/MASM you will need MASM syntax and different commands.

```powershell
# Using MinGW-w64 (powershell):
# assemble
gcc -c AssemblyFile.s -o add.o
# compile C++
g++ -c LinkingExample01.cpp -o main.o
# link
g++ main.o add.o -o program.exe
# run
./program.exe
```

Windows (MSVC)
MSVC uses a different assembler (MASM) and object format (`.obj`). Converting the AT&T/GAS assembly above to MASM syntax is required. Minimal example commands with MSVC tools are more involved and are not shown here; instead use MinGW or clang for easiest cross-platform parity.

Object file extensions and formats:
- ELF (Linux): object files usually end in `.o`.
- Mach-O (macOS): object files also commonly use `.o`.
- PE/COFF (Windows): object files often use `.obj` with MSVC, but MinGW/clang still often use `.o`.

## The compile/link flow (step-by-step explanation)
1) Compile/assemble each translation unit into object code:
    - The assembler (`gcc -c` or `as`) turns `AssemblyFile.s` into `add.o` (object code).
    - The C++ compiler (`g++ -c`) turns `LinkingExample01.cpp` into `main.o`.

2) Link object files together:
    - The linker (`g++` or `ld`) takes `main.o` and `add.o`, resolves symbols (for example, the `add_numbers` reference in `main.o`), and produces a single executable (`program` or `program.exe`).

3) Run the executable:
    - When you run `program`, it starts at the program entry point, executes `main`, which calls `add_numbers` in the assembly object. The assembly routine computes `5 + 7` and returns `12` in `EAX`/`RAX` which becomes `result` in the C++ code.

Expected output when run with these examples (32-bit assembly + matching toolchain):

```
The result is: 12
```

## Troubleshooting & portability tips

- If you see an "undefined reference" error for `add_numbers`, check symbol naming and whether `extern "C"` is used. Also inspect the object file symbol table (`nm add.o` on Unix-like systems) to see how the symbol is exported.
- If linking fails only on one platform, the issue is often symbol name decoration (leading underscore) or calling convention mismatch (stack vs registers).
- To port to x86_64, re-write the assembly to use the x86_64 register calling convention (use `rdi`, `rsi`, return in `rax`, etc.).

## Summary

This example demonstrates how a small C++ program can call a function implemented in assembly. The key points are:
- The compiler/assembler produce object files (.o/.obj).
- The linker resolves symbols and creates an executable.
- `extern "C"` is necessary to avoid C++ name mangling.
- Calling conventions and symbol naming are platform-dependent and must match between the assembly and the compiled C++.

If you want, I can:
- Add x86_64 assembly equivalent for this example.
- Add an MSVC/MASM version of the assembly and MSVC link steps.
- Show `nm`/`objdump` examples to inspect symbols and machine code.
