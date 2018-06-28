#ifndef __asm_h__
#define __asm_h__

#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include <setjmp.h>
#include <stddef.h>
#include <stdio.h>
#include <assert.h>
#include <stdbool.h>
//#include <pthread.h>

#include "curses.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(_WIN32) || defined(__INTEL_COMPILER)
#define INLINE __inline
#elif defined(__STDC_VERSION__) && __STDC_VERSION__>=199901L
#define INLINE inline
#elif defined(__GNUC__)
#define INLINE __inline__
#else
#define INLINE
#endif

#if _BITS == 32

#define MOVSS(a) {src=realAddress(esi,ds); dest=realAddress(edi,es); \
		memmove(dest,src,a); edi+=a; esi+=a; }
#define STOS(a,b) {memcpy (realAddress(edi,es), ((db *)&eax)+b, a); edi+=a;}

#define REP ecx++;while (--ecx != 0)
#define REPE AFFECT_ZF(0);ecx++;while (--ecx != 0 && ZF)
#define REPNE AFFECT_ZF(1);ecx++;while (--ecx != 0 && !ZF)
#define XLAT {al = *raddr(ds,ebx+al);}
#define CMPS(a) \
	{  \
			src=realAddress(esi,ds); dest=realAddress(edi,es); \
			AFFECT_ZF( (*(char*)dest-*(char*)src) ); edi+=a; esi+=a; \
	}

#define SCASB \
	{  \
			dest=realAddress(edi,es); \
			AFFECT_ZF( ( (*(char*)dest)-al) ); edi+=1; \
	}

#define LODS(addr,s) {memcpy (((db *)&eax), &(addr), s);; esi+=s;} // TODO not always si!!!
#define LODSS(a,b) {memcpy (((db *)&eax)+b, realAddress(esi,ds), a); esi+=a;}

#ifdef MSB_FIRST
#define STOSB STOS(1,3)
#define STOSW STOS(2,2)
#else
#define STOSB STOS(1,0)
#define STOSW {if (es>=0xB800) {STOS(2,0);} else {attron(COLOR_PAIR(ah)); mvaddch(edi/160, (edi/2)%80, al); /*attroff(COLOR_PAIR(ah))*/;edi+=2;refresh();}}
#define STOSD STOS(4,0)
#endif

#define LOOP(label) DEC(ecx); JNZ(label)
#define LOOPE(label) --ecx; if (ecx!=0 && ZF) GOTOLABEL(label) //TODO
#define LOOPNE(label) --ecx; if (ecx!=0 && !ZF) GOTOLABEL(label) //TODO

#else
#define MOVSS(a) {src=realAddress(si,ds); dest=realAddress(di,es); \
		memmove(dest,src,a); di+=a; si+=a; }
#define STOS(a,b) {memcpy (realAddress(di,es), ((db *)&eax)+b, a); di+=a;}

#define REP cx++;while (--cx != 0)
#define REPE AFFECT_ZF(0);cx++;while (--cx != 0 && ZF)
#define REPNE AFFECT_ZF(1);cx++;while (--cx != 0 && !ZF)
#define XLAT {al = *raddr(ds,bx+al);}
#define CMPS(a) \
	{  \
			src=realAddress(si,ds); dest=realAddress(di,es); \
			AFFECT_ZF( (*(char*)dest-*(char*)src) ); di+=a; si+=a; \
	}

#define SCASB \
	{  \
			dest=realAddress(di,es); \
			AFFECT_ZF( ( (*(char*)dest)-al) ); di+=1; \
	}

#define LODS(addr,s) {memcpy (((db *)&eax), &(addr), s);; si+=s;} // TODO not always si!!!
#define LODSS(a,b) {memcpy (((db *)&eax)+b, realAddress(si,ds), a); si+=a;}

