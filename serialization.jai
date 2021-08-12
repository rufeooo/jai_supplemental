// Jai version 077
// Linux
#import "Basic";
#import "POSIX";

ioS :: struct
{
    blob : u8;
    val : s64;
    ptr : *~s8 u8;
    str : string~s8;
};

main :: ()
{
    file_func :: #type (data: *void, size: size_t, count: size_t, file: *void) -> size_t #c_call;
    file_io :: (func : file_func, data : *$T)
    {
        mode := ifx func == fwrite "wb" else "rb";
        fd := fopen("test.dat", mode.data);
        defer fclose(fd);

        record_count := func(data, size_of(T), 1, fd);
    }
    
    output : ioS;
    output.blob = 65; // "A"
    output.val = 2;
    output.ptr = *output.blob;
    output.str.data = *output.blob;
    output.str.count = 1;

    print("% output.ptr\n", <<output.ptr);
    print("% output.str\n", output.str);

    file_io(fwrite, *output);

    input : ioS;
    file_io(fread, *input);

    print("% input.ptr\n", <<input.ptr);
    print("% input.str\n", input.str);
}
