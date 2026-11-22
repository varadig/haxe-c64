/* haxe64 runtime - included by every generated C file. */
#ifndef HAXE64_H
#define HAXE64_H

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#ifndef __C64__
#include <stdio.h>
#endif

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

/* ---------- Float = 12.4 fixed point (int16_t, -2048..2047, 1/16 steps) ---------- */
static inline int16_t h64_fmul(int16_t a, int16_t b) { return (int16_t)(((int32_t)a * b) >> 4); }
static inline int16_t h64_fdiv(int16_t a, int16_t b) { return b ? (int16_t)(((int32_t)a << 4) / b) : 0; }
static inline int16_t h64_idiv_fix(int16_t a, int16_t b) { return b ? (int16_t)(((int32_t)a << 4) / b) : 0; }
static inline int16_t h64_ftoi(int16_t f) { return f < 0 ? -((-f) >> 4) : (f >> 4); }
static inline int16_t h64_fabs(int16_t f) { return f < 0 ? -f : f; }
static inline int16_t h64_fmin(int16_t a, int16_t b) { return a < b ? a : b; }
static inline int16_t h64_fmax(int16_t a, int16_t b) { return a > b ? a : b; }
static inline int16_t h64_ffloor(int16_t f) { return f >> 4; }
static inline int16_t h64_fceil(int16_t f) { return (f + 15) >> 4; }
static inline int16_t h64_fround(int16_t f) { return (f + 8) >> 4; }
static int16_t h64_fsqrt(int16_t f) {
	/* sqrt(f/16)*16 = sqrt(f*16) */
	uint32_t v, r = 0, bit = 1UL << 20;
	if (f <= 0) return 0;
	v = (uint32_t)f << 4;
	while (bit > v) bit >>= 2;
	while (bit) {
		if (v >= r + bit) { v -= r + bit; r = (r >> 1) + bit; } else r >>= 1;
		bit >>= 2;
	}
	return (int16_t)r;
}
/* quarter sine wave, 16 steps, scaled by 16 */
static const uint8_t h64_sin_q[17] = {0, 2, 3, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 15, 16, 16, 16};
static int16_t h64_fsin(int16_t f) {
	/* f is radians * 16; one turn = 2*pi*16 = 100.5 -> map to 64 steps */
	int16_t i = (int16_t)(((int32_t)f * 64) / 101);
	uint8_t q;
	i &= 63;
	q = (uint8_t)i & 15;
	switch (i >> 4) {
		case 0: return h64_sin_q[q];
		case 1: return h64_sin_q[16 - q];
		case 2: return -h64_sin_q[q];
		default: return -h64_sin_q[16 - q];
	}
}
static int16_t h64_fcos(int16_t f) { return h64_fsin(f + 25); }

/* ---------- temporary strings (concatenation): a ring of 8 buffers, max 39 characters each ---------- */
static char h64_strbuf[8][40];
static uint8_t h64_strnext = 0;
static char *h64_tmpstr(void) {
	char *b = h64_strbuf[h64_strnext];
	h64_strnext = (h64_strnext + 1) & 7;
	return b;
}
static const char *h64_itoa(int16_t v) {
	char *b = h64_tmpstr();
	char t[7];
	uint8_t i = 0, j = 0;
	uint16_t u = v < 0 ? (uint16_t)(-v) : (uint16_t)v;
	do { t[i++] = '0' + (u % 10); u /= 10; } while (u);
	if (v < 0) b[j++] = '-';
	while (i) b[j++] = t[--i];
	b[j] = 0;
	return b;
}
static const char *h64_ftoa(int16_t f) {
	char *b = h64_tmpstr();
	uint16_t u = f < 0 ? (uint16_t)(-f) : (uint16_t)f;
	uint16_t fr = ((u & 15) * 100 + 8) / 16;
	const char *ip = h64_itoa((int16_t)(u >> 4));
	uint8_t j = 0;
	if (f < 0) b[j++] = '-';
	while (*ip && j < 32) b[j++] = *ip++;
	b[j++] = '.';
	b[j++] = '0' + fr / 10;
	b[j++] = '0' + fr % 10;
	b[j] = 0;
	return b;
}
static const char *h64_cat(const char *a, const char *b) {
	char *r = h64_tmpstr();
	uint8_t j = 0;
	while (*a && j < 39) r[j++] = *a++;
	while (*b && j < 39) r[j++] = *b++;
	r[j] = 0;
	return r;
}

/* q = r / 50, r = r % 50 (r passed by pointer). Subtraction loop: no multiply / divide library call
   (for 50 Hz motion |r| is small, so this is 0-6 iterations). */
static inline int16_t h64_take50(int16_t *r) {
	/* volatile: otherwise the compiler turns the loop back into a (slow) division */
	volatile int16_t v = *r;
	int16_t q = 0;
	while (v >= 50) { v -= 50; q++; }
	while (v <= -50) { v += 50; q--; }
	*r = v;
	return q;
}

/* ---------- trace / panic ---------- */
#ifdef __C64__
/* no printf on the C64 (it costs several KB): write through the KERNAL character output */
#include <cbm.h>
static void h64_puts(const char *s) {
	while (*s) {
		char c = *s++;
		if (c >= 'a' && c <= 'z') c -= 32;
		cbm_k_chrout(c == '\n' ? 13 : c);
	}
}
#else
static void h64_puts(const char *s) { fputs(s, stdout); }
#endif
static void h64_trace_str(const char *s) { h64_puts(s); h64_puts("\n"); }
static void h64_trace_int(int16_t v) { h64_trace_str(h64_itoa(v)); }
static void h64_trace_fix(int16_t f) { h64_trace_str(h64_ftoa(f)); }
static void h64_trace_bool(bool b) { h64_trace_str(b ? "true" : "false"); }

static void h64_panic(const char *msg) {
	h64_puts("\nPANIC: ");
	h64_puts(msg);
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
