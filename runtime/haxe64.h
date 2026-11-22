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

static inline uint8_t h64_ascii_to_screen(uint8_t c) {
	if (c >= 'a' && c <= 'z') return c - 'a' + 1;  /* upper-case glyphs */
	if (c >= '@' && c <= '_') return c - '@';
	if (c >= 0x20 && c <= 0x3f) return c;
	return 0x20;
}

static void h64_screen_print(int16_t x, int16_t y, const char *s) {
	uint16_t off = (uint16_t)y * 40 + (uint16_t)x;
	volatile uint8_t *scr = (volatile uint8_t *)0x0400 + off;
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
	memset((void *)0x0400, ch, 1000);
	memset((void *)0xD800, h64_text_color, 1000);
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
