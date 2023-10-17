#include <types.h>

extern void terminal_putentryat (char c, uint8_t color, uint16_t x, uint16_t y);

int kernel_main()
{
	terminal_clear();
	//terminal_putentryat('A', 0x1F, 0, 0); // Blue background with white text
	terminal_print("Welcome to ");
	terminal_print_color("ChiptuneOS!\n", 0x09);
	
	return 0;
}
