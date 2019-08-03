unit xansi;
interface
CONST   TOPLEFT = #218;
        TOPRIGHT = #191;
        BOTTOMLEFT = #192;
        BOTTOMRIGHT = #217;
        UPRIGHT = #179;
        LYINGDOWN = #196;
CONST
        sa_off = 0;
        sa_bold = 1;
        sa_faint = 2;
        sa_italic = 3;
        sa_blink = 5;
        sa_rapid = 6;
        sa_reverse = 7;
        sa_hidden = 8;
        sa_f_black = 30;
        sa_f_red = 31;
        sa_f_green = 32;
        sa_f_yellow = 33;
        sa_f_blue = 34;
        sa_f_magenta = 35;
        sa_f_cyan = 36;
        sa_f_white = 37;
        sa_b_black = 40;
        sa_b_red = 41;
        sa_b_green = 42;
        sa_b_yellow = 43;
        sa_b_blue = 44;
        sa_b_magenta = 45;
        sa_b_cyan = 46;
        sa_b_white = 47;
        sa_sub = 48;
        sa_super = 49;

        esc = #27;

        function ansicolour( w : word) : string;
        FUNCTION ANSILOCATE( R,C:WORD) : STRING;
        FUNCTION ANSICOLOURBF(B,F:WORD): STRING;

implementation
function strin(w:word):string;
VAR T : STRING;
BEGIN
     STR(w,T);
     STRIN := T

END;
function ansicolour;
VAR T : STRING;
BEGIN
        STR(w,T);
        ANSICOLOUR := CHR(27)+'['+T+'m'

END;

FUNCTION ANSILOCATE;
BEGIN
     ANSILOCATE := esc + '[' + strin(r) + ';' + strin(c) + 'H'

end;

function ansicolourbf;
begin
     ansicolourbf := esc + '[' + strin(b) + ';' + strin(f) + 'm'

end;
end.