#ifdef MSB_FIRST
#define STOSB STOS(1,3)
#define STOSW STOS(2,2)
#else
#define STOSB { \
	if (es==0xa000)\
		{ \
SDL_SetRenderDrawColor(renderer, vgaPalette[3*al+2], vgaPalette[3*al+1], vgaPalette[3*al], 255); \
        SDL_RenderDrawPoint(renderer, di%320, di/320); \
    SDL_RenderPresent(renderer); \
    di+=1;} \
	else \
		{STOS(1,0);} \
	}

#define STOSW { \
	if (es==0xB800)  \
		{dd t=(di>>1);attrset(COLOR_PAIR(ah)); mvaddch(t/80, t%80, al); /*attroff(COLOR_PAIR(ah))*/;di+=2;refresh();} \
	else \
		{STOS(2,0);} \
	}
//#define STOSW {if (es!=0xB800) {STOS(2,0);} else {di+=2;}}
#define STOSD STOS(4,0)
#endif

#define LOOP(label) DEC(cx); JNZ(label)
#define LOOPE(label) --cx; if (cx!=0 && ZF) GOTOLABEL(label) //TODO
#define LOOPNE(label) --cx; if (cx!=0 && !ZF) GOTOLABEL(label) //TODO

#endif

#if defined(_PROTECTED_MODE)
#if _BITS == 32
#define raddr(segment,offset) (reinterpret_cast<db *>(offset))
#else
#define raddr(segment,offset) ((db *)&m+(db)(offset)+selectors[segment])
#endif
#else
#define raddr(segment,offset) (((db *)&m + offset + (segment<<4) ))

#endif

#define realAddress(offset, segment) raddr(segment,offset)
#if _BITS == 32
#define offset(segment,name) ((dd)(db*)&m.name)
#else
#define offset(segment,name) offsetof(struct Memory,name)-offsetof(struct Memory,segment)
#endif
#define seg_offset(segment) ((offsetof(struct Memory,segment))>>4)



typedef uint8_t db;
typedef uint16_t dw;
typedef uint32_t dd;
typedef uint64_t dq;

#ifdef MSB_FIRST
typedef struct dblReg {
	db v0;
	db v1;
	db v2;
	db val;
} dblReg;
typedef struct dbhReg {
	db v0;
	db v1;
	db val;
	db v2;
} dbhReg;
typedef struct dwReg {
	dw v0;
	dw val;
} dwReg;
typedef struct dblReg16 {
	db v0;
	db val;
} dblReg16;
typedef struct dbhReg16 {
	db val;
	db v0;
} dbhReg16;
#else
typedef struct dblReg {
	db val;
	db v0;
	db v1;
	db v2;
} dblReg;
typedef struct dbhReg {
	db v0;
	db val;
	db v1;
	db v2;
} dbhReg;
typedef struct dwReg {
	dw val;
	dw v0;
} dwReg;
typedef struct dblReg16 {
	db val;
	db v0;
} dblReg16;
typedef struct dbhReg16 {
	db v0;
	db val;
} dbhReg16;
#endif

typedef struct ddReg {
	dd val;
} ddReg;


typedef union registry32Bits
{
	struct dblReg dbl;
	struct dbhReg dbh;
	struct dwReg dw;
	struct ddReg dd;
} registry32Bits;


typedef struct dwReg16 {
	dw val;
} dwReg16;                                       



typedef union registry16Bits
{
	struct dblReg16 dbl;
	struct dbhReg16 dbh;
	struct dwReg16 dw;
} registry16Bits;


#define VGARAM_SIZE 320*200
#define STACK_SIZE 1024*10
#define HEAP_SIZE 1024*1024 - 16 - STACK_SIZE
#define NB_SELECTORS 128


//#define PUSHAD memcpy (&m.stack[m.stackPointer], &m.eax.dd.val, sizeof (dd)*8); m.stackPointer+=sizeof(dd)*8; assert(m.stackPointer<STACK_SIZE)
//pusha AX, CX, DX, BX, SP, BP, SI, DI
//pushad EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI
#define PUSHAD {PUSH(eax);PUSH(ecx);PUSH(edx);PUSH(ebx); PUSH(esp);PUSH(ebp);PUSH(esi);PUSH(edi);}
//#define POPAD m.stackPointer-=sizeof(dd)*8; memcpy (&m.eax.dd.val, &m.stack[m.stackPointer], sizeof (dd)*8)
#define POPAD {POP(edi);POP(esi);POP(ebp); POP(ebx); POP(ebx);POP(edx);POP(ecx);POP(eax); }

