{$A+,B-,D+,E+,F-,I+,L+,N-,O-,R-,S-,V-}
{$M 16384,0,655360}

PROGRAM MENUMANAGER;
{V1.2}
{V1.3 WITH SETBOX BUILTIN FOR USER DEFINITION AS *BOX}
{     HOWEVER NOT WORKING BECAUSE OF VAST CHANGES NECESSARY}
{V1.4 COSMETIC CHANGES TO AVOID TOO MANY MAGIC VALUES}
{V1.5 ADDED HELP FACILITY}
{V1.6 REVISED RECORD STRUCTURES}
{V1.7 GENERAL TIDY}
{V1.8 MADE THE USE OF *FIRST MORE FUNCTIONAL. NOW USER CAN HAVE
HEADINGS STARTING ON LINE 3}
{V1.9 ADDED COMMANDS TO SET COLOURS INDIVIDUALLY}
{V1.91 ADDED A MESSAGE TO HELP}
{V1.92 ADDED *DOSVER SENS}
{V1.93 CHANGED TO HEAP STORAGE OF HELP ARRAY}
{V1.94 CHANGED TO HEAP STORAGE OF MAIN ARRAY}
{V1.95 CHANGED TO *EXIT *ENDEXIT WITH HEAP ARRAY OF EXIT COMMANDS}
{V2.0  MENU SCREEN NOW GOING TO FILE DEFINED BY *SCRNAME WITH .ESC EXT OR
DEFAULT NAME WITH .ESC EXT.}
{V2.1  MENU SCREEN GOES TO BATCH FILE UNLESS *SCRNAME DEFINED.}
{V2.2  KLUDGE TO MAKE NULL LINES IN .MNU BE TREATED AS COMMENTS.}
{V2.3  CHANGE TO USE OF A SET IN ERROR MESSAGE HANDLING}
{V3.0  *IF/*ENDIF CONTROL}
{V3.1  ADDED *MESSAGE CAPABILITY FOR MESSAGE TO OPERATOR}
{V3.2  ADDED HERC TO *IF}
{V3.3  ADDED *INCLUDE TO INCLUDE PRETRANSLATED SOURCES WITHIN *OPTION/*ENDOPT}
{V3.4  ADDED FACILITY FOR *IF BEING ! FOLLOWED BY COMMANDLINE DEFINER}
{V3.5  ADDED FACILITY TO CHECK FOR DUPLICATE DEFINITIONS AND SKIP THE REDEFINITION}
{V3.6  CHANGED PARSING OF COMMAND STRING}
{V3.7  MADE COMMANDLINE FILENAME THE DEFAULT OUTPUT FILENAME}
{V3.8  ADDED *INIT/*ENDINIT}
{V3.9  UPPERCASE ON CHECK FOR ENDINIT}
{V3.91 ADDED COMNAME TO THE COMMANDSET}
{V3.92 REMOVED HELP FACILITY}
{V3.93 ADDED /V TO COMMANDLINE. MADE LINECOUNT BETTER REFLECT LINES PROCESSED}
{v3.94 pretty work - meaningful datanames etc.}
{v3.95 change to reflect new ownership}

USES XANSI,XDOS,DOS,XSTRING, xparam;

CONST
     VERSION = 3;
     UPDATE = 95;
     MaximumDosCommands = 100;
     MaximumOptions = 24;
     MaximumDosCommandWidth = 80;
TYPE
    ERRORSET =      ( NOKEYWD,
                      NOENDOPT,
                      ENDOPTFOUND,
                      NOFILE,
                      NOTFOUND,
                      NOPROMPT,
                      NOHELP,
                      NOENDHELP,
                      NOFINISH,
                      NOENDEXIT,
                      ENDEXITFOUND,
                      SCRNAMEBLANK,
                      ENDIFFOUND,
                      FNDINCLUDE,
                      NOINCFILE,
                      ENDINITFOUND,
                      NOENDINIT,
                      COMNAMEBLANK);
    IfStateToggle  = (OFF, ON);
    OptionPointer = ^OptionRecord;
    OptionRecord = RECORD
                   OptionKey : CHAR;
                   OptionHeading : STRING;
                   OptionDosCommands :
                    ARRAY [1..MaximumDosCommands] OF
                      STRING[MaximumDosCommandWidth]
                   END;
    ExitProcPointer = ^ExitProcRecord;
    ExitProcRecord = RECORD
                     ExitProcDosCommands : STRING[MaximumDosCommandWidth]
                     END;
    InitProcPointer = ^InitProcRecord;
    InitProcRecord = RECORD
                     InitProcDosCommands : STRING[MaximumDosCommandWidth]
                     END;
VAR
   MachineCodeSearchRec : SEARCHREC;
   OptionArray   : ARRAY [1..MaximumOptions]
                   OF OptionPointer;
   ExitProcArray : ARRAY [1..MaximumDosCommands]
                   OF ExitProcPointer;
   InitProcArray : ARRAY [1..MaximumDosCommands]
                   OF InitProcPointer;
   Within_If,
   Translate_If : IfStateToggle;
   ScratchCounter1,
   ScratchCounter2,
   ProcessingLineCounter      : WORD;
   InputBuffer,
   OutputBuffer,
   MachineCodeScreenBuffer,
   TypedFileScreenBuffer     : TEXT;
   Verify_On,
   ReadyToGenerateMenu,
   TitleSet,
   DosVersionIs3,
   SuperTitleSet,
   ExitProcedureDefined,
   ScreenFileDefined,
   MachineCodeScreenDefined,
   InitialProcedureDefined,
   KeyGapSet: BOOLEAN;
   OptionCount,
   OptionLength,
   FirstLineOfMenu,
   OptionColour_Bkgnd,
   KeyColour_Bkgnd,
   BoxColour_Bkgnd,
   TitleColour_Bkgnd,
   SuperTitleColour_Bkgnd,
   PromptColour_Bkgnd,
   OptionColour_Frgnd,
   KeyColour_Frgnd,
   BoxColour_Frgnd,
   TitleColour_Frgnd,
   SuperTitleColour_Frgnd,
   PromptColour_Frgnd,
   SizeOfMachineCodeData,
   KeyToHeadingGap : WORD;
   PromptStr,
   SuperTitleStr,
   TitleStr,
   ExitPromptStr,
   BatchLabel_Options,
   BatchLabel_MainLoop,
   OptionKeyList,
   BatchFileName,
   ScreenFileName,
   MachineCodeFileName,
   MNU_FileName,
   MDL_Command,
   ScratchStr,
   OptionKeysListStr,
   MNU_Line,
   CommandLine,
   CommandLineParameter1,
   CommandLineParameter2  : STRING;
   MachineCodeDataByte,
   ExitProcOptionKey : CHAR;

PROCEDURE ProcessingError( N :ERRORSET);
BEGIN

  WRITELN;
  CASE N OF
     NOKEYWD     : WriteLn('keyword not known.');
     NOENDOPT    : WriteLn('*OPTION did not end with *ENDOPT.');
     ENDOPTFOUND : WriteLn('*ENDOPT encountered before *OPTION.');
     NOFILE      : WriteLn('No file on commandline.');
     NOTFOUND    : WriteLn('File not found.');
     NOPROMPT    : WriteLn('*EXIT defined without prompt.');
     NOHELP      : WriteLn('*ENDHELP encountered before *HELP.');
     NOENDHELP   : WriteLn('*HELP did not end with *ENDHELP.');
     NOFINISH    : WriteLn('*FINISH not found. ',BatchFileName,' not created.');
     NOENDEXIT   : WriteLn('*ENDEXIT not found.');
     ENDEXITFOUND: WriteLn('*ENDEXIT encountered before *EXIT.');
     SCRNAMEBLANK: WriteLn('*SCRNAME must have file name following.');
     ENDIFFOUND  : WriteLn('*ENDIF found before *IF.');
     FNDINCLUDE  : WriteLn('Found *INCLUDE outside of *OPTION/*ENDOPT.');
     NOINCFILE   : WriteLn('*INCLUDE file not found.');
     ENDINITFOUND: WriteLn('*ENDINIT found before *INIT.');
     NOENDINIT   : WriteLn('*ENDINIT not found.');
     COMNAMEBLANK: WriteLn('*COMNAME must have file name following.');
  END;
  HALT

END;
FUNCTION ParseMDL_Command(S:STRING) : WORD;
CONST   PARSELIM = 32;
        PARSELST : ARRAY [1..PARSELIM] OF STRING[7] =
        ('COMMENT',
         'NAME',
         'FIRST',
         'SUPER',
         'TITLE',
         'EXIT',
         'PROMPT',
         'KEYGAP',
         'OPTION',
         'ENDOPT',
         'FINISH',
         'DOSVER',
         'COLOUR',
         'LOOPLBL',
         'OPTLBL',
         'HELP',
         'ENDHELP',
         'KEYCOL',
         'OPTCOL',
         'PRMCOL',
         'TTLCOL',
         'STLCOL',
         'BOXCOL',
         'ENDEXIT',
         'SCRNAME',
         'IF',
         'ENDIF',
         'MESSAGE',
         'INCLUDE',
         'INIT',
         'ENDINIT',
         'COMNAME');
VAR     I, J : WORD;
BEGIN
        I := 1;
        J := 0;
        WHILE I<=PARSELIM DO
                IF S=PARSELST[I] THEN
                BEGIN
                        J := I;
                        I := PARSELIM+1
                END
                ELSE
                        INC(I);
        ParseMDL_Command := J

END;
PROCEDURE SETSCREEN( S : STRING);
BEGIN
  IF S='' THEN ProcessingError(SCRNAMEBLANK);
  ScreenFileDefined := TRUE;
  ScreenFileName := ADDFILETYPE(S,'.ESC');

END;

PROCEDURE SETTITLE( S :STRING);
BEGIN
  TitleStr := S;
  TitleSet := TRUE
END;

PROCEDURE SETSUPER( S:STRING);
BEGIN
  SuperTitleStr := S;
  SuperTitleSet := TRUE

END;
PROCEDURE BUMP_COUNTER;
BEGIN
  INC(ProcessingLineCounter);
  WRITE(#13,ProcessingLineCounter);
END;

PROCEDURE SETEXIT( S,T : STRING);
VAR I : WORD;
BEGIN
  ExitProcedureDefined := TRUE;
  I := 1;
  ExitProcOptionKey := S[1];
  IF T='' THEN ProcessingError(NOPROMPT) ELSE ExitPromptStr := T;
  READLN(InputBuffer,MNU_Line);
  BUMP_COUNTER;
  LTRIM(MNU_Line);
  WHILE (MNU_Line[1]<>'*') AND (NOT EOF(InputBuffer)) DO
  BEGIN
     NEW(ExitProcArray[I]);
     ExitProcArray[I]^.ExitProcDosCommands := MNU_Line;
     INC(I);
     READLN(InputBuffer,MNU_Line);
     BUMP_COUNTER;
     LTRIM(MNU_Line)
  END;
  IF MNU_Line<>'*ENDEXIT' THEN ProcessingError(NOENDEXIT);


END;


PROCEDURE SETINIT;
VAR I : WORD;
BEGIN
  InitialProcedureDefined := TRUE;
  I := 1;
  READLN(InputBuffer,MNU_Line);
  BUMP_COUNTER;
  LTRIM(MNU_Line);
  WHILE (MNU_Line[1]<>'*') AND (NOT EOF(InputBuffer)) DO
  BEGIN
     NEW(InitProcArray[I]);
     InitProcArray[I]^.InitProcDosCommands := MNU_Line;
     INC(I);
     READLN(InputBuffer,MNU_Line);
     BUMP_COUNTER;
     LTRIM(MNU_Line)
  END;
  IF UPPERCASE(MNU_Line)<>'*ENDINIT' THEN ProcessingError(NOENDINIT);

END;


PROCEDURE SETKEYGAP( S : STRING);
var i : word;
BEGIN
  VAL(S,KeyToHeadingGap,I);
  KeyGapSet := TRUE;

END;

PROCEDURE SETOPTION( K, H : STRING);
VAR i,J : WORD;
FNAME, TMPX,INCREC : STRING;
INCBUFF : TEXT;
DUPLICATING : BOOLEAN;

PROCEDURE PRIMING_READ;
BEGIN
  READLN(InputBuffer,MNU_Line);
  BUMP_COUNTER;
  LTRIM(MNU_Line);
  TMPX := UPPERCASE(XSTRING.FIRST(MNU_Line));
END;
BEGIN
  DUPLICATING := (POS(K,OptionKeysListStr)<>0);
  IF NOT DUPLICATING THEN
  BEGIN
     INC(OptionCount);
     NEW(OptionArray[OptionCount]);
     FOR I := 1 TO MaximumDosCommands DO OptionArray[OptionCount]^.OptionDosCommands[I] := '';
     OptionArray[OptionCount]^.OptionKey := K[1];
     IF LENGTH(H)>OptionLength THEN OptionLength:=LENGTH(H);
     OptionArray[OptionCount]^.OptionHeading := H;
     OptionKeyList := OptionKeyList + K[1];
     J := 1;
     PRIMING_READ;
     WHILE (TMPX<>'*ENDOPT') AND (NOT EOF(InputBuffer)) DO
     BEGIN
        IF TMPX<>'*INCLUDE' THEN
        BEGIN
           OptionArray[OptionCount]^.OptionDosCommands[J] := MNU_Line;
           INC(J);
           PRIMING_READ
        END
        ELSE
        BEGIN
           FNAME := (BUTFIRST(MNU_Line));
           LTRIM(FNAME);
           ASSIGN(INCBUFF,FNAME);
           {$I-}
           RESET(INCBUFF);
           {$I+}
           IF IORESULT<>0 THEN
           ProcessingError(NOINCFILE);
           WriteLn(#13,'Including file ',FNAME);
           WHILE NOT EOF(INCBUFF) DO
           BEGIN
              READLN(INCBUFF,INCREC);
              LTRIM(INCREC);
              OptionArray[OptionCount]^.OptionDosCommands[J] := INCREC;
              INC(J)
           END;
           CLOSE(INCBUFF);
           PRIMING_READ;
        END;
     END;

     IF UPPERCASE(MNU_Line)<>'*ENDOPT' THEN ProcessingError(NOENDOPT);
     OptionKeysListStr := OptionKeysListStr+K
  END
  ELSE
  BEGIN
     WriteLn(#13,'WARNING: Redefinition of ',K,' attempted.');
     PRIMING_READ;
     WHILE (TMPX<>'*ENDOPT') AND (NOT EOF(InputBuffer)) DO
     PRIMING_READ
  END


END;

PROCEDURE DOSVER(S:STRING);
VAR
I : WORD;
MAJOR, MINOR : STRING;
BEGIN
  I := LISTINDEX(RIGHTFILL(UPPERCASE(S),4)+',','3.3 ,SENS,',5);
  CASE I OF
     1 : DosVersionIs3 := TRUE;
     2 : BEGIN
        STR(LO(DOSVERSION),MAJOR);
        STR(HI(DOSVERSION),MINOR);
        IF MAJOR+'.'+MINOR >= '3.3' THEN DosVersionIs3 := TRUE
     END;
  END;
END;


PROCEDURE SETCOLOUR( COLOURLIST : STRING);
VAR J : WORD;
BEGIN
  VAL(CAR(COLOURLIST),OptionColour_Bkgnd,J);
  VAL(CAR(COLOURLIST),OptionColour_Frgnd,J);
  VAL(CAR(COLOURLIST),KeyColour_Bkgnd,J);
  VAL(CAR(COLOURLIST),KeyColour_Frgnd,J);
  VAL(CAR(COLOURLIST),BoxColour_Bkgnd,J);
  VAL(CAR(COLOURLIST),BoxColour_Frgnd,J);
  VAL(CAR(COLOURLIST),TitleColour_Bkgnd,J);
  VAL(CAR(COLOURLIST),TitleColour_Frgnd,J);
  VAL(CAR(COLOURLIST),SuperTitleColour_Bkgnd,J);
  VAL(CAR(COLOURLIST),SuperTitleColour_Frgnd,J);
  VAL(CAR(COLOURLIST),PromptColour_Bkgnd,J);
  VAL(CAR(COLOURLIST),PromptColour_Frgnd,J);

END;
PROCEDURE SETKEYCOL( S:STRING);
VAR J : WORD;
BEGIN
  VAL(CAR(S),KeyColour_Bkgnd,J);
  VAL(CAR(S),KeyColour_Frgnd,J);
END;
PROCEDURE SETOPTCOL( S:STRING);
VAR J : WORD;
BEGIN
  VAL(CAR(S),OptionColour_Bkgnd,J);
  VAL(CAR(S),OptionColour_Frgnd,J);
END;
PROCEDURE SETPRMCOL( S:STRING);
VAR J : WORD;
BEGIN
  VAL(CAR(S),PromptColour_Bkgnd,J);
  VAL(CAR(S),PromptColour_Frgnd,J);
END;
PROCEDURE SETBOXCOL( S:STRING);
VAR J : WORD;
BEGIN
  VAL(CAR(S),BoxColour_Bkgnd,J);
  VAL(CAR(S),BoxColour_Frgnd,J);
END;
PROCEDURE SETTTLCOL( S:STRING);
VAR J : WORD;
BEGIN
  VAL(CAR(S),TitleColour_Bkgnd,J);
  VAL(CAR(S),TitleColour_Frgnd,J);
END;
PROCEDURE SETSTLCOL( S:STRING);
VAR J : WORD;
BEGIN
  VAL(CAR(S),SuperTitleColour_Bkgnd,J);
  VAL(CAR(S),SuperTitleColour_Frgnd,J);
END;



PROCEDURE SETIF(S:STRING);
VAR X       : WORD;
V       : BYTE;
IFOPTS  : STRING;
BEGIN
  V := VIDEOMODE;
  Within_If := ON;
  IFOPTS := 'CGA    ,'+
  'HERC   ,';
  X := LISTINDEX(RIGHTFILL(UPPERCASE(S),7)+',',IFOPTS,8);
  CASE X OF
     0 : IF S[1]='!' THEN
     IF UPPERCASE(CommandLineParameter2)=UPPERCASE(COPY(S,2,255)) THEN
     Translate_If := ON
     ELSE
     Translate_If := OFF;
     1 : IF V= 3 THEN Translate_If := ON ELSE Translate_If := OFF;
     2 : IF V= 7 THEN Translate_If := ON ELSE Translate_If := OFF;
  END;
END;

PROCEDURE WRITE_ANSI(ROW,COL,BGD,FGD:WORD;TXT:STRING);
BEGIN
  IF ScreenFileDefined THEN
  WRITELN(TypedFileScreenBuffer,ANSILOCATE(ROW,COL),ANSICOLOURBF(BGD,FGD),TXT,
  ANSICOLOUR(SA_OFF))
  ELSE
  WRITELN(OutputBuffer,'echo ',ANSILOCATE(ROW,COL),ANSICOLOURBF(BGD,FGD),TXT,
  ANSICOLOUR(SA_OFF))

END;
PROCEDURE FINISH;
VAR I,J :WORD;
PROCEDURE WRITE_BOX( TOPROW, TOPCOL, HEIGHT, WIDTH, BGCOL, FGCOL : WORD);

VAR
I : WORD;
BEGIN
  WRITE_ANSI(TOPROW,TOPCOL,BGCOL,FGCOL,TOPLEFT);
  WRITE_ANSI(TOPROW,TOPCOL+1,BGCOL,FGCOL,REPEATSTRING(WIDTH-1,LYINGDOWN));
  WRITE_ANSI(TOPROW,TOPCOL+WIDTH,BGCOL,FGCOL,TOPRIGHT);

  FOR I := 1 TO HEIGHT-1 DO
  BEGIN
     WRITE_ANSI(TOPROW+I,TOPCOL,BGCOL,FGCOL,UPRIGHT);
     WRITE_ANSI(TOPROW+I,TOPCOL+WIDTH,BGCOL,FGCOL,UPRIGHT);
  END;
  WRITE_ANSI(TOPROW+HEIGHT,TOPCOL,BGCOL,FGCOL,BOTTOMLEFT);
  WRITE_ANSI(TOPROW+HEIGHT,TOPCOL+1,BGCOL,FGCOL,REPEATSTRING(WIDTH-1,LYINGDOWN));
  WRITE_ANSI(TOPROW+HEIGHT,TOPCOL+WIDTH,BGCOL,FGCOL,BOTTOMRIGHT);
END;
BEGIN
  IF ScreenFileDefined THEN
  BEGIN
     ASSIGN(TypedFileScreenBuffer,ScreenFileName);
     REWRITE(TypedFileScreenBuffer)
  END;
  ASSIGN(OutputBuffer,BatchFileName);
  REWRITE(OutputBuffer);
  IF DosVersionIs3 THEN
  WRITELN(OutputBuffer,'@echo off')
  ELSE
  WRITELN(OutputBuffer,'ECHO OFF');
  IF InitialProcedureDefined THEN
  BEGIN
        I := 1;
        WHILE InitProcArray[i]<>Nil DO
        BEGIN
                WRITELN(OutputBuffer,InitProcArray[I]^.InitProcDosCommands);
                INC(I)
        END
  END;
  WRITELN(OutputBuffer,':',BatchLabel_MainLoop);
  WRITELN(OutputBuffer,'CLS');
  IF ScreenFileDefined THEN
     IF MachineCodeScreenDefined THEN
        WRITELN(OutputBuffer,MachineCodeFileName)
     ELSE
         WRITELN(OutputBuffer,'type ',ScreenFileName);
  IF SuperTitleSet THEN
  WRITE_ANSI(1,CENTREINDEX(SuperTitleStr,80),SuperTitleColour_Bkgnd,SuperTitleColour_Frgnd,SuperTitleStr);
  IF TitleSet THEN
  WRITE_ANSI(3,CENTREINDEX(TitleStr,80),TitleColour_Bkgnd,TitleColour_Frgnd,TitleStr);
  IF NOT KeyGapSet THEN KeyToHeadingGap := 2;
  WRITE_BOX(2, 10, OptionCount+FirstLineOfMenu+2, 59, BoxColour_Bkgnd, BoxColour_Frgnd);
  WRITE_ANSI( OptionCount+FirstLineOfMenu+4, 14, BoxColour_Bkgnd, BoxColour_Frgnd,
  ' (c)Copyright Bruce M. Axtens, 1992 ');
  I := 1;
  WHILE I<=OptionCount DO
  BEGIN
     WRITE_ANSI(FirstLineOfMenu+I-1,
     40-TRUNC(OptionLength/2),KeyColour_Bkgnd,KeyColour_Frgnd,OptionArray[I]^.OptionKey);
     WRITE_ANSI(FirstLineOfMenu+I-1,
     (40-TRUNC(OptionLength/2))+KeyToHeadingGap+1,OptionColour_Bkgnd,OptionColour_Frgnd,OptionArray[I]^.OptionHeading);
     INC(I);
  END;
  WRITE_ANSI(
    FirstLineOfMenu+OptionCount,40-TRUNC(OptionLength/2),
    KeyColour_Bkgnd,KeyColour_Frgnd,ExitProcOptionKey);
  WRITE_ANSI(
    FirstLineOfMenu+OptionCount,(40-TRUNC(OptionLength/2))+KeyToHeadingGap+1,
    OptionColour_Bkgnd,OptionColour_Frgnd,ExitPromptStr);
  IF ScreenFileDefined THEN
        CLOSE(TypedFileScreenBuffer);
  IF MachineCodeScreenDefined THEN
  BEGIN
       FINDFIRST(ScreenFileName,0,MachineCodeSearchRec);
       SizeOfMachineCodeData := MachineCodeSearchRec.SIZE;
       ASSIGN(MachineCodeScreenBuffer,MachineCodeFileName);
       REWRITE(MachineCodeScreenBuffer);
       WRITE(MachineCodeScreenBuffer,CHR($BB),CHR($17),CHR($01));
       WRITE(MachineCodeScreenBuffer,CHR($B9),CHR(LO(SizeOfMachineCodeData)),CHR(HI(SizeOfMachineCodeData)));
       WRITE(MachineCodeScreenBuffer,CHR($B4),CHR($02),CHR($8A),CHR($17),CHR($43));
       WRITE(MachineCodeScreenBuffer,CHR($51),CHR($53));
       WRITE(MachineCodeScreenBuffer,CHR($CD),CHR($21),CHR($5B),CHR($59),CHR($E2),CHR($F3));
       WRITE(MachineCodeScreenBuffer,CHR($B4),CHR($4C),CHR($CD),CHR($21));
       ASSIGN(TypedFileScreenBuffer,ScreenFileName);
       RESET(TypedFileScreenBuffer);
       WHILE NOT EOF(TypedFileScreenBuffer) DO
       BEGIN
        READ(TypedFileScreenBuffer,MachineCodeDataByte);
        WRITE(MachineCodeScreenBuffer,MachineCodeDataByte)
       END;
       CLOSE(MachineCodeScreenBuffer);
       ERASE(TypedFileScreenBuffer);
  END;

  OptionKeyList := OptionKeyList + ExitProcOptionKey;
  WRITELN(OutputBuffer,
    'WHAT C "',
    ANSILOCATE(OptionCount+FirstLineOfMenu+2,40-TRUNC(OptionLength/2)),
    ANSICOLOURBF(PromptColour_Bkgnd,PromptColour_Frgnd),
    PromptStr,'" ',OptionKeyList);
  WRITELN(OutputBuffer,'echo ',ANSILOCATE(1,1),ANSICOLOURBF(SA_OFF,SA_OFF),'');
  WRITELN(OutputBuffer,'GOTO ',BatchLabel_Options,'%WHAT%');
  FOR I := 1 TO OptionCount DO
  BEGIN
     WRITELN(OutputBuffer,':',BatchLabel_Options,OptionArray[I]^.OptionKey);
     WRITELN(OutputBuffer,'cls');
     FOR J := 1 TO MaximumDosCommands DO
     IF OptionArray[I]^.OptionDosCommands[J] <> '' THEN
     WRITELN(OutputBuffer,OptionArray[I]^.OptionDosCommands[J]);
     WRITELN(OutputBuffer,'goto ',BatchLabel_MainLoop);
  END;
  WRITELN(OutputBuffer,':',BatchLabel_Options,ExitProcOptionKey);
  IF ExitProcedureDefined THEN
  BEGIN
     J := 1;
     WHILE ExitProcArray[J]<>NIL DO
     BEGIN
        WRITELN(OutputBuffer,ExitProcArray[J]^.ExitProcDosCommands);
        INC(J)
     END
  END
  ELSE
  BEGIN
     WRITELN(OutputBuffer,'cd\');
     WRITELN(OutputBuffer,'cls')
  END;
  CLOSE(OutputBuffer);
  ReadyToGenerateMenu := TRUE

END;
PROCEDURE INITVARS;
var i : word;
BEGIN
  CommandLine := GETCOMMANDLINE;
  Verify_On := PARAM_QUALIFY(CommandLine,'V');
  CommandLineParameter1 := CAR(CommandLine);
  CommandLineParameter2 := CAR(CommandLine);
  Translate_If := OFF;
  Within_If := OFF;
  ExitPromptStr := 'Exit to DOS';
  TitleSet := FALSE;
  SuperTitleSet := FALSE;
  KeyGapSet := FALSE;
  DosVersionIs3 := FALSE;
  ExitProcedureDefined := FALSE;
  ScreenFileDefined := FALSE;
  InitialProcedureDefined := FALSE;
  MachineCodeScreenDefined := FALSE;
  SuperTitleStr := '';
  TitleStr := '';
  FirstLineOfMenu := 5;
  ExitProcOptionKey := 'X';
  BatchFileName := ADDFILETYPE(CommandLineParameter1,'.bat');
  OptionKeyList := '';
  BatchLabel_Options := 'MENUOPT';
  BatchLabel_MainLoop := 'MENULOOP';
  OptionKeysListStr := '';
  OptionColour_Bkgnd := SA_OFF;
  KeyColour_Bkgnd := SA_OFF;
  BoxColour_Bkgnd := SA_OFF;
  TitleColour_Bkgnd := SA_OFF;
  SuperTitleColour_Bkgnd := SA_OFF;
  PromptColour_Bkgnd := SA_OFF;
  OptionColour_Frgnd := SA_OFF;
  KeyColour_Frgnd := SA_OFF;
  BoxColour_Frgnd := SA_OFF;
  TitleColour_Frgnd := SA_OFF;
  SuperTitleColour_Frgnd := SA_OFF;
  PromptColour_Frgnd := SA_OFF;
  KeyToHeadingGap := 2;
  OptionLength := LENGTH(ExitPromptStr)+KeyToHeadingGap+1;
  PromptStr := 'Select first letter: ';
  ScreenFileName := ADDFILETYPE(BatchFileName,'.ESC');
  ReadyToGenerateMenu := FALSE;
  OptionCount := 0;
  FOR I := 1 TO MaximumOptions DO OptionArray[I] := NIL;
  FOR I := 1 TO MaximumDosCommands DO ExitProcArray[I] := NIL;
  for i := 1 to MaximumDosCommands do InitPRocArray[i] := Nil;
END;

BEGIN
  WriteLn('MenuManager V',VERSION,'.',UPDATE);
  WriteLn('(c)Copyright Bruce M. Axtens, 1992.');
  INITVARS;
  IF PARAMCOUNT<1 THEN
  ProcessingError(NOFILE);
  MNU_FileName := ADDFILETYPE(CommandLineParameter1,'.mnu');
  ASSIGN(InputBuffer,MNU_FileName);
  {$I-}
  RESET(InputBuffer);
  {$I+}
  IF IORESULT<>0 THEN
  ProcessingError(NOTFOUND);

  ProcessingLineCounter := 0;
  WHILE (NOT EOF(InputBuffer)) AND (NOT ReadyToGenerateMenu) DO
  BEGIN
     READLN(InputBuffer,MNU_Line);
     BUMP_COUNTER;
     LTRIM(MNU_Line);
     IF MNU_Line<>'' THEN
     BEGIN
      MDL_Command := UPPERCASE(CAR(MNU_Line));
      IF (Translate_If=ON) OR (Within_If=OFF) THEN
     	BEGIN
      IF Verify_On THEN
      WRITELN(MDL_Command,' ',MNU_Line);
          ScratchCounter2 := ParseMDL_Command(UPPERCASE(COPY(MDL_Command,2,255)));
          CASE ScratchCounter2 OF
              0 : ProcessingError(NOKEYWD);
           		1 : BEGIN END;
           		2 : BEGIN
                    BatchFileName := ADDFILETYPE(CAR(MNU_Line),'.BAT');
                    ScreenFileName := ADDFILETYPE(BatchFileName,'.ESC');
           			END;
              3 : VAL(CAR(MNU_Line),FirstLineOfMenu,ScratchCounter1);
           		4 : BEGIN
                    ScratchStr := CAR(MNU_Line);
                    SETSUPER(ScratchStr)
           			END;
           		5 : BEGIN
                    ScratchStr := CAR(MNU_Line);
                    SETTITLE(ScratchStr)
           			END;
           		6 : BEGIN
                    ScratchStr := CAR(MNU_Line);
                    SETEXIT(ScratchStr,CAR(MNU_Line))
           			END;
              7 : PromptStr := CAR(MNU_Line);
           		8 : BEGIN
                    ScratchStr := CAR(MNU_Line);
                    SETKEYGAP(ScratchStr)
           			END;
           		9 : BEGIN
                    ScratchStr := CAR(MNU_Line);
                    SETOPTION(ScratchStr,CAR(MNU_Line))
           			END;
              10 : ProcessingError(ENDOPTFOUND);
           		11 : FINISH;
              12 : DOSVER(CAR(MNU_Line));
              13 : SETCOLOUR(MNU_Line);
              14 : BatchLabel_MainLoop := CAR(MNU_Line);
              15 : BatchLabel_Options := CAR(MNU_Line);
           		16 : ;
           		17 : ;
              18 : SETKEYCOL(MNU_Line);
              19 : SETOPTCOL(MNU_Line);
              20 : SETPRMCOL(MNU_Line);
              21 : SETTTLCOL(MNU_Line);
              22 : SETSTLCOL(MNU_Line);
              23 : SETBOXCOL(MNU_Line);
              24 : ProcessingError(ENDEXITFOUND);
              25 : SETSCREEN(MNU_Line);
              26 : SETIF(CAR(MNU_Line));
              27 : IF Within_If=OFF THEN ProcessingError(ENDIFFOUND);
              28 : WriteLn(#13,CAR(MNU_Line));
              29 : ProcessingError(FNDINCLUDE);
           		30 : SETINIT;
              31 : ProcessingError(ENDINITFOUND);
           		32 : BEGIN
                          SETSCREEN(MNU_Line);
                          MachineCodeScreenDefined := TRUE;
                          MachineCodeFileName := ADDFILETYPE(ScreenFileName,'.COM')
                		END;
        	END; {CASE}
     	END
     	ELSE
        IF MDL_Command = '*ENDIF' THEN
          Translate_If := ON
	END;
  END; {IF NOT EOF}
  IF NOT ReadyToGenerateMenu THEN
    ProcessingError(NOFINISH);
  CLOSE(InputBuffer);
  WriteLn(' lines processed.');
  HALT;
END.
