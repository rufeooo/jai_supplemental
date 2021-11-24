#import "Basic";
#import "Random";
#import "Machine_X64";

ENABLE_COUNT :: false;
ENABLE_MUTATE :: false;

MAX_LOOP :: 128;
MAX_BUFFER :: 1 << 28;
CYCLES_PER_SEC :: 2000000000.0;
GB := cast(float)1<<30;

array : [MAX_BUFFER]u8;

array_fill :: ()
{
    iter : *void = array.data;
    end := iter + array.count;
    step := size_of(u64);
    _, value := rdrand();
    while iter + step <= end {
        ptr : *u64 = iter;
        <<ptr = value;
        iter += step;
        value *= 7 + 1;
    }
}

main :: () #no_abc
{
    array_fill();

    start := rdtsc();

    sum := 0;
    count : u64 = 0;
    for 0..MAX_LOOP-1 {
        iter : *void = array.data;
        end := iter + array.count;
        step := size_of(type_of(sum));
        while iter + step <= end {
            ptr : *type_of(sum) = iter;
            sum += <<ptr;
            #if ENABLE_MUTATE {
                <<ptr = ~(<<ptr);
            }
            iter += step;
            #if ENABLE_COUNT {
                count += 1;
            }
        }
    }
    end := rdtsc();
    elapsed := (end-start)/CYCLES_PER_SEC;
    print("sum % in %s\n", cast (*void) sum, elapsed);
    print("% GB at % GB/s\n", MAX_LOOP*array.count/GB, MAX_LOOP*array.count/GB/elapsed);
    #if ENABLE_COUNT print("% count\n", count);
}