#define PUSHA {PUSH(ax);PUSH(cx);PUSH(dx);PUSH(bx); PUSH(sp);PUSH(bp);PUSH(si);PUSH(di);}
#define POPA {POP(di);POP(si);POP(bp); POP(bx); POP(bx);POP(dx);POP(cx);POP(ax); }

/*
#define PUSH(a) {memcpy (&stack[stackPointer], &a, sizeof (a)); stackPointer+=sizeof(a); assert(stackPointer<STACK_SIZE);\
	log_debug("after push %d\n",stackPointer);}

#define POP(a) {log_debug("before pop %d\n",stackPointer); \
	stackPointer-=sizeof(a); memcpy (&a, &stack[stackPointer], sizeof (a));}
#define PUSH(a) {stackPointer-=sizeof(a); memcpy (&m.stack[stackPointer], &a, sizeof (a));  assert(stackPointer>8);}
*/
#define PUSH(a) {dd t=a;stackPointer-=sizeof(a); \
		memcpy (raddr(ss,stackPointer), &t, sizeof (a)); \
		assert((raddr(ss,stackPointer) - ((db*)&m.stack))>8);}

#define POP(a) { memcpy (&a, raddr(ss,stackPointer), sizeof (a));stackPointer+=sizeof(a);}


#define AFFECT_ZF(a) {ZF=((a)==0);}
#define AFFECT_CF(a) {CF=(a);}
//#define ISNEGATIVE(a) (a & (1 << (sizeof(a)*8-1)))
//#define AFFECT_SF(a) {SF=ISNEGATIVE(a);}
#define AFFECT_SF(f, a) {SF=( (a)&(1 << sizeof(f)*8 - 1) );}
#define ISNEGATIVE(f,a) ( (a) & (1 << (sizeof(f)*8-1)) )

#define CMP(a,b) {dd t=(a-b)& MASK[sizeof(a)]; \
		AFFECT_CF((t)>(a)); \
		AFFECT_ZF(t); \
		AFFECT_SF(a,t);}

#define OR(a,b) {a=a|b; \
		AFFECT_ZF(a); \
		AFFECT_SF(a,a); \
		AFFECT_CF(0);}

#define XOR(a,b) {a=a^b; \
		AFFECT_ZF(a); \
		AFFECT_SF(a,a) \
		AFFECT_CF(0);}

#define AND(a,b) {a=a&b; \
		AFFECT_ZF(a); \
		AFFECT_SF(a,a) \
		AFFECT_CF(0);}

#define NEG(a) {AFFECT_CF((a)!=0); \
		a=-a;\
		AFFECT_ZF(a); \
		AFFECT_SF(a,a)}

#define TEST(a,b) {AFFECT_ZF((a)&(b)); \
		AFFECT_CF(0); \
		AFFECT_SF(a,(a)&(b))}

#define SHR(a,b) {if (b) {CF=(a>>(b-1))&1;\
		a=a>>b;\
		AFFECT_ZF(a);\
		AFFECT_SF(a,a)}}

#define SHL(a,b) {if (b) {CF=(a) & (1 << (sizeof(a)*8-b));\
		a=a<<b;\
		AFFECT_ZF(a);\
		AFFECT_SF(a,a)}}

#define ROR(a,b) {CF=((a)>>(shiftmodule(a,b)-1))&1;\
		a=((a)>>(shiftmodule(a,b)) | a<<(sizeof(a)*8-(shiftmodule(a,b))));}

