unit xfile;
interface
        function read_line( var b : text) : string;
        procedure write_line( var b : text; s : string);
        function openread( var b: text; s:string) : boolean;
        function openwrite( var b : text;s:string) : boolean;
        procedure enable_redirected_files;

implementation
function read_line;
var c : char;
    t : string;
    f : boolean;
begin
        f := false;
        t := '';
        repeat
        begin
                read(b,c);
                t := t + c;
                if ((c=^j) or (eof(b))) then f:=true
        end
        until f;
        read_line := t;
end;

PROCEDURE WRITE_LINE;
VAR I : WORD;
BEGIN
        FOR I := 1 TO LENGTH(S) DO WRITE(b,S[I])

END;
function openread;
begin
        assign(b,s);
        {$i-}
        reset(b);
        {$i+}
        openread := (ioresult=0)

end;
function openwrite;
begin
        assign(b,s);
        {$i-}
        rewrite(b);
        {$i+}
        openwrite := (ioresult=0)

end;
procedure enable_redirected_files;
begin
     assign(input,'');
     reset(input);
     assign(output,'');
     rewrite(output)

end;
end.
