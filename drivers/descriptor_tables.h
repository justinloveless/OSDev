// 
// descriptor_tables.h - Defines the interface for initialising the GDT and IDT.
//                       Also defines needed structures.
//                       Based on code from Bran's kernel development tutorials.
//                       Rewritten for JamesM's kernel development tutorials.
//

#ifndef DESCRIPTOR_TABLES_H
#define DESCRIPTOR_TABLES_H

#include "common.h"

// Initialisation function is publicly accessible.
void init_descriptor_tables();

// A struct describing an interrupt gate.
struct idt_entry_struct
{
    u16int base_lo;             // The lower 16 bits of the address to jump to when this interrupt fires.
    u16int sel;                 // Kernel segment selector.
    u8int  always0;             // This must always be zero.
    u8int  flags;               // More flags. See documentation.
    u16int base_hi;             // The upper 16 bits of the address to jump to.
} __attribute__((packed));

typedef struct idt_entry_struct idt_entry_t;

// A struct describing a pointer to an array of interrupt handlers.
// This is in a format suitable for giving to 'lidt'.
struct idt_ptr_struct
{
    u16int limit;
    u32int base;                // The address of the first element in our idt_entry_t array.
} __attribute__((packed));

typedef struct idt_ptr_struct idt_ptr_t;

// These extern directives let us access the addresses of our ASM ISR handlers.
extern void isr0 ();
extern void isr1 ();
extern void isr2 ();
extern void isr3 ();
extern void isr4 () asm ("isr4");
extern void isr5 () asm ("isr5");
extern void isr6 () asm ("isr6");
extern void isr7 () asm ("isr7");
extern void isr8 () asm ("isr8");
extern void isr9 () asm ("isr9");
extern void isr10() asm ("isr10");
extern void isr11() asm ("isr11");
extern void isr12() asm ("isr12");
extern void isr13() asm ("isr13");
extern void isr14() asm ("isr14");
extern void isr15() asm ("isr15");
extern void isr16() asm ("isr16");
extern void isr17() asm ("isr17");
extern void isr18() asm ("isr18");
extern void isr19() asm ("isr19");
extern void isr20() asm ("isr20");
extern void isr21() asm ("isr21");
extern void isr22() asm ("isr22");
extern void isr23() asm ("isr23");
extern void isr24() asm ("isr24");
extern void isr25() asm ("isr25");
extern void isr26() asm ("isr26");
extern void isr27() asm ("isr27");
extern void isr28() asm ("isr28");
extern void isr29() asm ("isr29");
extern void isr30() asm ("isr30");
extern void isr31() asm ("isr31");
extern void irq0 () asm ("irq0");
extern void irq1 () asm ("irq1");
extern void irq2 () asm ("irq2");
extern void irq3 () asm ("irq3");
extern void irq4 () asm ("irq4");
extern void irq5 () asm ("irq5");
extern void irq6 () asm ("irq6");
extern void irq7 () asm ("irq7");
extern void irq8 () asm ("irq8");
extern void irq9 () asm ("irq9");
extern void irq10() asm ("irq10");
extern void irq11() asm ("irq11");
extern void irq12() asm ("irq12");
extern void irq13() asm ("irq13");
extern void irq14() asm ("irq14");
extern void irq15() asm ("irq15");
extern void isr128() asm ("irq128");

#endif