#define ROL(a,b) {CF=((a)>>(sizeof(a)*8-(shiftmodule(a,b))))&1;\
		a=(((a)<<(shiftmodule(a,b))) | (a)>>(sizeof(a)*8-(shiftmodule(a,b))));}

#define SHRD(a,b,c) {/*TODO CF=(a) & (1 << (sizeof(f)*8-b));*/ \
			int shift = c&(2*bitsizeof(a)-1); \
			dd a1=a>>shift; \
			a=a1 | ( (b& ((1<<shift)-1) ) << (bitsizeof(a)-shift) ); \
		AFFECT_ZF(a);\
		AFFECT_SF(a,a)} //TODO optimize

#define SAR(a,b) {bool sign = (a & (1 << (sizeof(a)*8-1)))!=0; int shift = (bitsizeof(a)-b);shift = shift>0?shift:0;\
	dd sigg=shift<(bitsizeof(a))?( (sign?-1:0)<<shift):0; a = b>bitsizeof(a)?0:a; a=sigg | (a >> b);}  // TODO optimize
//#define SAR(a,b) { a= ((int32_t)a)>>b;}  // TODO optimize

#define READDDp(a) ((dd *) &m.a)
#define READDWp(a) ((dw *) &m.a)
#define READDBp(a) ((db *) &m.a)

#define READDD(a) (a)

#ifdef MSB_FIRST
#define READDBhW(a) (*(((db *) &a)+0))
#define READDBhD(a) (*(((db *) &a)+2))
#define READDBlW(a) (*(((db *) &a)+1))
#define READDBlD(a) (*(((db *) &a)+3))
#else
#define READDBhW(a) (*(((db *) &a)+1))
#define READDBhD(a) (*(((db *) &a)+1))
#define READDBlW(a) (*(((db *) &a)))
#define READDBlD(a) (*(((db *) &a)))
#endif

#define READDW(a) (*((dw *) &m.a.dw.val))
#define READDBh(a) (*((db *) &m.a.dbh.val))
#define READDBl(a) (*((db *) &m.a.dbl.val))

#define AAD {al = al + (ah * 10) & 0xFF; ah = 0;} //TODO

#define ADD(a,b) {dd t=(a+b)& MASK[sizeof(a)]; \
		AFFECT_CF((t)<(a)); \
		a=t; \
		AFFECT_ZF(a); \
		AFFECT_SF(a,a);}

#define SUB(a,b) {dd t=(a-b)& MASK[sizeof(a)]; \
		AFFECT_CF((t)>(a)); \
		a=t; \
		AFFECT_ZF(a); \
		AFFECT_SF(a,a);}

#define ADC(a,b) {dd t=(a+b+CF)& MASK[sizeof(a)]; \
		AFFECT_CF((t)<(a)); \
		a=t; \
		AFFECT_ZF(a); \
		AFFECT_SF(a,a);}

#define SBB(a,b) {dd t=(a-b-CF)& MASK[sizeof(a)]; \
		AFFECT_CF((t)>(a)); \
		a=t; \
		AFFECT_ZF(a); \
		AFFECT_SF(a,a);} 

// TODO: should affects OF, SF, ZF, AF, and PF
#define INC(a) {a+=1; \
		AFFECT_ZF(a);\
		AFFECT_SF(a,a);} 

#define DEC(a) {a-=1; \
		AFFECT_ZF(a);\
		AFFECT_SF(a,a);} 

#define IMUL1_1(a) {ax=(int16_t)((int8_t)al)*((int8_t)(a));}
#define IMUL1_2(a) {int32_t t=(int32_t)((int16_t)ax)*((int16_t)(a));ax=t;dx=t>>16;}
#define IMUL1_4(a) {int64_t t=(int64_t)((int32_t)eax)*((int32_t)(a));eax=t;edx=t>>32;}
#define IMUL2_2(a,b) {a = ((int16_t)(a)) * ((int16_t)(b));}
#define IMUL2_4(a,b) {a = ((int32_t)(a)) * ((int32_t)(b));}
#define IMUL3_2(a,b,c) {a = ((int16_t)(b)) * ((int16_t)(c));}
#define IMUL3_4(a,b,c) {a = ((int32_t)(b)) * ((int32_t)(c));}

