/*
    Masm 6.1 EBNF
*/
grammar masm61;
@ header{ 
 	 package com.xor.Syntax;
 	 }
module
  :  directiveList?  endDir
  ; 
lineReminder
  : comment? endOfLine
  ; 
eqDir
  : id '=' immExpr lineReminder
  ; 
addOp
  : '+' | '-'
  ; 
aExpr
  : term | aExpr  '&&' term
  ; 
altId
  : id
  ; 
arbitraryText
  : charList
  ; 
asmInstruction
  : mnemonic  exprList? 
  ; 
assumeDir
  : 'ASSUME' assumeList lineReminder| 'ASSUME NOTHING' lineReminder
  ; 
assumeList 
  : assumeRegister| assumeList  ',' assumeRegister
  ; 
assumeReg
  : register ':' assumeVal
  ; 
assumeRegister
  : assumeSegReg| assumeReg
  ; 
assumeSegReg
  : segmentRegister ':' assumeSegVal
  ; 
assumeSegVal
  : frameExpr| 'NOTHING' | 'ERROR' 
  ; 
assumeVal
  : qualifiedType| 'NOTHING' | 'ERROR' 
  ; 
bcdConst
  :  sign?  decNumber
  ; 
binaryOp
  : '=='| '!='| '>='| '<='| '>'| '<'| '&' 
  ; 
eqconstExpr
  : '=' constExpr
  ;
bitDef
  : bitFieldId ':' bitFieldSize eqconstExpr?
  ; 
bitDefList
  : bitDef| bitDefList  ',' lineReminder?  bitDef
  ; 
bitFieldId 
  : id 
  ; 
bitFieldSize
  : constExpr
  ; 
ifcexpr
  : '.IF' cExpr
  ;
blockStatements
  : directiveList| '.CONTINUE' ifcexpr? | '.BREAK' ifcexpr?
  ; 
bool
  : 'TRUE' | 'FALSE'
  ; 
byteRegister
  : 'AL' | 'AH' | 'BL' | 'BH' | 'CL' | 'CH' | 'DL' | 'DH' 
  ; 
cExpr
  : aExpr| cExpr ':' aExpr
  ; 
charList
  : character| charList character
  ; 
className
  : string
  ; 
commDecl
  :  nearfar?   langType?  id ':' commType eqconstExpr?
  ; 
commDir
  : 'COMM' commList lineReminder
  ; 
commentDir
  : 'COMMENT' delimiter text text delimiter text lineReminder
  ; 
commList
  : commDecl| commList  ',' commDecl
  ; 
commType
  : type| constExpr
  ; 
constant
  : digits  radixOverride? 
  ; 
constExpr
  : expr
  ; 
contextDir
  : 'PUSHCONTEXT' contextItemList lineReminder| 'POPCONTEXT' contextItemList lineReminder
  ; 
contextItem
  : 'ASSUMES' | 'RADIX' | 'LISTING' | 'CPU' | 'ALL' 
  ; 
contextItemList
  : contextItem| contextItemList  ',' contextItem
  ; 
controlBlock
  : whileBlock| repeatBlock
  ; 
controlDir
  : controlIf| controlBlock
  ; 
controlElseif
  : '.ELSEIF' cExpr lineReminder directiveList controlElseif? 
  ; 

elsedirectiveList
  : '.ELSE' lineReminder directiveList
  ;
controlIf
  : '.IF' cExpr lineReminder directiveList controlElseif? elsedirectiveList? '.ENDIF' lineReminder
  ; 
coprocessor
  : '.8087' | '.287' | '.387' | '.NO87' 
  ; 
crefDir
  : crefOption lineReminder
  ; 
crefOption
  : '.CREF' | '.XCREF' idList? | '.NOCREF' idList? 
  ; 
cxzExpr
  : expr| '!' expr| expr  '==' expr| expr  '!=' expr
  ; 
dataDecl
  : 'DB' | 'DW' | 'DD' | 'DF' | 'DQ' | 'DT' | dataType | typeId
  ; 
dataDir
  :  id?  dataItem lineReminder
  ; 
dataItem
  : dataDecl scalarInstList| structTag structInstList| typeId structInstList| unionTag structInstList| recordTag recordInstList
  ; 
dataType
  : 'BYTE' | 'SBYTE' | 'WORD' | 'SWORD' | 'DWORD' | 'SDWORD' | 'FWORD' | 'QWORD' | 'TBYTE' | 'REAL4' | 'REAL8' | 'REAL10' 
  ; 
decNumber
  : decdigit| decNumber decdigit
  ; 
digits
  : decdigit| digits decdigit| digits hexdigit
  ; 
directive
  : generalDir| segmentDef
  ; 
directiveList
  : directive| directiveList directive
  ; 
distance
  : nearfar| 'NEAR16' | 'NEAR32' | 'FAR16' | 'FAR32' 
  ; 
e01
  : e01 orOp e02| e02
  ; 
e02
  : e02 'AND' e03| e03
  ; 
e03
  : 'NOT' e04| e04
  ; 
