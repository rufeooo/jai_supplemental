#import "Basic";
#import "Random";
#import "Machine_X64";

ENABLE_COUNT :: false;
ENABLE_MUTATE :: false;

MAX_LOOP :: 128;
MAX_BUFFER :: 1 << 28;
CYCLES_PER_SEC :: 2000000000.0;
GB := cast(float)1<<30;

step_type :: s64;
array : [MAX_BUFFER/size_of(step_type)]step_type;

array_fill :: ()
{
    _, value := rdrand();
    for 0..array.count-1 {
        array[it] = xx value;
        value *= 7 + 1;
    }
}

main :: () #no_abc
{
    array_fill();

    start := rdtsc();

    sum : step_type = 0;
    count : u64 = 0;
    for 0..MAX_LOOP-1 {
        for 0..array.count-1 {
            sum += array[it];
            #if ENABLE_MUTATE {
                array[it] = ~array[it];
            }
            #if ENABLE_COUNT {
                count += 1;
            }
        }
    }
    end := rdtsc();
    elapsed := (end-start)/CYCLES_PER_SEC;
    print("sum % in %s\n", cast (*void) sum, elapsed);
    print("% GB at % GB/s\n", MAX_LOOP*MAX_BUFFER/GB, MAX_LOOP*MAX_BUFFER/GB/elapsed);
    #if ENABLE_COUNT print("% count\n", count);
}
