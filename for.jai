#import "Basic";

unitS :: struct { uid : s64; }
filterS :: struct { view : [] unitS; min : s64; }
filter_min :: (unit_view : [] unitS, min : s64) -> filterS
{
    filter : filterS;
    filter.view = unit_view;
    filter.min = min;
    return filter;
}

for_expansion :: (filter : *filterS, body: Code, flags: For_Flags) #expand {
    using filter;
    for *=(flags & .POINTER != 0) <=(flags & .REVERSE != 0) `it, `it_index: view {
        if (it.uid >= min) #insert body;
    }
}

main :: ()
{
    unit_array := unitS.[.{1}, .{2}, .{3}, .{5}, .{8}];
    print("-- forward expansion\n");
    for filter_min(unit_array, 5) {
        print("%\n", it);
    }
    print("-- pointer expansion\n");
    for *filter_min(unit_array, 5) {
        new_uid := 9000+it_index;
        print("%->%\n", it.uid, new_uid);
        it.uid = new_uid;
    }
    print("-- reverse expansion\n");
    for <filter_min(unit_array, 5) {
        print("%\n", it);
    }

}
