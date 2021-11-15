// v93
// 10,000 types generate an 11MB executable in about 64s on ryzen 4700U
// by the time you reach 70k+ types it is hours to compile
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

member_count := 0;
scan_type :: (t : $T)
{
    member_count += type_info(T).members.count;
}

make_type :: ($index : s64)
{
    #insert #run sprint("x : struct { foo% : s64; };", index);
    scan_type(x);
}

main :: ()
{
    #insert #run macro_N("make_type", 10000);
    print("%\n", member_count);
}