e04
  : e04 relOp e05| e05
  ; 
e05
  : e05 addOp e06| e06
  ; 
e06
  : e06 mulOp e07| e06 shiftOp e07| e07
  ; 
e07
  : e07 addOp e08| e08
  ; 
e08
  : 'HIGH' e09| 'LOW' e09| 'HIGHWORD' e09| 'LOWWORD' e09| e09
  ; 
e09
  : 'OFFSET' e10| 'SEG' e10| 'LROFFSET' e10| 'TYPE' e10| 'THIS' e10| e09 'PTR' e10| e09 ':' e10| e10
  ; 
e10
  : e10 '.' e11| e10  expr? | e11
  ; 
e11
  : '(' expr ')'|  expr? | 'WIDTH' id| 'MASK' id| 'SIZE' sizeArg| 'SIZEOF' sizeArg| 'LENGTH' id| 'LENGTHOF' id | recordConst| string| constant| type| id| '$'| segmentRegister| register| 'ST' | 'ST' '(' expr ')'
  ; 
echoDir
  : 'ECHO' arbitraryText lineReminder '%OUT' arbitraryText lineReminder
  ; 
elseifBlock
  : elseifStatement lineReminder directiveList elseifBlock? 
  ; 
elseifStatement
  : 'ELSEIF' constExpr| 'ELSEIFE' constExpr| 'ELSEIFB' textItem| 'ELSEIFNB' textItem | 'ELSEIFDEF' id| 'ELSEIFNDEF' id| 'ELSEIFDIF' textItem ',' textItem| 'ELSEIFDIFI' textItem ',' textItem| 'ELSEIFIDN' textItem ',' textItem| 'ELSEIFIDNI' textItem ',' textItem| 'ELSEIF1' | 'ELSEIF2' 
  ; 
endDir
  : 'END' immExpr?  lineReminder?
  ; 
endpDir
  : procId 'ENDP' lineReminder
  ; 
endsDir
  : id 'ENDS' lineReminder
  ; 
equDir
  : textMacroId 'EQU' equType lineReminder
  ; 
equType
  : immExpr| textLiteral
  ; 
errorDir
  : errorOpt lineReminder
  ; 
errorOpt
  : '.ERR' textItem? | '.ERRE' constExpr optText? | '.ERRNZ' constExpr optText? | '.ERRB' textItem optText? | '.ERRNB' textItem optText? | '.ERRDEF' id  optText? | '.ERRNDEF' id optText? | '.ERRDIF' textItem ',' textItem  optText? | '.ERRDIFI' textItem ',' textItem  optText? | '.ERRIDN' textItem ',' textItem  optText? | '.ERRIDNI' textItem ',' textItem  optText? | '.ERR1' textItem? | '.ERR2' textItem?  
  ; 
exitDir
  : '.EXIT' expr?  lineReminder
  ; 
exitmDir
  : 'EXITM' | 'EXITM' textItem
  ; 
exponent
  : 'E'  sign?  decNumber
  ; 
expr
  : 'SHORT' e05| '.TYPE' e01| 'OPATTR' e01| e01
  ; 
exprList
  : expr| exprList  ','  expr
  ; 
altIdq
  : '(' altId ')'
  ;
externDef
  :  langType?  id altIdq? ':' externType
  ; 
externDir
  : externKey externList lineReminder
  ; 
externKey
  : 'EXTRN' | 'EXTERN' | 'EXTERNDEF' 
  ; 
externList
  : externDef| externList  ',' lineReminder?  externDef
  ; 
externType
  : 'ABS' | qualifiedType
  ; 
fieldAlign
  : constExpr
  ; 
fieldInit
  :  initValue? | structInstance
  ; 
fieldInitList
  : fieldInit| fieldInitList ','  lineReminder?  fieldInit
  ; 
fileChar
  : delimiter
  ; 
fileCharList
  : fileChar| fileCharList fileChar
  ; 
fileSpec
  : fileCharList| textLiteral
  ; 
flagName
  : 'ZERO? '| 'CARRY?' | 'OVERFLOW?'|'SIGN?'| 'PARITY?'
  ; 
floatNumber 
  :  sign?  decNumber '.' decNumber?   exponent? | digits 'R'| digits 'r'
  ; 
forcDir
  : 'FORC' | 'IRPC' 
  ; 
forDir
  : 'FOR' | 'IRP' 
  ; 
dotdotforParmType
  : ':' forParmType
  ;
forParm
  : id dotdotforParmType?
  ; 
forParmType
  : 'REQ' | '=' textLiteral
  ; 
frameExpr
  : 'SEG' id | 'DGROUP' ':' id| segmentRegister ':' id| id
  ; 
generalDir
  : modelDir | segOrderDir | nameDir| includeLibDir | commentDir| groupDir | assumeDir| structDir | recordDir | typedefDir| externDir | publicDir | commDir | protoTypeDir| equDir | eqDir | textDir| contextDir | optionDir | processorDir| radixDir | titleDir | pageDir | listDir | crefDir | echoDir| ifDir | errorDir | includeDir | macroDir | macroCall | macroRepeat | purgeDir| macroWhile | macroFor | macroForc| aliasDir
  ; 
