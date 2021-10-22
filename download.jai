#import "Basic";
#import "Curl";
#import "File";
#import "Math";
#import "String";

usage :: ()
{
    args := get_command_line_arguments();
    print("Usage: % <url>", ifx args.count > 0 args[0]);
    exit(1);
}

filename_init :: (basename : string, ext : string) -> string
{
    sb : String_Builder;
    defer(free_buffers(*sb));

    print_to_builder(*sb, "%1.%2", basename, ext);

    return builder_to_string(*sb);
}

string_to_u8 :: (str : string, arr : []u8) -> s64
{
    len := min(arr.count, str.count);
    len = max(len, 0);
    memcpy(arr.data, str.data, len);

    len -= (ifx len >= arr.count 1);
    arr[len] = 0;
    return len;
}

main :: ()
{
    args := get_command_line_arguments();
    if args.count != 2 usage();
    url := args[1];
    url_length := url.count + 1;

    url_view : []u8 = ---;
    url_view.data = alloc(url_length);
    url_view.count = url_length;
    string_to_u8(url, url_view);

    url_parts := split(url, "/");
    if url_parts.count == 0 usage();
    last_part := url_parts[url_parts.count-1];

    name_parts := split(last_part, ".");
    if name_parts.count == 0 usage();
    name := name_parts[0];

    curl := curl_easy_init();
    if !curl {
        print("Could not initialize curl.");
        return;
    }

    write_data :: (ptr : *void, size : u64, nmemb : u64, stream : *File) -> u64 #c_call
    {
        jai_context : Context;
        push_context jai_context {
            length := cast (s64) clamp(size*nmemb, 0, xx S64_MAX);
            ok := file_write(stream, ptr, length);
            if ok return xx length;
        }
        return 0;
    }

    curl_easy_setopt(curl, .URL, url_view.data);
    curl_easy_setopt(curl, .FOLLOWLOCATION, 1);
    curl_easy_setopt(curl, .WRITEFUNCTION, write_data);
    filename := filename_init(name, "zip");
    defer(free(filename));
    stream := file_open(filename, for_writing=true);
    curl_easy_setopt(curl, .WRITEDATA, *stream);

    /* Perform the request, res will get the return code */
    res := curl_easy_perform(curl);
    file_close(*stream);

    /* Check for errors */
    print("curl_easy_perform(): %\n", res);

    /* always cleanup */
    curl_easy_cleanup(curl);
}
