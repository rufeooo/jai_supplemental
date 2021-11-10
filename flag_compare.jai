// v92

// linear expansion at compile time
macro_N :: (macro : string, $N : s64 = 1) -> string
{
    sb : String_Builder;
    for 0..N-1 {
        append(*sb, "{\n");
        print_to_builder(*sb, "  %(%);\n", macro, it);
        append(*sb, "}\n");
    }
    return builder_to_string(*sb);
}

// game enumerations
elementE :: enum_flags { FIRE; ICE; WATER; EARTH; AIR; }
directionE :: enum_flags { NORTH; EAST; SOUTH; WEST; }

// flag matching styles
all_flagS :: struct {}
operator == :: (match_flag : $T/all_flagS, flag : $U) -> bool { return (match_flag.flag & flag == match_flag.flag); }
any_flagS :: struct {}
operator == :: (match_flag : $T/any_flagS, flag : $U) -> bool { return (match_flag.flag & flag != 0); }
exclusive_flagS :: struct {}
operator == :: (exclusive_flag : $T/exclusive_flagS, flag : $U) -> bool { return (exclusive_flag.flag ^ flag == 0); }

usage :: ()
{
    // using an anonymous struct that leverages any_flagS for operator ==
    print("--- any flag match\n");
    is_water : struct { using _test : any_flagS; flag := elementE.WATER; }
    ice := elementE.ICE;
    print("The test of a true mystic, % is_water? % when any of %\n", ice, is_water == ice, is_water);
    // runtime changes to the flag are OK! Note the := in the declaration (non-const) above
    is_water.flag |= .ICE;
    print("Mystics require training too, % is_water? % when any of %\n", ice, is_water == ice, is_water);

    // Declaration of flags may also be const (performance win!)
    print("--- all flags match\n");
    is_ice_water : struct { using _test : all_flagS; flag :: elementE.ICE | .WATER; }
    ice_water :: elementE.WATER | .ICE;
    tumeric_ice_water := elementE.EARTH | ice_water;
    jalapeno_ice_water := elementE.FIRE | ice_water;
    print("% is ice_water? %\n", tumeric_ice_water, is_ice_water == tumeric_ice_water);
    print("% is ice_water? %\n", jalapeno_ice_water, is_ice_water == jalapeno_ice_water);
    print("% is ice_water? %\n", ice, is_ice_water == ice);

    print("--- exclusive set of flags\n");
    is_east_west_corridor : struct { using _test : exclusive_flagS; flag := directionE.EAST | .WEST; };
    room_exits_a := directionE.EAST | .WEST;
    room_exits_b := room_exits_a | .NORTH;
    room_exits_c := room_exits_a & ~.WEST;
    print("% is_east_west_corridor? %\n", room_exits_a, is_east_west_corridor == room_exits_a);
    print("% is_east_west_corridor? %\n", room_exits_b, is_east_west_corridor == room_exits_b);
    print("% is_east_west_corridor? %\n", room_exits_c, is_east_west_corridor == room_exits_c);
}

test :: ($name : string, $TEST : Type, $ENUM : Type)
{
    print("\n-- test %\n", name);

    // TODO: scope changes when mchoose macro is outside the callsite scope, wtf?
    // mchoose :: (flag : $U, $code : string, $depth : s64) #expand {
    //     #if (depth <= 0) {
    //         #insert code;
    //         return;
    //     }
    //     else {
    //         for enum_values_as_enum(U) {
    //             mchoose(it | flag, code, depth-1);
    //         }
    //     }
    // }

    enum_values_count :: #run type_info(ENUM).values.count;
    outer_inner_k :: ($index : s64) {
        outer_depth :: index/enum_values_count;
        inner_depth :: index%enum_values_count;
        mchoose :: (flag : $U, $code : string, $depth : s64) #expand {
            #if (depth <= 0) {
                #insert code;
                return;
            }
            else {
                for enum_values_as_enum(U) {
                    if it & flag != 0 continue;
                    mchoose(it | flag, code, depth-1);
                }
            }
        }

        match : struct { using _test : TEST; flag : ENUM; }
        outer :: #string EOF
            match.flag = flag;
            print("-- match % % choose %\n", name, match, inner_depth);
            inner :: "print(\"  vs. % [%]\\n\", flag, match == flag);";
            mchoose(cast (ENUM)0, inner, inner_depth);
        EOF
        mchoose(cast (ENUM)0, outer, outer_depth);
    }
    square :: x => x*x;
    #insert #run macro_N("outer_inner_k", #run square(enum_values_count));
}

test_misuse :: ()
{
    match_north : struct { using match_flag : all_flagS; flag :: directionE.NORTH; }
    element := elementE.FIRE;

    // Uncomment to see an error: Type mismatch. Type wanted: directionE; type given: elementE
    //print("element %, match_north %\n", element, match_north == element);
}

main :: ()
{
    usage();

    test("all_flag", all_flagS, elementE);
    test("all_flag", all_flagS, directionE);

    test("any_flag", any_flagS, elementE);
    test("any_flag", any_flagS, directionE);

    test("exclusive_flag", exclusive_flagS, elementE);
    test("exclusive_flag", exclusive_flagS, directionE);

    test_misuse();
}

#import "Basic";