aliasDir
  : 'ALIAS'
  ;
gpRegister
  : 'AX' | 'EAX' | 'BX' | 'EBX' | 'CX' | 'ECX' | 'DX' | 'EDX'| 'BP' | 'EBP' | 'SP' | 'ESP' | 'DI' | 'EDI' | 'SI' | 'ESI'
  ; 
groupDir 
  : groupId 'GROUP' segIdList
  ; 
groupId
  : id
  ; 
idList
  : id| idList ',' id
  ; 
ifDir
  : ifStatement lineReminder directiveList elseifBlock? elsedirectiveList? 'ENDIF' lineReminder
  ; 
ifStatement
  : 'IF' constExpr| 'IFE' constExpr| 'IFB' textItem| 'IFNB' textItem| 'IFDEF' id| 'IFNDEF' id| 'IFDIF' textItem ',' textItem| 'IFDIFI' textItem ',' textItem| 'IFIDN' textItem ',' textItem| 'IFIDNI' textItem ',' textItem| 'IF1' | 'IF2' 
  ; 
immExpr
  : expr
  ; 
includeDir
  : 'INCLUDE' fileSpec lineReminder
  ; 
includeLibDir
  : 'INCLUDELIB' fileSpec lineReminder
  ; 
initValue
  : immExpr| string| '?'| constExpr  'DUP' '(' scalarInstList ')'| floatNumber| bcdConst
  ; 
inSegDir
  :  labelDef?  inSegmentDir
  ; 
inSegDirList
  : inSegDir | inSegDirList inSegDir
  ; 
inSegmentDir
  : instruction| dataDir| controlDir| startupDir| exitDir| offsetDir| labelDir| procDir  localDirList?   inSegDirList?  endpDir| invokeDir| generalDir 
  ; 
instrPrefix
  : 'REP' | 'REPE' | 'REPZ' | 'REPNE' | 'REPNZ' | 'LOCK' 
  ; 
instruction
  :  instrPrefix?  asmInstruction
  ; 
invokeArg
  : register '::' register| expr| 'ADDR' expr
  ; 
commainvokeList
  : ',' lineReminder? invokeList
  ;
invokeDir
  : 'INVOKE' expr commainvokeList? lineReminder
  ; 
invokeList
  : invokeArg| invokeList  ',' lineReminder?  invokeArg
  ; 
labelDef
  : id ':' | id '::' | '@@:'
  ; 
labelDir
  : id 'LABEL' qualifiedType lineReminder
  ; 
langType
  : 'C' | 'PASCAL' | 'FORTRAN' | 'BASIC' | 'SYSCALL' | 'STDCALL' 
  ; 
listDir
  : listOption lineReminder
  ; 
listOption
  : '.LIST' | '.NOLIST' | '.XLIST' | '.LISTALL' | '.LISTIF' | '.LFCOND' | '.NOLISTIF' | '.SFCOND' | '.TFCOND' | '.LISTMACROALL' | '.LALL' | '.NOLISTMACRO' | '.SALL' | '.LISTMACRO' | '.XALL' 
  ; 
localDef
  : 'LOCAL' idList lineReminder
  ; 
localDir
  : 'LOCAL' parmList lineReminder
  ; 
localDirList
  : localDir| localDirList localDir
  ; 
localList
  : localDef| localList localDef
  ; 
macroArg
  : '%' constExpr| '%' textMacroId| '%' macroFuncId '(' macroArgList ')'| string| arbitraryText| '<' arbitraryText '>'
  ; 
macroArgList
  : macroArg| macroArgList  ',' macroArg
  ; 
macroBody
  :  localList? macroStmtList
  ; 
macroCall
  : id macroArgList lineReminder| id  '(' macroArgList ')'
  ; 
macroDir
  : id 'MACRO' macroParmList?  lineReminder macroBody 'ENDM' lineReminder
  ; 
macroFor
  : forDir forParm  ',' '<' macroArgList '>' lineReminder macroBody 'ENDM' lineReminder
  ; 
macroForc
  : forcDir id  ',' textLiteral lineReminder macroBody 'ENDM' lineReminder
  ; 
macroFuncId
  : id
  ; 
macroId
  : macroProcId| macroFuncId
  ; 
macroIdList
  : macroId| macroIdList  ','  macroId
  ; 
macroLabel
  : id
  ; 
dotdotparmType
  : ':' parmType
  ;
macroParm
  : id dotdotparmType?
  ; 
macroParmList
  : macroParm| macroParmList  ',' lineReminder?  macroParm
  ; 
macroProcId
  : id
  ; 
macroRepeat
  : repeatDir constExpr lineReminder macroBody 'ENDM' lineReminder
  ; 
macroStmt
  : directive| exitmDir| ':' macroLabel| 'GOTO' macroLabel
  ; 
macroStmtList
  : macroStmt lineReminder| macroStmtList macroStmt lineReminder
  ; 
macroWhile
  : 'WHILE' constExpr lineReminder macroBody 'ENDM' lineReminder
  ; 
