// v088: Preamble: This may not be a best practice, you have to pay a runtime cost to resolve pointer to type
// and the type_fixed array must be updated or generated.
//
// Alternatives to run-time type information may be:
//   Share a common member then use compiler cast (see how_to/160_type_restrictions.jai)
//   Move variables into 100% compile time types (rely on other techniques to reduce codegen)
//     (Maybe it is fast to have 70,000 types? @me)
#import "Basic";

check_const :: (text : string, $$T : Type) {
    print("% Constant: %\n", text, is_constant(T));
}

macro_N :: (macro : string, $N : s64) -> string
{
    sb : String_Builder;
    for 0..N-1 {
        print_to_builder(*sb, "%(%);\n", macro, it);
    }
    return builder_to_string(*sb);
}

X :: struct { id := 4; }
Y :: struct { aggressive := true; }
type_fixed :: Type.[X, Y, struct {anonymous := true;} ];

rtti_array : [..]*Type_Info;
runtime_type_info :: ($index : s64) #expand 
{
    array_add(*rtti_array, type_info(type_fixed[index]));
}

rtini_array : [..](*void);
runtime_initializer :: ($index : s64) #expand 
{
    array_add(*rtini_array, cast(*void) initializer_of(type_fixed[index]));
}

type_id_from_any :: (any : Any) -> s64
{
    for rtti_array {
        if it == any.type {
            return it_index;
        }
    }
    return -1;
}

any_from_type_info :: (ti : *Type_Info) -> Any #expand
{
    base_pointer : * void = alloc(ti.runtime_size, __temporary_allocator);
    any : Any = ---;
    any.value_pointer = base_pointer;
    any.type = ti;
    return any;
}

any_init :: (any : Any)
{
    type_id := type_id_from_any(any);
    if (type_id < 0) return;
    rtini_array[type_id](any.value_pointer);
}

main :: ()
{
    print("type_fixed: %\n", type_fixed);
    check_const("type_fixed[0]", type_fixed[0]);

    rtti_name :: "runtime_type_info";
    rtti :: #run macro_N(rtti_name, type_fixed.count);
    print("\ngenerating code for % type_info:\n%\n", rtti_name, rtti);
    #insert rtti;

    x : X;
    any_x : Any = x;
    y : Y;
    any_y : Any = y;
    z : struct {anonymous := true;};
    zz : struct {anonymous := true;};
    any_z : Any = z;
    print("rtti_array: %\n", rtti_array);
    print("type_id % [any_x]\n", type_id_from_any(any_x));
    print("type_id % [any_y]\n", type_id_from_any(any_y));
    print("type_id % [any_z]\n", type_id_from_any(any_z));

    print("\nAnonymous structures create unique type info:\n");
    print("z (anonymous) type_info %\n", type_info(type_of(z)));
    print("zz (anonymous) type_info %\n", type_info(type_of(zz)));
    print("type_fixed[2] (anonymous) type_info %\n", type_info(type_fixed[2]));

    // Initializer codegen
    ini_name :: "runtime_initializer";
    rtini :: #run macro_N(ini_name, type_fixed.count);
    print("\ngenerating code for %:\n%\n", ini_name, rtini);
    #insert rtini;

    print("initializing each type:\n");
    for 0..rtti_array.count-1 {
        any := any_from_type_info(rtti_array[it]);
        any_init(any);

        sb : String_Builder;
        print_item_to_builder(*sb, any);
        append(*sb, "\n");
        print(builder_to_string(*sb));
    }
}
