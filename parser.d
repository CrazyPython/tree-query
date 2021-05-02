/** Detect indent level and return where the indent level stops in "i"
  * A tab is counted as one indent.
  * Params:
  *      i                 = the index to start looking from. This is mutated
  *                          by reference to indicate the index the last index
  *                          was.
  *      spaces_per_indent = the number of spaces to treat as one indent
  */
int detect_indent_level(ref int i, string input, int spaces_per_indent=4) {
    int nspaces = 0;
    if (i == input.length || !(input[i] == ' ' || input[i] == '\t')) {
        return 0;
    }
    for (; i < input.length; ++i) {
        switch (input[i]) {
            case  ' ': nspaces++; break;
            case '\t': nspaces += spaces_per_indent; break;
            // Commented out makes it only accept "-"
            //case  '-': return nspaces / spaces_per_indent;
            case '\n': nspaces = 0; break;
            //default  : return 0;
            default : return nspaces / spaces_per_indent;
        }
    }
    return nspaces / spaces_per_indent;
}
unittest {
    int i;
    assert(detect_indent_level(i = 0, "    - hi") == 1);
    assert(detect_indent_level(i = 0, "Foo") == 0);
    assert(detect_indent_level(i = 0, "        - hi") == 2);
    assert(detect_indent_level(i = 0, "\t - hey") == 1);
}
void doNothing(T)(T _=null) {}
/** A streaming parser for Markdown trees. Emits a stream of parsing events. 
  * Params:
  *      ParseEventHandler = struct that handles a stream of parsing events.
  *                          See [ExampleParseEventHandler] for an example.
  *      deleStart         = function that is called with the return value of
  *                          the ParseEventHandler's start(). Defaults to 
  *                          doNothing
  *      deleEnd           = function that is called with the return value of
  *                          the ParseEventHandler's end(). Defaults to 
  *                          doNothing
  * These are all compile-time (template) parameters, thus the compiler will
  * inline functions into generated code.
  */
void parse(ParseEventHandler,
        alias deleStart=doNothing,
        alias deleEnd=doNothing,
        bool relaxed=false,
        Args...)
    (string input, int spaces_per_indent, string title, Args args) {
    import std.traits;
    ParseEventHandler parser = ParseEventHandler(args);
    //const initial_indent_level = 
    int current_indent_level;
    //BitType current_bits;
    //BitType[] stack;
    int line_content_start_index;
    // Workwround for void not being a parameter type
    void emitBlockStart(string nodeContent) {
        static if (is(ReturnType!(parser.start) == void)) {
            parser.start(nodeContent);
            deleStart();
        } else deleStart(parser.start(nodeContent));
    }
    void emitBlockEnd() {
        static if (is(ReturnType!(parser.end) == void)) {
            parser.end();
            deleEnd();
        } else deleEnd(parser.end());
    }
    emitBlockStart(title);
    for (int i = 0; i < input.length; ++i) {
        // emit end when on same or lower indent level, number based on difference
        // start on new lines
        switch (input[i]) {
            case '\n':
                //stack[0] & current_bits;
                // FIXME: Start and end based on "-"
                const nodeContent = input[line_content_start_index..i];
                emitBlockStart(nodeContent);
                i++;
                int new_indent_level =
                    detect_indent_level(i, input, spaces_per_indent);
                line_content_start_index = i;
                const extraEndings = i == input.length ? 0 : 1;
                foreach (_;
                  0..current_indent_level - new_indent_level + extraEndings) {
                    emitBlockEnd();
                }
                if (relaxed && new_indent_level > current_indent_level + 1) {
                    foreach (_; 0..new_indent_level - current_indent_level - 1)
                    {
                        emitBlockStart("");
                    }
                }
                current_indent_level = new_indent_level;
                break;
            case '[':
               break;
            // Skip across multiline constructs to prevent
            // detect_indent
            case '`':
                if (input[i+1] == '`' && input[i+2] == '`') {
                    // Skip 3 at a time for efficiency
                    // TODO: SIMD this and/or PGO it
                    for (i += 3; i < input.length; ++i) {
                        if (input[i-2] == '`' && 
                                input[i-1] == '`' && 
                                input[i-0] == '`') {
                            break;
                        }
                    }
                }
                break;
            default: break;
        }
    }
    if (line_content_start_index != input.length) {
        emitBlockStart(input[line_content_start_index .. input.length]);
    }
    for (int i = 0; i < current_indent_level + 1; ++i) {
        emitBlockEnd();
    }
    // End again because we started for the title
    emitBlockEnd();
}
/// Test the stream of parser events
unittest {
    import std.range, std.array;
    struct ExampleParseEventHandler {
        string start(string text) {
            return "START" ~ text;
        }
        string end() {
            return "END";
        }
    }
    string sample = "- ab\n\t- b\nhello\n\tworld\n\tfoo";
    // A trailing newline should not affect ther esult
    foreach (useTrailingNewline; [false, true]) {
        string result;
        parse!(ExampleParseEventHandler, s => result ~= s, s => result ~= s)
            (sample ~ (useTrailingNewline ? "\n" : ""), 4, "Title");
        assert(result == 
          `STARTTitleSTART- abSTART- bENDENDSTARThelloSTARTworldENDSTARTfooENDENDEND`
        );
    }
}
unittest {
    import std.stdio;
    struct ExampleParseEventHandler {
        string start(string text) {
            return "<div>" ~ text;
        }
        string end() {
            return "</div>";
        }
    }
    string sample =
`a
  b
c
   d`;
    string result;
    parse!(ExampleParseEventHandler, s => result ~= s, s => result ~= s, true)
             (sample, 1, "Title");
    result.writeln;
}
struct ConvertToXMLEventHandler {
    string start(string text) {
        return "<block>" ~ text;
    }
    string end() {
        return "</block>";
    }
}
/*struct ConvertToOPMLEventHandler {
    string start(string text) {
        // todo: escpae
        return `<outline text=` ~ text;
    }
    string end() {
        return `</outline>`;
    }
}*/