mapType
  : 'ALL' | 'NONE' | 'NOTPUBLIC' 
  ; 
memOption
  : 'TINY' | 'SMALL' | 'MEDIUM' | 'COMPACT' | 'LARGE' | 'HUGE' | 'FLAT' 
  ; 
mnemonic
  : 
    'aaa'|
    'aad'|
    'aam'|
    'aas'|
    'adc'|
    'add'|
    'and'|
    'cbw'|
    'clc'|
    'cld'|
    'cli'|
    'cmc'|
    'cmp'|
    'cwd'|
    'daa'|
    'das'|
    'dec'|
    'div'|
    'esc'|
    'hlt'|
    'inc'|
    'int'|
    'jae'|
    'jbe'|
    'jge'|
    'jle'|
    'jna'|
    'jnb'|
    'jnc'|
    'jne'|
    'jng'|
    'jnl'|
    'jno'|
    'jnp'|
    'jns'|
    'jnz'|
    'jpe'|
    'jpo'|
    'jmp'|
    'lds'|
    'lea'|
    'les'|
    'mov'|
    'mul'|
    'neg'|
    'nop'|
    'not'|
    'out'|
    'pop'|
    'rcl'|
    'rcr'|
    'ret'|
    'rol'|
    'ror'|
    'sal'|
    'sar'|
    'sbb'|
    'shl'|
    'shr'|
    'stc'|
    'std'|
    'sti'|
    'sub'|
    'xor'|
    'ins'|
    'lar'|
    'lsl'|
    'ltr'|
    'str'|
    'bsf'|
    'bsr'|
    'btc'|
    'btr'|
    'bts'|
    'cdq'|
    'lfs'|
    'lgs'|
    'lss'|
    'ud2'|
    'por'|
    'call'|
    'idiv'|
    'imul'|
    'into'|
    'iret'|
    'jcxz'|
    'jnae'|
    'jnbe'|
    'jnge'|
    'jnle'|
    'lahf'|
    'loop'|
    'popf'|
    'push'|
    'retn'|
    'retf'|
    'sahf'|
    'test'|
    'wait'|
    'xchg'|
    'xlat'|
    'outs'|
    'popa'|
    'arpl'|
    'clts'|
    'lgdt'|
    'lidt'|
    'lldt'|
    'lmsw'|
    'sgdt'|
    'sidt'|
    'sldt'|
    'smsw'|
    'verr'|
    'verw'|
    'cwde'|
    'insb'|
    'insw'|
    'insd'|
    'insq'|
    'seta'|
    'setb'|
    'setc'|
    'sete'|
    'setg'|
    'setl'|
    'seto'|
    'setp'|
    'sets'|
    'setz'|
    'shld'|
    'shrd'|
    'invd'|
    'xadd'|
    'pand'|
    'pxor'|
    'movd'|
    'movq'|
    'emms'|
    'orps'|
    'clgi'|
    'stgi'|
    'dpps'|
    'dppd'|
    'cmpsb'|
    'cmpsw'|
    'jecxz'|
    'lodsb'|
    'lodsw'|
    'lodsd'|
    'loopx'|
    'movsb'|
    'movsw'|
    'pushf'|
    'scasb'|
    'scasw'|
    'stosb'|
    'stosw'|
    'bound'|
    'enter'|
    'leave'|
    'pusha'|
    'cmpsd'|
    'iretb'|
    'iretw'|
    'iretd'|
    'iretq'|
    'loope'|
    'loopz'|
    'movsx'|
    'movsd'|
    'movzx'|
    'popad'|
    'popfd'|
    'scasd'|
    'setae'|
    'setbe'|
    'setge'|
    'setle'|
    'setna'|
    'setnb'|
    'setnc'|
    'setne'|
    'setng'|
    'setnl'|
    'setno'|
    'setnp'|
    'setns'|
    'setnz'|
    'setpe'|
    'setpo'|
    'stosd'|
    'stosq'|
    'bswap'|
    'cpuid'|
    'rdmsr'|
    'rdtsc'|
    'wrmsr'|
    'cmova'|
    'cmovb'|
    'cmovc'|
    'cmove'|
    'cmovg'|
    'cmovl'|
    'cmovo'|
    'cmovp'|
    'cmovs'|
    'cmovz'|
    'rdpmc'|
    'paddb'|
    'paddw'|
    'paddd'|
    'psubb'|
    'psubw'|
    'psubd'|
    'pmull'|
    'pmulh'|
    'pmadd'|
    'pandn'|
    'psllw'|
    'pslld'|
    'psrlw'|
    'psrld'|
    'psraw'|
    'psrad'|
    'psllq'|
    'psrlq'|
    'movss'|
    'addss'|
    'subss'|
    'mulss'|
    'divss'|
    'rcpss'|
    'maxss'|
    'minss'|
    'addps'|
    'subps'|
    'mulps'|
    'divps'|
    'rcpps'|
    'maxps'|
    'minps'|
    'cmpss'|
    'cmpps'|
    'andps'|
    'xorps'|
    'pavgb'|
    'pavgw'|
    'pause'|
    'lddqu'|
    'mwait'|
    'pabsb'|
    'pabsw'|
    'pabsd'|
    'vmxon'|
    'vmrun'|
    'ptest'|
    'crc32'|
    'lzcnt'|
    'loopne'|
    'loopnz'|
    'pushad'|
    'pushfd'|
    'setnae'|
    'setnbe'|
    'setnge'|
    'setnle'|
    'invlpg'|
    'wbinvd'|
    'cmovae'|
    'cmovbe'|
    'cmovge'|
    'cmovle'|
    'cmovna'|
    'cmovnb'|
    'cmovnc'|
    'cmovne'|
    'cmovng'|
    'cmovnl'|
    'cmovno'|
    'cmovnp'|
    'cmovns'|
    'cmovnz'|
    'cmovpe'|
    'cmovpo'|
    'sysret'|
    'paddsb'|
    'paddsw'|
    'psubsb'|
    'psubsw'|
    'movaps'|
    'movups'|
    'movlps'|
    'movhps'|
    'sqrtss'|
    'sqrtps'|
    'comiss'|
    'shufps'|
    'andnps'|
    'psadbw'|
    'pmaxub'|
    'pminub'|
    'pmaxsw'|
    'pminsw'|
    'pextrw'|
    'pinsrw'|
    'pshufw'|
    'movntq'|
    'sfence'|
    'lfence'|
    'mfence'|
    'movnti'|
    'haddpd'|
    'haddps'|
    'hsubpd'|
    'hsubps'|
    'psignb'|
    'psignw'|
    'psignd'|
    'pshufb'|
    'phsubw'|
    'phsubd'|
    'phaddw'|
    'phaddd'|
    'vmread'|
    'vmcall'|
    'vmxoff'|
    'skinit'|
    'vmload'|
    'vmsave'|
    'rdtscp'|
    'pmuldq'|
    'pmulld'|
    'pminsb'|
    'pmaxsb'|
    'pminuw'|
    'pmaxuw'|
    'pminud'|
    'pmaxud'|
    'pminsd'|
    'pmaxsd'|
    'pinsrb'|
    'pinsrd'|
    'pinsrq'|
    'pextrb'|
    'pextrd'|
    'pextrq'|
    'popcnt'|
    'loadall'|
    'cmpxchg'|
    'cmovnae'|
    'cmovnbe'|
    'cmovnge'|
    'cmovnle'|
    'sysexit'|
    'syscall'|
    'paddusb'|
    'paddusw'|
    'psubusb'|
    'psubusw'|
    'pcmpeqb'|
    'pcmpeqw'|
    'pcmpeqd'|
    'movlhps'|
    'movhlps'|
    'rsqrtss'|
    'rsqrtps'|
    'ucomiss'|
    'pmulhuw'|
    'ldmxcsr'|
    'stmxcsr'|
    'movntps'|
    'clflush'|
    'movntdq'|
    'movntpd'|
    'movddup'|
    'fisfttp'|
    'monitor'|
    'palignr'|
    'phaddsw'|
    'vmptrld'|
    'vmptrst'|
    'vmclear'|
    'vmwrite'|
    'vmmcall'|
    'mpsadbw'|
    'blendps'|
    'blendpd'|
    'pblendw'|
    'roundps'|
    'roundss'|
    'roundpd'|
    'roundsd'|
    'pcmpeqq'|
    'pcmpgtq'|
    'sysenter'|
    'pcmpgtpb'|
    'pcmpgtpw'|
    'pcmpgtpd'|
    'packsswb'|
    'packssdw'|
    'packuswb'|
    'unpckhps'|
    'unpcklps'|
    'cvtsi2ss'|
    'cvtss2si'|
    'cvtpi2ps'|
    'cvtps2pi'|
    'pmovmskb'|
    'maskmovq'|
    'addsubpd'|
    'addsubps'|
    'movshdup'|
    'movsldup'|
    'pmulhrsw'|
    'vmlaunch'|
    'vmresume'|
    'blendvps'|
    'blendvpd'|
    'pblendvb'|
    'insertps'|
    'pmovsxbw'|
    'pmovzxbw'|
    'pmovsxbd'|
    'pmovzxbd'|
    'pmovsxbq'|
    'pmovzxbq'|
    'pmovsxwd'|
    'pmovzxwd'|
    'pmovsxwq'|
    'pmovzxwq'|
    'pmovsxdq'|
    'pmovzxdq'|
    'packusdw'|
    'movntdqa'|
    'cmpxchg8b'|
    'punpckhbw'|
    'punpckhwd'|
    'punpckhdq'|
    'punpcklbw'|
    'punpcklwd'|
    'punpckldq'|
    'cvttss2si'|
    'cvttps2pi'|
    'prefetch0'|
    'prefetch1'|
    'prefetch2'|
    'pmaddubsw'|
    'extractps'|
    'pcmpestri'|
    'pcmpestrm'|
    'pcmpistri'|
    'pcmpistrm'|
    'maskmovdqu'|
    'cmpxchg16b'|
    'phminposuw'|
    'prefetchnta'|

    'f2xm1'|
    'FABS'|
    'fadd'|
    'faddp'|
    'fbld'|
    'fbstp'|
    'fchs'|
    'fclex'|
    'fcom'|
    'fcomp'|
    'fcompp'|
    'fdecstp'|
    'fdisi'|
    'fdiv'|
    'fdivp'|
    'fdivr'|
    'fdivrp'|
    'feni'|
    'ffree'|
    'fiadd'|
    'ficom'|
    'ficomp'|
    'fidiv'|
    'fidivr'|
    'fild'|
    'fimul'|
    'fincstp'|
    'finit'|
    'fist'|
    'fistp'|
    'fisub'|
    'fisubr'|
    'fld'|
    'fld1'|
    'fldcw'|
    'fldenv'|
    'fldenvw'|
    'fldl2e'|
    'fldl2t'|
    'fldlg2'|
    'fldln2'|
    'fldpi'|
    'fldz'|
    'fmul'|
    'fmulp'|
    'fnclex'|
    'fndisi'|
    'fneni'|
    'fninit'|
    'fnop'|
    'fnsave'|
    'fnsavew'|
    'fnstcw'|
    'fnstenv'|
    'fnstenvw'|
    'fnstsw'|
    'fpatan'|
    'fprem'|
    'fptan'|
    'frndint'|
    'frstor'|
    'frstorw'|
    'fsave'|
    'fsavew'|
    'fscale'|
    'fsqrt'|
    'fst'|
    'fstcw'|
    'fstenv'|
    'fstenvw'|
    'fstp'|
    'fstsw'|
    'fsub'|
    'fsubp'|
    'fsubr'|
    'fsubrp'|
    'ftst'|
    'fwait'|
    'fxam'|
    'fxch'|
    'fxtract'|
    'fyl2x'|
    'fyl2xp1'|
    'fsetpm'|
    'fcos'|
    'fldenvd'|
    'fnsaved'|
    'fnstenvd'|
    'fprem1'|
    'frstord'|
    'fsaved'|
    'fsin'|
    'fsincos'|
    'fstenvd'|
    'fucom'|
    'fucomp'|
    'fucompp'|
    'fcmovbe'|
    'fcmove'|
    'fcmovnb'|
    'fcmovnbe'|
    'fcmovne'|
    'fcmovnu'|
    'fcmovu'|
    'fcomip'|
    'fucomi'|
    'fucomip'|
    'fxrstor'|
    'fxrstorb'|
    'fxrstorw'|
    'fxrstorq'|
    'fxsave'|
    'fxsaveb'|
    'fxsavew'|
    'fxsaveq'|
    'ffreep'|


    'movdqa'|
    'movdqu'|
    'movapd'|
    'movupd'|

    'psrldq'|
    'pslldq'|
    'pshufd'|
    'pshuflw'|
    'shufpd'|

    'pmullw'|
    'pmulhw'|
    'pmuludq'|
    'punpcklqdq'|
    'punpckhqdq'|
    'paddq'|
    'pcmpgtd'|
    'psubq'|
    'movdq2q'
  ; 
