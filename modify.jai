#import "Basic";

// Code generation results in one function
test :: (x : $T)
// modify all T into a single instance of test(u64)
#modify {
    print("compile time, modify: %\n", T);
    T = type_info(u64);
}
{
    print("%: %\n", T, x);
}

main :: ()
{
    a : u8 = 1;
    b : u16 = 2<<8;
    c : u32 = 3<<16;
    d : u64 = 4<<32;

    // Implicit conversions exist for these types
    test(a);
    test(b);
    test(c);
    test(d);

    // The compiler halts on invalid conversions to u64:
    // The #modify block can also assign T to null for invalid conversions
    // test(*d);
}
