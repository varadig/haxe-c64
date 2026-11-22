/* haxe64 runtime - included by every generated C file. */
#ifndef HAXE64_H
#define HAXE64_H

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>

#define H64_POKE(a, v) (*(volatile uint8_t *)(uint16_t)(a) = (uint8_t)(v))
#define H64_PEEK(a) (*(volatile uint8_t *)(uint16_t)(a))

/* ---------- random (xorshift16) ---------- */
static uint16_t h64_seed = 0xACE1;

static inline uint16_t h64_rand16(void) {
	h64_seed ^= h64_seed << 7;
	h64_seed ^= h64_seed >> 9;
	h64_seed ^= h64_seed << 8;
	return h64_seed;
}

static inline int16_t h64_random(int16_t n) {
	if (n <= 0) return 0;
	return (int16_t)(h64_rand16() % (uint16_t)n);
}

/* ---------- trace / panic ---------- */
static void h64_trace_int(int16_t v) { printf("%d\n", v); }
static void h64_trace_str(const char *s) { printf("%s\n", s); }
static void h64_trace_bool(bool b) { printf(b ? "true\n" : "false\n"); }

static void h64_panic(const char *msg) {
	printf("\nPANIC: %s\n", msg);
	for (;;) {
	}
}

#ifdef __C64__
#include <cbm.h>

/* ---------- screen helpers ---------- */
static uint8_t h64_text_color = 1;
/* text screen base (VIC screen RAM as seen by the CPU) */
static volatile uint8_t *h64_screen = (volatile uint8_t *)0x0400;

static inline uint8_t h64_ascii_to_screen(uint8_t c) {
	if (c >= 'a' && c <= 'z') return c - 'a' + 1;  /* upper-case glyphs */
	if (c >= '@' && c <= '_') return c - '@';
	if (c >= 0x20 && c <= 0x3f) return c;
	return 0x20;
}

static void h64_screen_print(int16_t x, int16_t y, const char *s) {
	uint16_t off = (uint16_t)y * 40 + (uint16_t)x;
	volatile uint8_t *scr = h64_screen + off;
	volatile uint8_t *col = (volatile uint8_t *)0xD800 + off;
	while (*s) {
		*scr++ = h64_ascii_to_screen((uint8_t)*s++);
		*col++ = h64_text_color;
	}
}

static void h64_screen_print_num(int16_t x, int16_t y, int16_t n, uint8_t width) {
	char buf[7];
	uint8_t i = 6;
	bool neg = n < 0;
	uint16_t u = neg ? (uint16_t)(-n) : (uint16_t)n;
	buf[6] = 0;
	do {
		buf[--i] = '0' + (u % 10);
		u /= 10;
	} while (u && i > 1);
	if (neg) buf[--i] = '-';
	while (6 - i < width && i > 0) buf[--i] = '0';
	h64_screen_print(x, y, buf + i);
}

static void h64_screen_clear(uint8_t ch) {
	memset((void *)h64_screen, ch, 1000);
	memset((void *)0xD800, h64_text_color, 1000);
}

/* copy into the RAM hidden under the I/O area ($D000-$DFFF) - all ROMs and I/O are banked out meanwhile */
static void h64_copy_under_io(uint16_t dest, const void *src, uint16_t len) {
	uint8_t old;
	__asm__ volatile("sei");
	old = H64_PEEK(0x01);
	H64_POKE(0x01, (old & 0xF8) | 0x04);
	memcpy((void *)dest, src, len);
	H64_POKE(0x01, old);
	__asm__ volatile("cli");
}

/* copy `len` bytes of the character ROM (offset from $D000) into RAM at `dest` */
static void h64_copy_charrom(uint16_t dest, uint16_t offset, uint16_t len) {
	uint8_t old;
	uint16_t i;
	__asm__ volatile("sei");
	old = H64_PEEK(0x01);
	H64_POKE(0x01, (old & 0xF8) | 0x03); /* char ROM visible at $D000, KERNAL stays */
	for (i = 0; i < len; i++) {
		uint8_t v = *(volatile uint8_t *)(0xD000 + offset + i);
		H64_POKE(0x01, (old & 0xF8) | 0x04); /* all RAM */
		*(volatile uint8_t *)(dest + i) = v;
		H64_POKE(0x01, (old & 0xF8) | 0x03);
	}
	H64_POKE(0x01, old);
	__asm__ volatile("cli");
}

static void h64_wait_frame(void) {
	while (H64_PEEK(0xD012) == 251) {
	}
	while (H64_PEEK(0xD012) != 251) {
	}
}
#endif

static void h64_init(void) {
#ifdef __C64__
	/* classic upper-case/graphics character set (llvm-mos starts in lower-case mode) */
	H64_POKE(0xD018, 0x15);
	/* seed RNG from CIA timer + raster */
	h64_seed ^= ((uint16_t)H64_PEEK(0xDC04) << 8) | H64_PEEK(0xD012);
	if (!h64_seed) h64_seed = 0xACE1;
#endif
}

#endif
