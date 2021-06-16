/++ Query system that implements Roam queries. +/
module query;
import interp;
debug import std.stdio;

// Unoptimized function to calculate matches for a set of
// words
// This should be replaced by something faster.
// For instance, a regex library, that scans once, instead of once
struct DumbMatcher(BitType) {
    string[] search_terms;
    this(string[] terms) {
        search_terms = terms;
    }
    BitType match(string str) {
        import std.algorithm.searching : canFind;
        BitType result;
        debug writeln("Query " ~ str);
        for (int i = 0; i < search_terms.length; ++i) {
            auto term = search_terms[i];
            if (canFind(str, term)) {
                debug writeln("Matched with " ~ term);
                result |= 1 << i;
            }
        }
        return result;
    }
    unittest {
        DumbMatcher!BitType matcher = DumbMatcher(["red", "green"]);
        assert(matcher.match("blue")       == 0b00);
        assert(matcher.match("red")        == 0b01);
        assert(matcher.match("green")      == 0b10);
        assert(matcher.match("red green")  == 0b11);
        assert(matcher.match("blue green") == 0b10);
        Form form = { Op.ATOM, bitshift: 0};
        assert(eval_form(matcher.match("red"), Form(Op.AND, [form])));
    }
    unittest {
        DumbMatcher!BitType matcher = DumbMatcher(["[[PRIME Theory]]", "[[PRIME: Motives]]"]);
        assert(matcher.match("- In every moment we [act]([[PRIME: Responses]]) in pursuit of what we most [want or need]([[PRIME: Motives]]) at that moment. Something can only exert [[behavioral influence]] if it is [[salient]] at the moment") == 0b10);
    }
}
struct RegexMatcher;
struct TrieMatcher;

alias BitType = uint;

/++Roam query.
 + It handles a stream of START and END events.
 + START means a indented block or line started
 + END means a indented block or line ended
 +
 + It computes a bitfield for each line.
 + Each bit in the bitfield corresponds to a word in the query, and represents
 + whether that bit was present in this line or one of its parents.
 +/
struct QueryHandler {
    bool matching = false;
    string[] parent_lines; // Bookkeeping data structure. Holds parent lines as strings, so we can later print them out.
    //string[] to_print;
    BitType[] bit_stack = [0];
    DumbMatcher!BitType matcher;
    Form expression;
    this(string[] terms, Form form) { // Construct a QueryHandler struct
        debug writeln("Terms", terms);
        assert(terms.length < BitType.sizeof * 8);
        matcher = DumbMatcher!BitType(terms);
        expression = form;
    }
    void start(string line) {
        BitType own_bits = matcher.match(line);
        bit_stack ~= bit_stack[$-1] | own_bits;
        debug writeln("Own bitstring", own_bits);
        parent_lines ~= line;
        if (eval_form(bit_stack[$-1], expression)) {
            import std.stdio;
            foreach (parent_line; parent_lines)
                writeln(parent_line);
            // Simple way to avoid printing it twice
            parent_lines.length = 0;
        }
    }
    void end() {
        debug writeln("stacklen", bit_stack.length);
        bit_stack.length--;
        if (parent_lines.length > 0)
            parent_lines = parent_lines[0..$-1]; // Pop the last item
    }
}
unittest {
    //QueryHandler!uint handler = QueryHandler!uint(["red", "green"], "");
}
