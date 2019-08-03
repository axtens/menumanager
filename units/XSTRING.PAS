{$V-}
UNIT XSTRING;
INTERFACE
         USES XDOS,DOS;
CONST
     CAR_OPENS : STRING = '"''`';
     CAR_CLOSE : STRING = '"''`';
     FUNCTION ISWHITESPACE( C : CHAR) : BOOLEAN;
     PROCEDURE LTRIM( VAR S : STRING);
     FUNCTION TRIMLEFT( S : STRING) : STRING;
     PROCEDURE RTRIM( VAR S : STRING);
     FUNCTION TRIMRIGHT( S : STRING) : STRING;
     FUNCTION SPACES( I : WORD) : STRING;
     FUNCTION RIGHTFILL( S : STRING; I : WORD) : STRING;
     FUNCTION LEFTFILL( S : STRING; I : WORD) : STRING;
     FUNCTION CAR( VAR S : STRING) : STRING;
     FUNCTION FIRST( S : STRING) : STRING;
     FUNCTION BUTFIRST( S : STRING) : STRING;
     FUNCTION REPEATSTRING( I : WORD; S : STRING) : STRING;
     FUNCTION LISTINDEX(FIND, INTHIS : STRING; WIDTH : WORD) : WORD;
     FUNCTION ADDFILETYPE(FNAME, FTYPE :STRING) : STRING;
     FUNCTION STRIN( W : WORD) :STRING;
     FUNCTION CENTREINDEX( S : STRING; W : WORD) : WORD;
     FUNCTION CENTRESTRING( S : STRING; W : WORD) : STRING;
     FUNCTION YESNO( S: STRING) : BOOLEAN;
     FUNCTION CRUSH( S : STRING) : STRING;
     FUNCTION DETAB( S : STRING; W : WORD) : STRING;
     FUNCTION ESCAPE( S : STRING) : STRING;
     FUNCTION STRIP7( S : STRING) : STRING;
     FUNCTION ZEROFILL( S : STRING; W : WORD) : STRING;
     FUNCTION SOUNDEX( S : STRING) : STRING;
     FUNCTION LOCASE( C : CHAR) : CHAR;
     PROCEDURE UPPER( VAR S : STRING);
     FUNCTION LOWERCASE( S : STRING): STRING;
     FUNCTION UPPERCASE( S : STRING): STRING;
     FUNCTION STUFF( S : STRING; B, E:WORD; T : STRING) : STRING;
     FUNCTION INSTR( VECTOR : WORD; INTHIS, FINDTHIS : STRING) : INTEGER;
     function findrepl( dataline, find, repl : STRING) : STRING;
IMPLEMENTATION
CONST
     SPACE = ' ';
     HTAB  = ^I;
     MINUS = '-';
     PLUS  = '+';