#define MUL1_1(a) {ax=(dw)al*(a);}
#define MUL1_2(a) {dd t=(dd)ax*(a);ax=t;dx=t>>16;}
#define MUL1_4(a) {uint64_t t=(dq)eax*(a);eax=t;edx=t>>32;}
#define MUL2_2(a,b) {a *= (b);}
#define MUL2_4(a,b) {a *= (b);}
#define MUL3_2(a,b,c) {a = (b) * (c);}
#define MUL3_4(a,b,c) {a = (b) * (c);}

#define IDIV1(a) {int16_t t=ax;al=t/((int8_t)a); ah=t%((int8_t)a);}
#define IDIV2(a) {int32_t t=(((int32_t)(int16_t)dx)<<16)|ax; ax=t/((int16_t)a);dx=t%((int16_t)a);}
#define IDIV4(a) {int64_t t=(((int64_t)(int32_t)edx)<<32)|eax;eax=t/((int32_t)a);edx=t%((int32_t)a);}

#define DIV1(a) {dw t=ax;al=t/(a);ah=t%(a);}
#define DIV2(a) {dd t=((((dd)dx)<<16)|ax);ax=t/(a);dx=t%(a);}
#define DIV4(a) {uint64_t t=((((dq)edx)<<32)|eax);eax=t/(a);edx=t%(a);}

#define NOT(a) a= ~(a);// AFFECT_ZF(a) //TODO
#define SETNZ(a) a= (!ZF)&1; //TODO
#define SETZ(a) a= (ZF)&1; //TODO
#define SETB(a) a= (CF)&1; //TODO


#define JE(label) if (ZF) GOTOLABEL(label)
#define JZ(label) JE(label)

#define JNE(label) if (!ZF) GOTOLABEL(label)
#define JNZ(label) JNE(label)

#define JNB(label) if (!CF) GOTOLABEL(label)
#define JAE(label) JNB(label)
#define JNC(label) JNB(label)

#define JGE(label) if (!SF) GOTOLABEL(label) // TODO
#define JG(label) if (!ZF && !SF) GOTOLABEL(label) // TODO

#define JLE(label) if (ZF || SF) GOTOLABEL(label) // TODO
#define JL(label) if (SF) GOTOLABEL(label) // TODO

#define JCXZ(label) if (cx == 0) GOTOLABEL(label) // TODO
#define JECXZ(label) if (ecx == 0) GOTOLABEL(label) // TODO


#define JB(label) if (CF) GOTOLABEL(label)
#define JC(label) JB(label)
#define JNAE(label) JB(label)

#define JA(label) if (!CF && !ZF) GOTOLABEL(label)
#define JNBE(label) JA(label)

#define JS(label) if (SF) GOTOLABEL(label)
#define JNS(label) if (!SF) GOTOLABEL(label)

#define JNA(label) if (CF || ZF) GOTOLABEL(label)
#define JBE(label) JNA(label)

#if DEBUG >= 3
#define MOV(dest,src) {log_debug("%x <= (%x)\n",&dest, src); dest = src;}
#else
#define MOV(dest,src) {dest = src;}
#endif

#define LFS(dest,src) dest = src; fs= *(dw*)((db*)&(src) + sizeof(dest))
#define LES(dest,src) dest = src; es = *(dw*)((db*)&(src) + sizeof(dest))
#define LGS(dest,src) dest = src; gs = *(dw*)((db*)&(src) + sizeof(dest))
#define LDS(dest,src) dest = src; ds = *(dw*)((db*)&(src) + sizeof(dest))

#define MOVZX(dest,src) dest = src
#define MOVSX(dest,src) if (ISNEGATIVE(src,src)) { dest = ((-1 ^ (( 1 << (sizeof(src)*8) )-1)) | src ); } else { dest = src; }

