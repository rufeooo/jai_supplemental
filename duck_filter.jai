// v92
// extends the example duck_compare to include filter function invocations
#import "Basic";

// Linear expansions at compile time
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

// Deref collapses pointers into immutable copies (reducing codegen)
deref :: (x : *$T) -> T #expand { return <<x; }
deref :: (x : $T) -> T #expand #modify { if (T.type == .POINTER) T = null; } { return x; }

// for_each member of A (left-hand side) compare to member of B (right-hand side)
// member PROCEDURES invoke with an immutable copy of B (right-hand side)
duck_filter :: (lhs : $A, rhs : $B) -> bool
{
    lhs_members :: () -> []Type_Info_Struct_Member { return type_info(type_of(lhs)).members; };
    each_member :: ($index : s64) #expand
    {
        member_name :: #run lhs_members()[index].name;
        #if #run lhs_members()[index].type.type == .PROCEDURE {
            #insert #run sprint("`result &= (lhs.%1(deref(rhs)));", member_name);
        }
        else {
            #insert #run sprint("`result &= (lhs.%1 == rhs.%1);", member_name);
        }
    }

    result := true;
    #insert #run macro_N("each_member", #run lhs_members().count);
    return result;
}

perspective : *thingS;
perspective_room : *roomS;
perceive_unit :: (other : $T) -> bool
{
    if perspective.is_blind return false;
    if perspective.blessed_with_truesight return true;

    return (perspective_room.is_lit || other.is_lit) && !other.is_invisible;
}

thingS :: struct {
    id : s64;
    name : string;
    is_lit : bool;
    is_invisible : bool;
    is_blind : bool;
    blessed_with_truesight : bool;
}
roomS :: struct {
    using thing : thingS;
}

initF :: #type (thing : *thingS);
main :: ()
{
    thing_array : [..]thingS;
    room_array : [..]roomS;

    ant_init :: (thing : *thingS) {
        // normal!
    }
    firefly_init :: (thing : *thingS) {
        thing.is_lit = true;
    }
    jon_init :: (thing : *thingS) {
        thing.blessed_with_truesight = true;
    }
    ghost_init :: (thing : *thingS) {
        thing.is_invisible = true;
    }
    bat_init :: (thing : *thingS) {
        thing.is_blind = true;
    }
    universe :: string.["ant", "firefly", "jon", "ghost", "bat"];
    ini :: initF.[ant_init, firefly_init, jon_init, ghost_init, bat_init];
    for universe {
        t := array_add(*thing_array);
        t.name = it;
        ini[it_index](t);
    }

    sunny_meadow_init :: (thing : *thingS) {
        thing.is_lit = true;
    }
    dark_forest_init :: (thing : *thingS) {
        thing.is_lit = false;
    }
    space :: string.["sunny_meadow", "dark_forest"];
    space_ini :: initF.[sunny_meadow_init, dark_forest_init];
    for space {
        t := array_add(*room_array);
        t.name = it;
        space_ini[it_index](t);
    }

    for thing_array print("%\n", it);

    search :: (filter : $T) #expand {
        print("\nSEARCH % ", filter);
        for type_info(type_of(filter)).members {
            if it_index print(", ");
            print("%", it.name);
        }
        print("\n");
        
        for room_index: 0..room_array.count-1 {
            perspective_room = *room_array[room_index];
            print("-- standing in %\n", perspective_room.name);
            for thing_index: 0..thing_array.count-1 {
                perspective = *thing_array[thing_index];
                print("  -- as %\n", perspective.name);

                for thing_array {
                    if duck_filter(filter, it) {
                        print("    sees %\n", it.name);
                    }
                }
            }
        }
    }

    look : struct { _see :: perceive_unit; };
    search(look);
    look_at : struct { name : string; _see :: perceive_unit; }
    look_at.name = "ghost";
    search(look_at);
}