commamodelOptlist
  : ',' modelOptlist
  ;
modelDir
  : '.MODEL' memOption commamodelOptlist? lineReminder
  ; 
modelOpt
  : langType| stackOption 
  ; 
modelOptlist
  : modelOpt| modelOptlist  ',' modelOpt
  ; 
mulOp
  : '*'| '/' | 'MOD' 
  ; 
nameDir
  : 'NAME' id lineReminder
  ; 
nearfar
  : 'NEAR' | 'FAR' 
  ; 
nestedStruct
  : structHdr  id?  lineReminder structBody 'ENDS' lineReminder
  ; 
offsetDir
  : offsetDirType lineReminder
  ; 
offsetDirType
  : 'EVEN' | 'ORG' immExpr| 'ALIGN' constExpr? 
  ; 
offsetType
  : 'GROUP' | 'SEGMENT' | 'FLAT' 
  ; 
oldRecordFieldList
  :  constExpr? | oldRecordFieldList ','  constExpr? 
  ; 
optionDir
  : 'OPTION' optionList lineReminder
  ; 
readonly
  : 'READONLY'
  ;
optionItem
  : 'CASEMAP' ':' mapType| 'DOTNAME' | 'NODOTNAME' | 'EMULATOR' | 'NOEMULATOR' | 'EPILOGUE' ':' macroId| 'EXPR16' | 'EXPR32' | 'LANGUAGE' ':' langType| 'LJMP' | 'NOLJMP' | 'M510' | 'NOM510' | 'NOSIGNEXTEND' | 'OFFSET' ':' offsetType| 'OLDMACROS' | 'NOOLDMACROS' | 'OLDSTRUCTS' | 'NOOLDSTRUCTS' | 'PROC' ':' oVisibility| 'PROLOGUE' ':' macroId| readonly | 'NOREADONLY' | 'SCOPED' | 'NOSCOPED' | 'SEGMENT' ':' segSize| 'SETIF2' ':' bool
  ; 
