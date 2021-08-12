// Jai version 075
#import "Basic";

enum_iteratorS :: struct($T: Type)
{
    foo : T;
}

enum_iterator :: ($T: Type) -> enum_iteratorS(T)
{
    return enum_iteratorS(T).{};
}

for_expansion :: (iterator: *enum_iteratorS, body: Code, flags: For_Flags) #expand {
    info := type_info(iterator.T);
    assert(info.type == .ENUM);
    #assert(flags & .POINTER == 0);
    for value, index: info.values {
        `it := cast(iterator.T)value;
        `it_index := index;

        #insert body;
    }
}

fooE :: enum
{
    A;
    B;
};

barE :: enum
{
    ONE;
    TWO;
};

main :: ()
{
    for enum_iterator(fooE)
    {
        print("%\n", it);
    }
    for enum_iterator(barE)
    {
        print("%\n", it);
    }
}