#define bitsizeof(dest) (8*sizeof(dest))
#define shiftmodule(dest,bit) (bit&(bitsizeof(dest)-1))
#define nthbit(dest,bit) (1 << shiftmodule(dest,bit))
#define BT(dest,src) {CF = dest & nthbit(dest,src);} //TODO
#define BTS(dest,src) {CF = dest & nthbit(dest,src); dest |= nthbit(dest,src);}
#define BTC(dest,src) {CF = dest & nthbit(dest,src); dest ^= nthbit(dest,src);}
#define BTR(dest,src) {CF = dest & nthbit(dest,src); dest &= ~(nthbit(dest,src));}

// LEA - Load Effective Address
#define LEA(dest,src) dest = src

#define XCHG(dest,src) {dd t = (dd) dest; dest = src; src = t;}//std::swap(dest,src); //TODO


#define MOVS(dest,src,s)  {dest=src; dest+=s; src+=s; }
//                        {memmove(dest,src,s); dest+=s; src+=s; } \


#define CMPSB CMPS(1)
#define CBW ah = ((int8_t)al) < 0?-1:0 // TODO
#define CWD dx = ((int16_t)ax) < 0?-1:0
#define CWDE {*(((dw*)&eax)+1) = ((int16_t)ax) < 0?-1:0;}

// MOVSx (DF FLAG not implemented)

#define MOVSB MOVSS(1)
#define MOVSW MOVSS(2)
#define MOVSD MOVSS(4)

/*
#define REP_MOVSS(b) MOVSS(b,cx)
#define REP_MOVS(dest,src) while (cx-- > 0) {MOVS(dest,src);}
#define REP_MOVSB REP_MOVSS(1)
#define REP_MOVSW REP_MOVSS(2)
#define REP_MOVSD REP_MOVSS(4)
*/



//#define REP_STOSB while (cx>0) { STOSB; --cx;}
//#define REP_STOSW while (cx>0) { STOSW; --cx;}
//#define REP_STOSD while (cx>0) { STOSD; --cx;}


#ifdef MSB_FIRST
#define LODSB LODSS(1,3)
#define LODSW LODSS(2,2)
#else
#define LODSB LODSS(1,0)
#define LODSW LODSS(2,0)
#endif
#define LODSD LODSS(4,0)

/*
#define REP_LODS(a,b) for (i=0; i<ecx; i++) { LODS(a,b); }

#ifdef MSB_FIRST
#define REP_LODSB REP_LODS(1,3)
#define REP_LODSW REP_LODS(2,2)
#else
#define REP_LODSB REP_LODS(1,0)
#define REP_LODSW REP_LODS(2,0)
#define REP_LODSD REP_LODS(4,0)
#endif
*/

// JMP - Unconditional Jump
#define JMP(label) GOTOLABEL(label)
#define GOTOLABEL(a) {_source=__LINE__;goto a;}


#define CLD DF=0
#define STD DF=1

#define STC CF=1 //TODO
#define CLC CF=0 //TODO
#define CMC CF ^= 1 //TODO

struct _STATE;
void stackDump(_STATE* state);
void hexDump (void *addr, int len);
void asm2C_INT(_STATE* state, int a);
void asm2C_init();
void asm2C_printOffsets(unsigned int offset);

// directjeu nosetjmp,2
// directmenu
#define INT(a) asm2C_INT(_state,a); TESTJUMPTOBACKGROUND

#define TESTJUMPTOBACKGROUND  //if (jumpToBackGround) CALL(moveToBackGround);

void asm2C_OUT(int16_t address, int data);
#define OUT(a,b) asm2C_OUT(a,b)
int8_t asm2C_IN(int16_t data);
#define IN(a,b) a = asm2C_IN(b); TESTJUMPTOBACKGROUND

#define STI // TODO: STI not implemented
#define CLI // TODO: STI not implemented
//#define PUSHF {dd t = CF+(ZF<<1)+(DF<<2)+(SF<<3); PUSH(t);}
//#define POPF {dd t; POP(t); CF=t&1; ZF=(t>>1)&1; DF=(t>>2)&1; SF=(t>>3)&1;}

