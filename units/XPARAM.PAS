{$v-}
unit xparam;
interface
uses xdos, xstring;

var
	pcnt : word;
	pstr : array [1..64] of string[127];
	procedure load_parameters( s : string);
	function param_qualify( var s : string; p : string) : boolean;
implementation
procedure load_parameters;
var i : word;
begin
	i := 1;
	while s<>'' do
	begin
		pstr[i] := car(s);
		inc(i)
	end;
	pcnt := i-1
end;
function param_qualify;

var 
	j : word;
        i : word;
begin
	j := 0;
	i := pos('/'+uppercase(p),uppercase(s));
	if i=0 then
		param_qualify := false
	else
	begin
                delete(s,i,length(p)+1);
		param_qualify := true
	end;
end;

end.
