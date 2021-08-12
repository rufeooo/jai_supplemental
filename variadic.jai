// Jai version 077
#import "Basic";

combatS :: struct
{
    health : s64;
};

movementS :: struct
{
    stamina : s64;
};

basicS :: struct($T : Type)
{
    using only : T;
}

variadicS :: struct(T : ..Type)
{
    generate_fields :: () -> string
    {
        ret : String_Builder;

        for T print_to_builder(*ret, "using poly% : %;\n", it_index, it);
        print(builder_to_string(*ret));
        return builder_to_string(*ret);
    }
    #insert #run generate_fields();
}

combat_delta :: (combat : *combatS, delta : s64)
{
    combat.health -= delta;
}

movement_delta :: (movement : *movementS, delta : s64)
{
    movement.stamina -= delta;
}

main :: ()
{
    combat_instance : basicS(combatS);
    movement_instance : basicS(movementS);

    // Normal C-style activity
    combat_delta(*combat_instance, 3);
    movement_delta(*movement_instance, 1);

    // thanks compiler! we can't do this :)
    // combat_delta(*movement_instance, 2);
    // movement_delta(*combat_instance, 1);

    both_instance : variadicS(combatS, movementS);
    // Cool!! Direct access.. many types' fields
    stamina := both_instance.stamina;
    health := both_instance.health;

    // God-like: Function re-use for combinatoric types
    combat_delta(*both_instance, 2);
    movement_delta(*both_instance, 1);
    print("%\n", both_instance);

    // Type info
    for both_instance.T print("% %\n", it_index, it);
}
