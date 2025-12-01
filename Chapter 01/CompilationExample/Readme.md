# C++ + Assembly Linking Example

This project demonstrates how a C++ program can call a function written in x86 assembly.
It also explains how compilers generate object code and how linkers combine multiple object files into one executable.

This example is perfect for beginners who want to understand what happens behind the scenes when building programs.

---

## 📌 File Overview

### **1) AssemblyFile.s** (32-bit x86, AT&T syntax)

```asm
.global _add_numbers
.def _add_numbers
_add_numbers:
    movl 4(%esp), %eax   # Load first argument into EAX
    addl 8(%esp), %eax   # Add second argument to EAX
    ret                  # Return result in EAX
```

### **2) LinkingExample01.cpp**

```cpp
#include <iostream>

extern "C" int add_numbers(int a, int b);

int main() {
    int result = add_numbers(5, 7);
    std::cout << "The result is: " << result << std::endl;
    return 0;
}
```

---

## 🧠 Why `extern "C"` Is Needed

C++ normally applies **name mangling** to support features like function overloading.
Assembly cannot understand mangled names.

`extern "C"` disables mangling so the C++ compiler exports the symbol exactly as written, allowing the linker to match it with your assembly function.

> Note: `extern "C"` affects **linkage**, not the calling convention.

---

## 🔧 Calling Conventions (Important!)

Different platforms pass function arguments differently.

### **32-bit x86 (cdecl — used in this example)**

* Arguments passed on the stack

  * 1st argument → `4(%esp)`
  * 2nd argument → `8(%esp)`
* Return value in `EAX`

### **64-bit Calling Conventions (for future reference)**

**Linux/macOS x86_64 (System V ABI)**

* Args: `RDI`, `RSI`, `RDX`, `RCX`, `R8`, `R9`
* Return: `RAX`

**Windows x64**

* Args: `RCX`, `RDX`, `R8`, `R9`
* Return: `RAX`

⚠ The provided assembly works only for **32-bit builds**.
64-bit versions require a different assembly file.

---

## 🏗 Build Instructions (Platform-Specific)

### **Windows (MinGW-w64)**

```powershell
gcc -c AssemblyFile.s -o add.o
g++ -c LinkingExample01.cpp -o main.o
g++ main.o add.o -o program.exe
./program.exe
```

### **Linux (32-bit build)**

```bash
gcc -m32 -c AssemblyFile.s -o add.o
g++ -m32 -c LinkingExample01.cpp -o main.o
g++ -m32 main.o add.o -o program
./program
```

### **macOS (clang)**

macOS requires a leading underscore on symbols (`_add_numbers`), which this example already follows.

```bash
clang -c AssemblyFile.s -o add.o
clang++ -c LinkingExample01.cpp -o main.o
clang++ main.o add.o -o program
./program
```

---

## 📦 Folder Structure

```
project/
│
├── AssemblyFile.s
├── LinkingExample01.cpp
└── README.md
```

---

## 🔍 How Compilation Works (Step-by-Step)

### **Step 1: Compile each file**

* The assembler converts `AssemblyFile.s` → `add.o`
* The C++ compiler converts `LinkingExample01.cpp` → `main.o`

### **Step 2: Link**

The linker takes both object files:

```
main.o + add.o → program.exe
```

It resolves the reference to `add_numbers` and produces a complete executable.

### **Step 3: Run**

Output:

```
The result is: 12
```

---

## 🛠 Troubleshooting

### **❌ undefined reference to `add_numbers`**

Check:

* Is the assembly symbol `_add_numbers` or `add_numbers`?
* Did you forget `extern "C"`?
* Did you mix 32-bit assembly with a 64-bit build?

### **❌ mismatch between ELF/COFF/Mach-O formats**

Occurs when mixing:

* `.o` from MinGW with `.obj` from MSVC
* AT&T syntax with MASM syntax
* 32-bit assembly with 64-bit compilation flags

Always use **one toolchain** for the whole build.

---

## 📝 Summary

* C++ can easily call assembly functions when symbol names and calling conventions match.
* Each source file first becomes an **object file**.
* The **linker** combines all object files into an executable.
* `extern "C"` prevents name mangling.
* Calling conventions differ between 32-bit, Linux, macOS, and Windows, so assembly must match the target platform.

---
