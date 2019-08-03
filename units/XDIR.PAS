{$V-}
UNIT XDIR;
INTERFACE
  USES DOS;
  TYPE
    DirPTR = ^DirREC;
    DirREC = RECORD
                NAME : STRING
              END;

  VAR
    Dir : ARRAY [1..1000] OF DirPTR;
    DirCNT : WORD;

  PROCEDURE DirLoad ( MASK : STRING; FTYPE : WORD);
  Procedure DirUnLoad;

IMPLEMENTATION
PROCEDURE DirLoad;
VAR
  I : WORD;
  F : SEARCHREC;
  N : STRING;
BEGIN
  FOR I := 1 TO 1000 DO Dir[I] := NIL;
  I := 1;
  FINDFIRST(MASK,FTYPE,F);
  WHILE DOSERROR=0 DO
  BEGIN
       N := FEXPAND(F.NAME);
       NEW(Dir[I]);
       Dir[I]^.NAME := (N);
       FINDNEXT(F);
       INC(I)
  END;
  DirCNT := I-1

END;
Procedure DirUnLoad;
var i : word;
begin
  for i := 1 to DirCnt do Dispose(Dir[i])
end;
END.


