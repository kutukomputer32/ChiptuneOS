#include <types.h>

#define TERMINAL_WIDTH 80
#define TERMINAL_HEIGHT 25

uint16_t* terminal_framebuffer = (uint16_t*)0xB8000;
uint16_t terminal_x = 0, terminal_y = 0;
uint8_t terminal_color = 0x07;

void terminal_clear ()
{
	for (int i=0; i<TERMINAL_WIDTH*TERMINAL_HEIGHT; i++)
	{
		terminal_framebuffer[i] = terminal_color << 8;
	}
}

void terminal_change_color (uint8_t color)
{
	terminal_color = color;
	for (int i=0; i<TERMINAL_WIDTH*TERMINAL_HEIGHT; i++)
	{
		uint8_t c = terminal_framebuffer[i] & 0xFF;
		terminal_framebuffer[i] = (uint16_t) c | (uint16_t) terminal_color << 8;
	}
}

void terminal_putentryat (char c, uint8_t color, uint16_t x, uint16_t y)
{
	terminal_framebuffer[y * TERMINAL_WIDTH + x] = (uint16_t) c | (uint16_t) color << 8;
}

void terminal_newline ()
{
	terminal_x = 0;
	terminal_y++;
}

void terminal_putchar (char c, uint8_t color)
{
	if (terminal_x >= 80)
		terminal_newline();
	switch (c)
	{
		case '\n':
			terminal_newline();
			break;
		default:
			terminal_putentryat(c, color, terminal_x, terminal_y);
			terminal_x++;
			break;
	}
}

void terminal_print (char *str)
{
	int i = 0;
	while(str[i] != 0)
	{
		terminal_putchar(str[i++], terminal_color);
	}
}

void terminal_print_color (char *str, uint8_t color)
{
	int i = 0;
	while(str[i] != 0)
	{
		terminal_putchar(str[i++], color);
	}
}