optionList
  : optionItem| optionList  ',' lineReminder?  optionItem
  ; 
optText
  : ',' textItem
  ; 
orOp
  : 'OR' | 'XOR' 
  ; 
oVisibility
  : 'PUBLIC' | 'PRIVATE' | 'EXPORT' 
  ; 
pageDir
  : 'PAGE' pageExpr?  lineReminder
  ; 
commapageWidth
  : ',' pageWidth
  ;
pageExpr
  : '+'|  pageLength?  commapageWidth?
  ; 
pageLength
  : constExpr
  ; 
pageWidth
  : constExpr
  ; 
dotdotqualifiedType
  : ':' qualifiedType
  ;
parm
  : parmId dotdotqualifiedType? | parmId  constExpr? dotdotqualifiedType?
  ; 
parmId
  : id
  ; 
parmList
  : parm| parmList  ',' lineReminder?  parm
  ; 
parmType
  : 'REQ' | '=' textLiteral| 'VARARG' 
  ; 
pOptions
  :  distance?   langType?   oVisibility? 
  ; 
primary
  : expr binaryOp expr| flagName| expr
  ; 
brmacroArgList
  : '<' macroArgList '>'
  ;
procDir
  : procId 'PROC' pOptions?  brmacroArgList?  usesRegs?   procParmList? 
  ; 