#define PUSHF {PUSH( (dd) ((CF?1:0)|(PF?4:0)|(AF?0x10:0)|(ZF?0x40:0)|(SF?0x80:0)|(DF?0x200:0)|(OF?0x400:0)) );}
#define POPF {dd t; POP(t); CF=t&1;  PF=(t&4);AF=(t&0x10);ZF=(t&0x40);SF=(t&0x80);DF=(t&0x200);OF=(t&0x400);}
#define NOP

/*
#define CALLF(label) {log_debug("before callf %d\n",stackPointer);PUSH(cs);CALL(label);}
#define CALL(label) \
	{ log_debug("before call %d\n",stackPointer); db tt='x';  \
	if (setjmp(jmpbuffer) == 0) { \
		PUSH(jmpbuffer); PUSH(tt);\
		JMP(label); \
	} }

#define RET {log_debug("before ret %d\n",stackPointer); db tt=0; POP(tt); if (tt!='x') {log_error("Stack corrupted.\n");exit(1);} \
 		POP(jmpbuffer); log_debug("after ret %d\n",stackPointer);longjmp(jmpbuffer, 0);}

#define RETN RET
#define RETF {log_debug("before ret %d\n",stackPointer); db tt=0; POP(tt); if (tt!='x') {log_error("Stack corrupted.\n");exit(1);} \
 		POP(jmpbuffer); stackPointer-=2; log_debug("after retf %d\n",stackPointer);longjmp(jmpbuffer, 0);}
*/
#define CALLF(label) {PUSH(cs);CALL(label);}
/*
#define CALL(label) \
	{ db tt='x';  \
	if (setjmp(jmpbuffer) == 0) { \
		PUSH(jmpbuffer); PUSH(tt);\
		JMP(label); \
	} }

#define RET {db tt=0; POP(tt); if (tt!='x') {log_error("Stack corrupted.\n");exit(1);} \
 		POP(jmpbuffer); longjmp(jmpbuffer, 0);}
#define RETF {db tt=0; POP(tt); if (tt!='x') {log_error("Stack corrupted.\n");exit(1);} \
 		POP(jmpbuffer); stackPointer-=2; longjmp(jmpbuffer, 0);}
*/
#define CALL(label) \
	{ PUSH(eip); ++_state->_indent;log_spaces(_state->_str,_state->_indent);\
	mainproc(label, _state); \
	}

#define RET {POP(eip);--_state->_indent;log_spaces(_state->_str,_state->_indent);return;}

#define RETN RET
#define IRET RET
#define RETF {dw tt=0; POP(tt); RET;}

// ---------unimplemented
#define AAA log_debug("unimplemented\n");
#define AAM log_debug("unimplemented\n");
#define AAS log_debug("unimplemented\n");
#define BSR(a,b) log_debug("unimplemented\n");
#define BSWAP(a) log_debug("unimplemented\n");
#define CDQ log_debug("unimplemented\n");
#define CMPSD log_debug("unimplemented\n");
#define CMPSW log_debug("unimplemented\n");
#define CMPXCHG log_debug("unimplemented\n");
#define CMPXCHG8B(a) log_debug("unimplemented\n"); // not in dosbox
#define DAA log_debug("unimplemented\n");
#define DAS log_debug("unimplemented\n");
#define RCL(a,b) log_debug("unimplemented\n");
#define RCR(a,b) log_debug("unimplemented\n");
#define SCASD log_debug("unimplemented\n");
#define SCASW log_debug("unimplemented\n");
#define SHLD(a,b,c) log_debug("unimplemented\n");
#define XADD(a,b) log_debug("unimplemented\n");

