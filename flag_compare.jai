// v92
elementE : enum_flags { FIRE; ICE; WATER; EARTH; AIR; }
flag_opE : enum_flags { SET; NOT; }
match_flagS :: struct ($T : Type, $FLAG_OP := flag_opE.SET) { flag : T; }
operator == :: (match_flag : match_flagS($T, $FLAG_OP), flag : T) -> bool
{
    #if FLAG_OP == .SET {
        return (match_flag.flag & flag == match_flag.flag);
    }
    #if FLAG_OP == .NOT {
        return match_flag.flag & flag == 0;
    }
}

flag_is_set :: (flag : $T) -> match_flagS(T)
{
    match_flag : match_flagS(T);
    match_flag.flag = flag;
    return match_flag;
}

flag_is_not :: (flag : $T) -> match_flagS(T, .NOT)
{
    match_flag : match_flagS(T, .NOT);
    match_flag.flag = flag;
    return match_flag;
}

main :: ()
{
    element := elementE.ICE | .WATER;
    is_ice := flag_is_set(elementE.ICE);
    is_earth := flag_is_set(elementE.EARTH);
    not_air := flag_is_not(elementE.AIR);
    not_water := flag_is_not(elementE.WATER);
    print("element % is_ice %\n", element, is_ice == element);
    print("element % not_air %\n", element, not_air == element);
    print("element % is_earth %\n", element, is_earth == element);
    print("element % not_water %\n", element, not_water == element);
}

#import "Basic";