FUNCTION ISWHITESPACE;
BEGIN
     ISWHITESPACE := (C IN [#0..#32,#127])
END;

PROCEDURE LTRIM;
VAR
   I, J : WORD;
BEGIN
     I := LENGTH( S);
     J := 1;
     WHILE ((J<I) AND (S[J] IN [SPACE,HTAB])) DO
           INC(J);
     DELETE( S,1,J-1)

END;

FUNCTION TRIMLEFT;
VAR
   I, J : WORD;

BEGIN
     I := LENGTH(S);
     J := 1;
     WHILE ((J<I) AND (S[J] IN [SPACE,HTAB])) DO
           INC(J);
     DELETE( S,1,J-1);
     TRIMLEFT := S
END;

PROCEDURE RTRIM;
VAR
   I, J : WORD;
BEGIN
     I := LENGTH( S);
     J := 1;
     WHILE ((I>=J) AND (S[I] IN [SPACE,HTAB]) ) DO
           DEC(I);
     DELETE( S,I+1,255)

END;

FUNCTION TRIMRIGHT;
VAR
   I, J : WORD;
BEGIN
     I := LENGTH( S);
     J := 1;
     WHILE ((I>=J) AND (S[I] IN [SPACE,HTAB]) ) DO
           DEC(I);
     DELETE( S,I+1,255);
     TRIMRIGHT := S

END;

FUNCTION REPEATSTRING;
VAR K : WORD;
    M : STRING;

BEGIN
     M := '';
     FOR K := 1 TO I DO M := CONCAT(M,S);
     REPEATSTRING := M
END;

FUNCTION SPACES;
BEGIN
     SPACES := REPEATSTRING(I,SPACE)

END;

FUNCTION RIGHTFILL;
BEGIN
     IF LENGTH(S)<I THEN
        RIGHTFILL := CONCAT(S,SPACES(I-LENGTH(S)))
     ELSE
        IF LENGTH(S)=I THEN
           RIGHTFILL := S
        ELSE
           RIGHTFILL := COPY(S,1,I)

END;
FUNCTION LEFTFILL;
BEGIN
     IF LENGTH(S)<I THEN
        LEFTFILL := CONCAT(SPACES(I-LENGTH(S)),S)
     ELSE
         IF LENGTH(S)=I THEN
            LEFTFILL := S
         ELSE
             LEFTFILL := COPY(S,1,I)

END;


FUNCTION CAR;
VAR I,
    DELIM_INDEX:WORD;
    DELIM : STRING;
BEGIN
     I:=0;
     REPEAT
          INC(I)
     UNTIL (I=255) OR (NOT ISWHITESPACE(S[I])); { IN [' ',#9]));}
     S := COPY(S,I,255);
     DELIM_INDEX := POS(S[1],CAR_OPENS);
     IF DELIM_INDEX<>0 THEN {IF S[1] IN ['''','"','`'] THEN}
     BEGIN
	  DELIM := CAR_CLOSE[DELIM_INDEX]; {S[1];}
          S :=COPY(S,2,255);
          I := POS(DELIM,S);
          IF I=0 THEN
          BEGIN
               CAR := S;
               S := ''
          END
          ELSE
          BEGIN
              CAR := COPY(S,1,I-1);
              S := COPY(S,I+1,255);
          END;
      END
      ELSE
      BEGIN
           I := POS(' ',S);
           IF I = 0 THEN I := POS(#9,S);
           IF I=0 THEN
           BEGIN
                CAR := S;
                S := '';
           END
           ELSE
           BEGIN
                CAR := COPY(S,1,I-1);
                S := COPY(S,I+1,255)
           END;
       END;
END;
FUNCTION FIRST;
VAR DELIM_INDEX,
    I:WORD;
    DELIM:STRING;
BEGIN
     I:=0;
     REPEAT
          INC(I)
     UNTIL (I=255) OR (NOT ISWHITESPACE(S[I]));
     S := COPY(S,I,255);
     DELIM_INDEX := POS(S[1],CAR_OPENS);
     IF DELIM_INDEX<>0 THEN {IF S[1] IN ['''','"','`'] THEN}
     BEGIN
          DELIM := CAR_CLOSE[DELIM_INDEX]; {S[1];}
     	  S :=COPY(S,2,255);
          I := POS(DELIM,S);
          IF I=0 THEN
               FIRST := S
          ELSE
              FIRST := COPY(S,1,I-1);
      END
      ELSE
      BEGIN
           I := POS(' ',S);
           IF I = 0 THEN I := POS(#9,S);
           IF I=0 THEN
                FIRST := S
           ELSE
                FIRST := COPY(S,1,I-1);
       END;
END;
FUNCTION BUTFIRST;
VAR T : STRING;
BEGIN
     T := S;
     DELETE(T,1,LENGTH(FIRST(S)));
     BUTFIRST := TRIMLEFT(T)
END;

FUNCTION LISTINDEX;
VAR
   I : WORD;

BEGIN
     I := POS(FIND, INTHIS);
     IF (I=0) THEN
        LISTINDEX := 0
     ELSE
         LISTINDEX := TRUNC(I/WIDTH)+1

END;
FUNCTION ADDFILETYPE;
{CONST
     DOT = '.';
     DELIM = '\:';
VAR
   I,
   DOTPOINT,
   DISTANCE : WORD;
   TMP : STRING;

BEGIN
     DOTPOINT := LENGTH(FNAME)+1;
     DISTANCE := PRED(DOTPOINT);
     I := DISTANCE;
     REPEAT
     BEGIN
          TMP := FNAME[I];
          IF (TMP=DOT) THEN
          BEGIN
               DOTPOINT := I;
               I := 1
          END
          ELSE
               IF (POS( TMP, DELIM)<>0) THEN
                  I := 1
               ELSE I := PRED(I);
     END
     UNTIL (I=1);
     TMP := COPY( FNAME, 1, DOTPOINT-1);
     ADDFILETYPE := TMP + FTYPE;

END;}
VAR FILEDIR : STRING[67];
    FILENAME : STRING[8];
    FILETYPE : STRING[4];
BEGIN
     FSPLIT(FEXPAND(FNAME),FILEDIR,FILENAME,FILETYPE);
     ADDFILETYPE := FILEDIR+FILENAME+FTYPE;
END;

FUNCTION STRIN;
VAR T : STRING;
BEGIN
     STR(W,T);
     STRIN := T

END;
FUNCTION CENTREINDEX;
BEGIN
     CENTREINDEX := TRUNC((W/2)-LENGTH(S)/2)
END;
FUNCTION CENTRESTRING;
BEGIN
     CENTRESTRING := SPACES(CENTREINDEX(S,W))+S
END;
FUNCTION YESNO;
VAR
   CH : CHAR;

BEGIN
     WRITE(S);
     CH := READKEY;
     WHILE NOT (UPCASE(CH) IN ['Y','N']) DO CH := READKEY;
     WRITELN(CH);
     YESNO := UPCASE(CH)='Y'

END;
FUNCTION CRUSH;
VAR
        TEMP1, TEMP2 : STRING;
        I            : WORD;
BEGIN
        TEMP2 := '';
        FOR I := 1 TO LENGTH(S) DO
        BEGIN
                TEMP1 := COPY(S, I, 1);
                IF TEMP1 <> SPACE THEN TEMP2 := TEMP2 + TEMP1
        END;
        CRUSH := TEMP2
END;
FUNCTION DETAB;
VAR
   K : WORD;
BEGIN
     K := POS(HTAB,S);
     WHILE K<>0 DO
     BEGIN
          DELETE(S,K,1);
          INSERT( REPEATSTRING(8-(K MOD 8),' '),S,K);
          K := POS(HTAB,S)
     END;
     DETAB := S

END;
FUNCTION ESCAPE;
BEGIN
     ESCAPE := #27+S

END;
FUNCTION STRIP7;
VAR I : WORD;
    T : STRING;
BEGIN
     T := S;
     FOR I := 1 TO LENGTH(S) DO T[I] := CHR( ORD( S[I]) AND $7F);
     STRIP7 := T

END;
FUNCTION ZEROFILL;
VAR I : WORD;
BEGIN
     I := LENGTH(S);
     IF I>W THEN ZEROFILL := S ELSE ZEROFILL := REPEATSTRING(W-I,'0')+S

END;
FUNCTION SOUNDEX;
VAR
        FIRSTCHAR : CHAR;
        I : WORD;
        CHAR1,
        CHAR2 : CHAR;
        LIST1 : STRING;

FUNCTION F_SOUNDEX( LETTER : CHAR) : CHAR;
CONST
        SDXSTRNG : STRING[42] = 'A0B1C2D3E0F1G2H0I0J2K2L4M5N5O0P1Q2R6S2T3U0V1X2Y0Z2';
BEGIN
        F_SOUNDEX := SDXSTRNG[POS( LETTER, SDXSTRNG)+1]
END;

BEGIN
     LIST1 := '';
     FIRSTCHAR := S[1];
     IF (FIRSTCHAR IN ['A'..'Z']) THEN
     BEGIN
          FOR I := 1 TO LENGTH(S) DO
          BEGIN
               CHAR1 := F_SOUNDEX( S[I]);
               IF (CHAR1 IN ['0'..'6']) THEN
                  LIST1 := LIST1 + CHAR1;
          END;
          CHAR2 := ' ';
          I := 1;
          WHILE (I <= LENGTH(LIST1)) DO
          BEGIN
               CHAR1 := LIST1[I];
               IF (CHAR1<>'') THEN
               BEGIN
                    IF (CHAR1=CHAR2) THEN
                       DELETE(LIST1,I-1,1)
                    ELSE
                        INC(I);
                    CHAR2 := CHAR1
               END
               ELSE
                   EXIT;
           END;
           LIST1[1] := FIRSTCHAR;
     END;
     SOUNDEX := COPY(LIST1,1,5)
END;
FUNCTION LOCASE;
BEGIN
     IF C IN ['A'..'Z'] THEN
        LOCASE := CHR(ORD(C)+32)
     ELSE
        LOCASE := C

END;
PROCEDURE UPPER;
VAR I : WORD;

BEGIN
     FOR I := 1 TO LENGTH(S) DO
         IF S[I] IN ['a'..'z'] THEN S[I] := UPCASE(S[I]);

END;
{$L CASE}
FUNCTION LOWERCASE; EXTERNAL;
FUNCTION UPPERCASE; EXTERNAL;
FUNCTION STUFF;
BEGIN
     STUFF := COPY(S,1,B)+T+COPY(S,E,255)

END;
FUNCTION INSTR;
{FUNCTION POSITION : WORD;
BEGIN
     POSITION := POS(INTHIS,COPY(FINDTHIS,VECTOR,255))
END;
BEGIN
     INSTR := (POSITION + ORD(POSITION<>0)*VECTOR)

END;
}
VAR I : WORD;
    T : STRING;
BEGIN
     T := COPY(INTHIS,VECTOR,255);
     I := POS(FINDTHIS,T);
     IF I>0 THEN
        INSTR := I + VECTOR - 1
     ELSE
         INSTR := 0

END;
FUNCTION FINDREPL;
var
   matched,
   oldmatched : integer;
   temp : STRING;
begin
     matched := 1;
     temp := dataline;
     repeat
     begin
          oldmatched := matched-1;
          matched := pos( find, copy(temp,matched,255));
          if (matched>0) then
          begin
               matched := matched+oldmatched;
               delete(temp,matched,length(find));
               insert(repl,temp,matched);
               matched := matched+length(find);
          end
      end;
      until ((matched=0) or (matched>255));
      findrepl := temp;
end;

END.
