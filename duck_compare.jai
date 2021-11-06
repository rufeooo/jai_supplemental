// v91
// see also how_to/160_type_restrictions.jai
#import "Basic";

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

// Thing is often identified by name or id
thingS :: struct {
    of : [4]ofS;
    id : s64;
    name : string;
}
// reference to another thing
ofS :: struct { othing : s64; }
operator == :: (lhs : ofS, rhs : ofS) -> bool { return lhs.othing == rhs.othing; }

// 1:many comparison type
one_ofS :: struct { of : ofS; }
operator == :: (one_of : one_ofS, other : [$N]ofS) -> bool
{
    for other {
        if one_of.of == it return true;
    }
    return false;
}

// for_each field of A (left-hand side) compare to B (right-hand side)
duck_compare :: (lhs : $A, rhs : $B) -> bool
{
    lhs_member_array :: #run member_array(type_of(lhs));
    member_array :: ($type : Type) -> [..]string {
        array : [..]string;
        for type_info(type).members {
            array_add(*array, it.name);
        }
        return array;
    }
    result := true;
    each_member :: ($index : s64) #expand
    {
        #insert #run sprint("`result &= (lhs.%1 == rhs.%1);", lhs_member_array[index]);
    }
    #insert #run macro_N("each_member", lhs_member_array.count);
    return result;
}

main :: ()
{
    // x is anonymous
    x : struct {
        name : string;
        id : s64;
        of : one_ofS;
    }
    // with some values we want to search for
    x.name = "alan";
    x.id = 1;
    print("%\n", x);

    // Here are some things to search
    search :: ($T : Type) #expand {
        print("--%--\n", T);
        t : T;
        s := `x;
        print("compare [mismatch id/name] %\n", duck_compare(s, t));
        t.id = 2;
        t.name = "alan";
        print("compare [mismatch id] %\n", duck_compare(s, t));
        t.id = 1;
        t.name = "bob";
        print("compare [mismatch name] %\n", duck_compare(s, t));
        t.name = "alan";
        t.id = 1;
        print("compare [expect true] %\n", duck_compare(s, t));
    }
    search(thingS);

    // We can use thingS at a different offset!
    other_thingS :: struct {
        array : [..]s64;
        using thing : thingS;
    }
    // And still search
    search(other_thingS);

    // and so forth
    another_thingS :: struct {
        using thing: thingS;
        pointer_array : [..]*void;
    }
    search(another_thingS);
}
