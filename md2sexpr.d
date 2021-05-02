import parser;
import std.string;
private string escape(string text) {
    return `"` ~ text.replace(`\`, `\\`).replace(`"`, `\\"`) ~ `"`;
}
struct ConvertToSExprEventHandler {
    string start(string text) {
        return " (" ~ escape(text);
    }
    string end() {
        return ")";
    }
}
struct ConvertToSExprListEventHandler {
    bool multiple = false;
    string start(string text) {
        if (multiple) {
            return " ((" ~ escape(text);
        } else {
            multiple = true;
            return "(" ~ escape(text);
        }
    }
    string end() {
        if (multiple) {
            multiple = false;
            return "))";
        } else return ") ";
    }
}
void main(string[] args) {
    import std.stdio, std.file;
    string[] inputnames;
    string[] inputs;
    args = args[1..$]; // skip first arg, which is name of binary
    bool list = false;
    if (args.length > 0 && args[0] == "-l") {
        args = args[1..$];
        list = true;
    }
    if (args.length == 0) {
        // stdin
        string input;
        string line;
        while ((line = readln()) !is null)
            input ~= line;
        inputnames ~= "stdin";
        inputs ~= input;
    }
    void readRestArgs() {
        foreach (filename; args) {
            inputnames ~= filename;
            inputs ~= filename.readText;
        }
    }
    if (list) {
        readRestArgs();
        for (int i = 0; i < inputs.length; ++i) {
            string output;
            parse!(ConvertToSExprListEventHandler, s => output ~= s, s => output ~=s)(inputs[i], 4, inputnames[i]);
            // Write each on a separate lines
            writeln(output);
        }
    } else {
        readRestArgs();
        for (int i = 0; i < inputs.length; ++i) {
            string output;
            parse!(ConvertToSExprEventHandler, s => output ~= s, s => output ~=s)(inputs[i], 4, inputnames[i]);
            // Write each on separate lines
            writeln(output);
        }
    }
}
