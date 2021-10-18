// v088: Preamble: This may not be a best practice, you have to pay a runtime cost to map pointer to type
// and the type_fixed array must be updated or generated.
//
// Alternatives to run-time type information may be:
//   Share a common member then use compiler cast (see how_to/160_type_restrictions.jai)
//   Move variables into 100% compile time types (rely on other techniques to reduce codegen)
//     (Maybe it is fast to have 70,000 types? @me)
#import "Basic";

X :: struct { id := 4; }
Y :: struct { aggressive := true; }

type_id_from_any :: (any : Any) -> s64
{
    for rtti_array {
        if it == any.type {
            return it_index;
        }
    }
    return -1;
}

check_const :: (text : string, $$T : Type) {
    print("% Constant: %\n", text, is_constant(T));
}

runtime_type_info :: (dest_name : string, source_name : string, fixed : [$N]Type) -> string {
    builder : String_Builder;
    for fixed {
        print_to_builder(*builder, "array_add(*%1, type_info(%2[%3]));\n", dest_name, source_name, it_index);
    }
    return builder_to_string(*builder);
}

type_fixed :: Type.[X, Y, struct {anonymous := true;} ];
rtti_array : [..]*Type_Info;
main :: ()
{
    rtti : string : #run runtime_type_info("rtti_array", "type_fixed", type_fixed);
    #insert rtti;
    print("type_fixed: %\n", type_fixed);
    check_const("type_fixed[0]", type_fixed[0]);
    print("rtti codegen:\n%\n",  rtti);
    print("rtti_array: %\n", rtti_array);

    x : X;
    any_x : Any = x;
    y : Y;
    any_y : Any = y;
    z : struct {anonymous := true;};
    zz : struct {anonymous := true;};
    any_z : Any = z;
    print("% [any_x]\n", type_id_from_any(any_x));
    print("% [any_y]\n", type_id_from_any(any_y));
    print("% [any_z]\n", type_id_from_any(any_z));

    print("z (anonymous) type_info %\n", type_info(type_of(z)));
    print("zz (anonymous) type_info %\n", type_info(type_of(zz)));
    print("type_fixed[2] (anonymous) type_info %\n", type_info(type_fixed[2]));
}
