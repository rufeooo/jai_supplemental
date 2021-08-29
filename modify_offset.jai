// version 081
#import "Basic";

// offset may be performed on any pointer type
ptr_offset :: (ptr : *$T, offset : s64) -> *T
#modify {
    // codegen uses a single type: *void
    T = type_info(void);
}
{
    return ptr + offset;
}

linkS :: struct {
    prev : *linkS;
    next : *linkS;
}

unitS :: struct {
    uid : s64;
    using link : linkS;
}

type_using_offset :: ($T : Type, $U : Type) -> s64
{
    ti := type_info(T);
    ui := type_info(U);
    for ti.members
    {
        if it.flags & .USING == 0 continue;
        if it.type == ui return it.offset_in_bytes;
    }

    assert(false);
    return 0;
}

main :: ()
{
    unit : unitS;
    auto_link : *linkS = *unit;
    offset := type_using_offset(unitS, linkS);
    manual_link : *linkS = ptr_offset(*unit, offset);
    unit_from_link : *unitS = ptr_offset(auto_link, -offset);

    assert(auto_link == manual_link);
    assert(unit_from_link == *unit);

    print("% *unit, % *auto_link\n", *unit, auto_link);
    print("% offset\n", offset);
    print("% unit_from_link % manual_link\n", unit_from_link, manual_link);
}
