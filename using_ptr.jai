// Jai version 077
#import "Basic";

prototypeS :: struct
{
    spawn_location : s64;
};

unitS :: struct
{
    using prototype : *prototypeS;
    health : s64;
};

main :: ()
{
    prototype : prototypeS = .{9000};
    unit : unitS;
    unit.prototype = *prototype;
    unit.health = 30;

    print("%\n", unit);
    print("% unit.spawn_location\n", unit.spawn_location);
}
