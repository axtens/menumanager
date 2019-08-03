{$M $8000,$8000,$8000}
USES xparam, XDOS,DOS,XSTRING;
VAR
   BUFF : TEXT;
   cl, FILENAME, OUTPUTFILE, MAINPROG, INREC, KWD : STRING;
   SUBLIST : ARRAY [1..50] OF STRING;
   I,J,k : WORD;

BEGIN
     Writeln('MAKEMM - Make utility for MenuManager v1.0');
     Writeln('(c)Copyright Bruce M. Axtens, 1992.);

     cl := GETCOMMANDLINE;
     FILENAME := ADDFILETYPE(CAR(cl),'.MKE');
     ASSIGN(BUFF,FILENAME);
     {$I-}
     RESET(BUFF);
     {$I+}
     IF IORESULT<>0 THEN
     BEGIN
          WRITELN(FILENAME,' not found.');
          HALT
     END;
     J := 0;
     WHILE NOT EOF(BUFF) DO
     BEGIN
          READLN(BUFF,INREC);
          KWD := CAR(INREC);
          UPPER(KWD);
          I := LISTINDEX(RIGHTFILL(KWD,6)+',','REM   ,MAIN  ,SUB   ,OUTPUT,',7);
          CASE I OF
               0 : BEGIN
                        WRITELN('Keyword ',KWD,' not known.');
                        HALT
                   END;
               1 : ;
               2 : IF INREC<>'' THEN
                      MAINPROG := ADDFILETYPE(CAR(INREC),'.MNU')
                   ELSE
                   BEGIN
                        WRITELN('No main program defined.');
                        HALT
                   END;
               3 : BEGIN
                        WHILE INREC<>'' DO
                        BEGIN
                             INC(J);
                             SUBLIST[J] := ADDFILETYPE(CAR(INREC),'.MNU')
                        END
                   END;
               end;
      END;
      CLOSE(BUFF);
      IF J<>0 THEN
         FOR I := 1 TO J DO
              k := invoke('mm.exe',SUBLIST[I]+' '+cl);
      k := invoke('mm.exe',MAINPROG+' '+cl);

END.


