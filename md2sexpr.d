import parser;
import std.string;
private string escape(string text) {
    return `"` ~ text.replace(`\`, `\\`).replace(`"`, `\"`) ~ `"`;
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
    int[] nchildren;
    string start(string text) {
        int current;
        if (nchildren.length) {
            nchildren[$-1]++;
            current = nchildren[$-1];
        } else {
            current = 0;
        }
        nchildren ~= 0;
        // If we are starting a list with more than one child, add 2 parens
        if (current == 1) {
            return " ((" ~ escape(text);
        } else {
            return " (" ~ escape(text);
        }
    }
    string end() {
        // If we are ending a list with more than one child, add 2 parens
        if (nchildren.length > 0 && nchildren[$-1] > 0) {
            nchildren.length--;
            return "))";
        } else {
            nchildren.length--;
            return ")";
        }
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
