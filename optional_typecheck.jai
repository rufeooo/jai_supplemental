// v93
#import "Basic";

TYPECHECK :: 0;

isa :: ($T : Type) -> string 
{
    #if TYPECHECK
        return sprint("#type,isa %;", T);
    else
        return sprint("%;", T);
}
Handle :: #insert #run isa(u64);

// not the same as isa
// a single polymorph returns the same #type,isa for all u64
alt_isa :: ($T : Type) -> Type
{
    return #type,isa T;
}
Big :: #run alt_isa(u64);

// matches the behavior of isa!!!
// must be expanded to result in a unique type per callsite
expand_isa :: ($T : Type) -> Type #expand
{
    return #type,isa T;
}

// control type #type,isa checks at compile time!
conditional_isa :: ($T : Type) -> Type #expand
{
    if TYPECHECK {
        return #type,isa T;
    } else {
        return T;
    }
}

main :: ()
{
    x : Handle;
    u : u64;
    u = x;

    // blocked when #type,isa
    // x = u;

    Other :: #insert #run isa(u64);
    o : Other;
    // blocked when #type,isa
    //o = x;
    //x = o;

    print("raw #type,isa u64 %\n", type_info(#type,isa u64));
    print("raw #type,isa u64 (2) %\n", type_info(#type,isa u64));
    print("Other: %\n", type_info(Other));
    print("Handle: %\n", type_info(Handle));

    print("alt_isa u64: %\n", type_info(#run alt_isa(u64)));
    print("alt_isa u64: %\n", type_info(#run alt_isa(u64)));

    print("expand_isa u64: %\n", type_info(#run expand_isa(u64)));
    print("expand_isa u64: %\n", type_info(#run expand_isa(u64)));

    print("conditional_isa u64: %\n", type_info(#run conditional_isa(u64)));
    print("conditional_isa u64: %\n", type_info(#run conditional_isa(u64)));
    print("u64 type_info: %\n", type_info(u64));
}
