    .global _add_numbers
    .def _add_numbers
_add_numbers:
    movl 4(%esp), %eax   # Load 'a' into EAX (EAX is the return register)
    addl 8(%esp), %eax   # Add 'b' to EAX

    ret                  # Return the result in EAX