processor
  : '.8086' | '.186' | '.286' | '.286C' | '.286P' | '.386' | '.386C' | '.386P' | '.486' | '.486P' | '.586' | '.586P' |
 '.686' | '.686P' | '.K3D' | '.MMX' | '.XMM' | '.8086' 
  ; 
processorDir
  : processor lineReminder | coprocessor lineReminder
  ; 
procId
  : id
  ; 
commaparmList
  : ','  lineReminder?  parmList
  ;
commaparmIdvararg
  : ','  lineReminder?  parmId ':VARARG' 
  ;
procParmList
  : commaparmList? 
    commaparmIdvararg?
  ; 
protoArg 
  :  id? ':' qualifiedType 
  ; 
commaprotoList
  : ','  lineReminder?  protoList
  ;
commaidvararg
  : ','  lineReminder?   id? ':VARARG' 
  ;
protoArgList
  : commaprotoList?
    commaidvararg?
  ; 
protoList
  : protoArg| protoList  ',' lineReminder?  protoArg
  ; 
protoSpec
  :  distance?   langType?   protoArgList?  | typeId
  ; 
protoTypeDir
  : id 'PROTO' protoSpec
  ; 
pubDef
  :  langType?  id
  ; 
publicDir
  : 'PUBLIC' pubList lineReminder
  ; 
pubList
  : pubDef| pubList  ',' lineReminder?  pubDef
  ; 
purgeDir
  : 'PURGE' macroIdList
  ; 
qualifiedType
  : type|  distance? 'PTR' qualifiedType? 
  ; 
qualifier
  : qualifiedType| 'PROTO' protoSpec
  ; 
quote
  : '\'' | '"'
  ; 
radixDir
  : '.RADIX' constExpr lineReminder
  ; 
recordConst
  : recordTag '{' oldRecordFieldList '}'| recordTag '<' oldRecordFieldList '>'
  ; 
recordDir
  : recordTag 'RECORD' bitDefList lineReminder 
  ; 
recordFieldList
  :  constExpr? | recordFieldList  ','  lineReminder?   constExpr? 
  ; 
recordInstance
  : '{'  lineReminder?  recordFieldList  lineReminder?  '}'| '<' oldRecordFieldList '>'| constExpr 'DUP' '(' recordInstance ')'
  ; 
recordInstList
  : recordInstance| recordInstList ','  lineReminder?  recordInstance
  ; 
recordTag
  : id
  ; 
register
  : specialRegister| gpRegister| byteRegister
  ; 
regList
  : register| regList register
  ; 
relOp
  : 'EQ' | 'NE' | 'LT' | 'LE' | 'GT' | 'GE' 
  ; 
repeatBlock
  : '.REPEAT' lineReminder blockStatements lineReminder untilDir lineReminder
  ; 
repeatDir
  : 'REPEAT' | 'REPT' 
  ; 
scalarInstList
  : initValue| scalarInstList  ','  lineReminder?  initValue
  ; 
segAlign
  : 'BYTE' | 'WORD' | 'DWORD' | 'PARA' | 'PAGE' 
  ; 
segAttrib
  : 'PUBLIC' | 'STACK' | 'COMMON' | 'MEMORY' | 'AT' constExpr| 'PRIVATE' 
  ; 
segDir
  : '.CODE' segId? | '.DATA' | '.DATA?'| '.CONST' | '.FARDATA' segId? | '.FARDATA?' segId? | '.STACK' constExpr? 
  ; 
segId
  : id
  ; 
segIdList 
  : segId| segIdList  ',' segId
  ; 
segmentDef
  : segmentDir  inSegDirList?  endsDir| simpleSegDir  inSegDirList?   endsDir? 
  ; 
