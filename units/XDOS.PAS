unit xdos;
interface
         uses dos;
	
         procedure prtscr;
         function GetCommandLine : string;
         function param( flag : string; var num : word) : boolean;
         procedure warmboot;
         procedure coldboot;
         FUNCTION READKEY : CHAR;
         FUNCTION KEYPRESSED : BOOLEAN;
         PROCEDURE GOTOXY( X, Y : WORD);
         procedure clrscr;
         FUNCTION READKEYBYTE : BYTE;
         FUNCTION KEYSCAN : WORD;
         function timer : real;
         function command( S : string) : word;
         function Invoke( ppath, pline : string) : word;
         function videomode : byte;
         FUNCTION GET_EQUIPLIST : WORD;
implementation

procedure prtscr;
var
   REGS : Registers;
begin
     FILLCHAR(REGS,SIZEOF(REGS),0);
     intr($5,REGS)
end;

function GetCommandLine;
var i,j,k : word;
    t     : string;
begin
     i := PrefixSeg;
     j := mem[i:$80];
     if j=0 then
        GetCommandLine := ''
     else
     begin
          t := '';
          for k := 1 to j do t := t + chr(mem[i:$80+k]);
          GetCommandLine := t
     end;

end;

function param;
var
   tline : string;
   flag1 : string[2];
   i, j  : integer;
   needn : boolean;

begin
     num := 0;
     tline := GetCommandLine;
     needn := (flag[length(flag)] = ':');
     flag1 := '/' + flag;
     i := pos( flag1, tline);
     if (i=0) then
          param := false
     else
     begin
         if needn then
         begin
              val( copy( tline, i+length(flag), 255), num, j);
         end;
         param := true
     end;

end;
procedure warmboot;
begin
inline(
$55
/$BB/$34/$12
/$B8/$40/$00
/$8E/$D8
/$89/$1E/$72/$00
/$EA/$00/$00/$FF/$FF
/$5D
/$C3)

end;
procedure coldboot;
begin
inline(
$55
/$BB/$7f/$7f
/$B8/$40/$00
/$8E/$D8
/$89/$1E/$72/$00
/$EA/$00/$00/$FF/$FF
/$5D
/$C3)

end;
FUNCTION READKEY;
VAR
   REGS : REGISTERS;
BEGIN
     FILLCHAR(REGS,SIZEOF(REGS),0);
     REGS.AH := $00;
     INTR($16,REGS);
     READKEY := CHR(REGS.AL)
END;

FUNCTION KEYPRESSED;
VAR
   REGS : REGISTERS;
BEGIN
     FILLCHAR(REGS,SIZEOF(REGS),0);
     REGS.AH := $01;
     INTR($16,REGS);
     KEYPRESSED := ((REGS.FLAGS AND $40) = 0)
END;
PROCEDURE GOTOXY;
VAR
	regs : registers;
BEGIN
	fillchar(regs,sizeof(regs),0);
	regs.dh := X-1;
	regs.dl := Y-1;
	regs.ah := 2;
	intr($10,regs)
END;
procedure clrscr;
var regs : registers;
    i : byte;
begin
	fillchar(regs,sizeof(regs),0);
	for i := 1 to 25 do
	begin
		XDOS.gotoxy(i,0);
		regs.ah := 10;
		regs.al := $20;
		regs.cx := 80;
		intr($10,regs)
	end;
	gotoxy(1,1);

end;
FUNCTION READKEYBYTE;
BEGIN
     READKEYBYTE := ORD(READKEY)

END;
FUNCTION KEYSCAN;
VAR   REGS : REGISTERS;
      PATT : ARRAY [1..2] OF BYTE;
      SCAN : WORD ABSOLUTE PATT;
BEGIN
     FILLCHAR(REGS,SIZEOF(REGS),0);
     REGS.AX := $0000;
     INTR($16,REGS);
     PATT[1] := REGS.AH;
     PATT[2] := REGS.AL;
     KEYSCAN := SCAN

END;
function timer;
var
   a,b,c,d : word;

begin
     GetTime(a,b,c,d);
     Timer := a*3600+b*60+c+d/100

end;
function command;
begin
      SwapVectors;
      Exec(GetEnv('COMSPEC'), '/C ' + S);
      SwapVectors;
      command := DosError

end;
function Invoke;
begin
        SwapVectors;
        Exec(ppath,pline);
        SwapVectors;
        Invoke := DosExitCode
end;
function videomode;
const
     getvidmode = $0F;
var
    REGS : Registers;
begin
     FILLCHAR(REGS,SIZEOF(REGS),0);
     REGS.AH := GETVIDMODE;
     intr($10,REGS);
     videomode := REGS.AL

end;

FUNCTION GET_EQUIPLIST;
VAR
        REGS : REGISTERS;
BEGIN
     FILLCHAR(REGS,SIZEOF(REGS),0);
        INTR($11,REGS);
        GET_EQUIPLIST := REGS.AX
END;

END.
