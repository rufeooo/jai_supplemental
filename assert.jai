// v93
#import "Basic";

WITH_ASSERT :: true;

// parameters to the assert are processed when WITH_ASSERT is true
#if WITH_ASSERT {
    my_assert :: assert;
}
else {
    my_assert :: (code_va : ..Code) { }
}

is_power_of_two :: (val : s64) -> bool
{
    result := (val-1)&val == 0;
    print("is_power_of_two % (%)\n", result, val);
    return result;
}

x_mod_y_fast :: (x : s64, y : s64) -> s64
{
    // is_power_of_two(y) is called only when WITH_ASSERT is true
    my_assert(is_power_of_two(y), "y must be a power of two!");
    return (y-1) & x;
}

main :: ()
{
    args := get_command_line_arguments();

    // a runtime value makes it easy to test violations of the assert
    for 0..42 {
        x := it;
        print("% %% % == %\n", x, args.count, x_mod_y_fast(x, args.count));
    }
}