segmentDir
  : segId 'SEGMENT' segOptionList?  lineReminder
  ; 
segmentRegister
  : 'CS' | 'DS' | 'ES' | 'FS' | 'GS' | 'SS'
  ; 
segOption
  : segAlign| segRO| segAttrib| segSize| className
  ; 
segOptionList
  : segOption| segOptionList segOption
  ; 
segOrderDir
  : '.ALPHA' | '.SEQ' | '.DOSSEG' | 'DOSSEG' 
  ; 
segRO
  : readonly
  ; 
segSize 
  : 'USE16' | 'USE32' | 'FLAT' 
  ; 
shiftOp
  : 'SHR' | 'SHL' 
  ; 
sign
  : '-' | '+'
  ; 
simpleExpr
  : '(' cExpr ')'| primary
  ; 
simpleSegDir
  : segDir lineReminder
  ; 
sizeArg
  : id| type| e10
  ; 
specialChars
  : ':' | '.' | '[[' | ']]' | '(' | ')' | '<' | '>' | '{' | '}'| '+' | '-' | '/' | '*' | '&' | '%' | '!'| '\'' | '\\' | '=' | ';' | ',' | '"'| whiteSpaceCharacter | endOfLine
  ; 
specialRegister
  : 'CR0' | 'CR2' | 'CR3' | 'DR0' | 'DR1' | 'DR2' | 'DR3' | 'DR6' | 'DR7'| 'TR3' | 'TR4' | 'TR5' | 'TR6' | 'TR7'
  ; 
stackOption
  : 'NEARSTACK' | 'FARSTACK' 
  ; 
startupDir
  : '.STARTUP' lineReminder
  ; 
stext
  : stringChar| stext stringChar
  ; 
string
  : quote  stext?  quote
  ; 
structBody
  : structItem lineReminder | structBody structItem lineReminder
  ; 
commanonuniq
  : ',' 'NONUNIQUE'
  ;
structDir
  : structTag structHdr  fieldAlign?  commanonuniq? lineReminder structBody structTag 'ENDS' lineReminder
  ; 
structHdr
  : 'STRUC' | 'STRUCT' | 'UNION' 
  ; 
structInstance
  : '<'  fieldInitList?  '>'| '{' lineReminder?   fieldInitList?   lineReminder?  '}'| constExpr 'DUP' '(' structInstList ')'
  ; 
structInstList
  : structInstance| structInstList  ','  lineReminder?  structInstance
  ; 
structItem 
  : dataDir| generalDir| offsetDir| nestedStruct
  ; 
structTag
  : id
  ; 
term
  : simpleExpr| '!' simpleExpr
  ; 
text
  : textLiteral| text character| '!' character text| character| '!' character
  ; 
textDir
  : id textMacroDir lineReminder
  ; 
textItem
  : textLiteral| textMacroId| '%' constExpr
  ; 
textLen
  : constExpr
  ; 
textList
  : textItem| textList  ',' lineReminder?  textItem
  ; 
textLiteral
  : '<' text '>' lineReminder
  ; 
commatextLen
  : ',' textLen
  ;
textStartcomma
  : textStart  ','
  ;
textMacroDir
  : 'CATSTR' textList? | 'TEXTEQU' textList? | 'SIZESTR' textItem| 'SUBSTR' textItem  ',' textStart commatextLen| 'INSTR' textStartcomma? textItem  ',' textItem
  ; 
textMacroId
  : id
  ; 
textStart
  : constExpr
  ; 
titleDir
  : titleType arbitraryText lineReminder
  ; 
titleType
  : 'TITLE' | 'SUBTITLE' | 'SUBTTL' 
  ; 
type
  : structTag| unionTag| recordTag| distance| dataType| typeId
  ; 
typedefDir
  : typeId 'TYPEDEF' qualifier
  ; 
typeId
  : id
  ; 
unionTag
  : id
  ; 
untilDir
  : '.UNTIL' cExpr lineReminder '.UNTILCXZ' cxzExpr?  lineReminder
  ; 
usesRegs
  : 'USES' regList 
  ; 
whileBlock
  : '.WHILE' cExpr lineReminder blockStatements lineReminder '.ENDW' 
  ; 
stringChar
  : quote quote| ~ ('\'' | '"')
  ; 
radixOverride
  : 'h' | 'o' | 'q' | 't' | 'y' | 'H' | 'O' | 'Q' | 'T' | 'Y'
  ; 
hexdigit
  : ('a' .. 'f' | 'A' .. 'F')
  ; 
id
  : ('a' .. 'z' | 'A' .. 'Z') | id ('a' .. 'z' | 'A' .. 'Z')| id decdigit
  ; 
character
  : ~ '\r' | ~ '\n'
  ; 
decdigit
  : '0' .. '9'
  ; 
endOfLine
  : ('\n' | '\r')+
  ;
delimiter
  : ','
  ; 
whiteSpaceCharacter
  : (' ' | '\t' | '\n' | '\r')
  ;
comment
  : ';' ~ ('\n' | '\r')* '\r'? '\n'
  ; 
