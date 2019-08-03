unit xnumber;
interface
         function ToRadix( Number : real;  Radix : word) : string;
         function FromRadix( Number : string; Radix : word) : real;
         function power( Number : real; Pwr : word) : real;
         function Binary( Number : word) : string;
         function hexbyte( B : byte) : string;
         function hexword( W : word) : string;
         FUNCTION SIGN( I : INTEGER) : INTEGER;
         function hex2dec( s:string) : word;

implementation
function power;
var
   i : word;
   x : real;

function lne( x : real) : real;
begin
     if x<=0 then lne:=0 else lne:=ln(x)

end;

begin {power}
     power := exp( lne(Number) * Pwr)

end;

function ToRadix;
const
     list : array[1..62] of char =
     '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
var
   t : string;
   top, bot : real;
   listlen  : word;

procedure calc_top;
begin
     top := int(Number/Radix)
end;

begin
     listlen := length(list);
     if ((Radix>listlen) or (Radix<2)) then ToRadix := ''
     else
         begin
              t := '';
              calc_top;
              while top<>0.0 do
              begin
                   bot := frac(Number/Radix) * Radix;
                   t := list[trunc(bot)+1]+t;
                   Number := top;
                   calc_top
              end;
              t := list[trunc(Number)+1]+t;
              ToRadix := t
          end;
end;

function FromRadix;
const
     list : array[1..62] of char =
     '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
var      sum    : real;
         c      : char;
         nlen   : word;
         decode : string;
         i, m   : word;


begin  {FromRadix}
     sum := 0.0;
     nlen := length(Number);
     decode := copy(list,1,Radix);
     for i := 0 to nlen-1 do
     begin
          c := Number[nlen-i];
          m := pos(c,decode);
          if m<>0 then sum := sum + (( m - 1 ) * power(Radix,i));
     end;
     FromRadix := sum

end;
function binary;
var
   t : string;
   i : integer;

begin
     t := '';
     for i := 0 to 15 do
         t := chr( $30 + ord(((number shr i) and 1) = 1)) + t;
     binary := t

end;
function hexbyte;
var
   hinyb, lonyb : byte;

begin
     hinyb := ( b and $f0) shr 4;
     lonyb := b and $0f;
     hexbyte := chr((hinyb + 7 * ord(hinyb > 9)) + $30)+
                chr((lonyb + 7 * ord(lonyb > 9)) + $30)

end;

function hexword;
begin
     hexword := hexbyte(hi(W))+hexbyte(lo(W))

end;
FUNCTION SIGN;
BEGIN
     IF I<0 THEN
        SIGN := -1
     ELSE
         IF I=0 THEN
            SIGN := 0
         ELSE
             SIGN := 1

END;
function hex2dec;
var t, i, j, m, g : word;
    k             : char;

begin
     t := 0;
     i := length(s);
     g := 0;
     for j := i downto 1 do
     begin
          k := upcase(s[j]);
          m := (ord(k) and $0f);
          if k in ['A'..'F'] then
             inc(m,9);
          t := t + trunc(power(16,g)) * m;
          inc(g)

      end;
      hex2dec := t

end;
end.