#define CMOVA(a,b) log_debug("unimplemented\n"); // not in dosbox
#define CMOVB(a,b) log_debug("unimplemented\n");
#define CMOVBE(a,b) log_debug("unimplemented\n");
#define CMOVG(a,b) log_debug("unimplemented\n");
#define CMOVGE(a,b) log_debug("unimplemented\n");
#define CMOVL(a,b) log_debug("unimplemented\n");
#define CMOVLE(a,b) log_debug("unimplemented\n");
#define CMOVNB(a,b) log_debug("unimplemented\n");
#define CMOVNO(a,b) log_debug("unimplemented\n");
#define CMOVNP(a,b) log_debug("unimplemented\n");
#define CMOVNS(a,b) log_debug("unimplemented\n");
#define CMOVNZ(a,b) log_debug("unimplemented\n");
#define CMOVO(a,b) log_debug("unimplemented\n");
#define CMOVP(a,b) log_debug("unimplemented\n");
#define CMOVS(a,b) log_debug("unimplemented\n");
#define CMOVZ(a,b) log_debug("unimplemented\n");

#define JNO(x) log_debug("unimplemented\n");
#define JNP(x) log_debug("unimplemented\n");
#define JO(x) log_debug("unimplemented\n");
#define JP(x) log_debug("unimplemented\n");
#define LOOPW(x) log_debug("unimplemented\n");
#define LOOPWE(x) log_debug("unimplemented\n");
#define LOOPWNE(x) log_debug("unimplemented\n");
#define SETBE(x) log_debug("unimplemented\n");
#define SETL(x) log_debug("unimplemented\n");
#define SETLE(x) log_debug("unimplemented\n");
#define SETNB(x) log_debug("unimplemented\n");
#define SETNBE(x) log_debug("unimplemented\n");
#define SETNL(x) log_debug("unimplemented\n");
#define SETNLE(x) log_debug("unimplemented\n");
#define SETNO(x) log_debug("unimplemented\n");
#define SETNP(x) log_debug("unimplemented\n");
#define SETNS(x) log_debug("unimplemented\n");
#define SETO(x) log_debug("unimplemented\n");
#define SETP(x) log_debug("unimplemented\n");
#define SETS(x) log_debug("unimplemented\n");
// ---------

#ifdef __LIBSDL2__
#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#endif

#ifdef __LIBRETRO__
#include "libretro.h"
extern retro_log_printf_t log_cb;
#else
extern FILE * logDebug;
#endif

void log_error(const char *fmt, ...);
void log_debug(const char *fmt, ...);
void log_info(const char *fmt, ...);
void log_debug2(const char *fmt, ...);

void log_spaces(char * s, int n) 
{ 
	memset(s, ' ', n); 
	*(s+n) = 0; 
}

#if DEBUG==2
    #define R(a) {log_debug("l:%d:%s%s\n",__LINE__,_state->_str,#a);}; a
#elif DEBUG>=3
    #define R(a) {log_debug("l:%x:%d:%s%s eax: %x ebx: %x ecx: %x edx: %x ebp: %x ds: %x esi: %x es: %x edi: %x fs: %x\n",0/*pthread_self()*/,__LINE__,_state->_str,#a, \
eax, ebx, ecx, edx, ebp, ds, esi, es, edi, fs);} \
	a 
#else
    #define R(a) a
#endif

bool is_little_endian();

#if defined(_MSC_VER)
#define SWAP16 _byteswap_ushort
#define SWAP32 _byteswap_ulong
#else
#define SWAP16(x) ((uint16_t)(                  \
			   (((uint16_t)(x) & 0x00ff) << 8)      | \
			   (((uint16_t)(x) & 0xff00) >> 8)        \
			   ))
#define SWAP32(x) ((uint32_t)(           \
			   (((uint32_t)(x) & 0x000000ff) << 24) | \
			   (((uint32_t)(x) & 0x0000ff00) <<  8) | \
			   (((uint32_t)(x) & 0x00ff0000) >>  8) | \
			   (((uint32_t)(x) & 0xff000000) >> 24)   \
			   ))
#endif

#ifdef __cplusplus
}
#endif

#endif
