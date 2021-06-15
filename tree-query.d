module tree_query;
import std.stdio;
import std.variant;
import std.string;
import query;
import interp;
/++
 + Extract the query from the input.
 + These forms are supported, where QUERY represents the query itself.
 +  - QUERY
 +  - {{query: QUERY }}
 +  - {{query:QUERY}}
 +  - {{[[query]]: QUERY }}
 +
 + Leading and trailing whitespace are allowed before the start and end of the query.
 +
 + Note that Roam does not accept {{ query: nor {{ query :
 + 
 +/
string extractQuery(string query) {
    import std.string;
    query = strip(query); // Allow leading and trailing whitespace
    if (query.startsWith("{{")) {
        if (query.endsWith("}}")) {
            // "1"th index is 2
            auto withoutWhitespace = stripLeft(query[2..$]);
            enum command = "query:";
            if (withoutWhitespace.startsWith(command)) {
                auto result = query[2+command.length..$-2].strip;
                return result;
            } else {
                throw new Error("Unrecognized command, command must be 'query:'");
            }
        } else {
            throw new Exception("Malformed query. Must end with '}}'");
        }
    } else {
        return query;
    }
}
unittest {
    const nakedQueries = ["{and: [[foo]] [[bar]] }", "{or: [[foo]] [[bar]] }"];
    foreach (nakedQuery; nakedQueries) {
        assert(extractQuery(nakedQuery) == nakedQuery);
        assert(extractQuery("{{query:" ~ nakedQuery ~ "}}") == nakedQuery);
        assert(extractQuery(" {{query: " ~ nakedQuery ~ " }} ") == nakedQuery);
    }
}
struct ParsedQuery {
    string[] terms;
    Form form;
}

ParsedQuery parseQuery(string query) {
    ParsedQuery q;
    return q;
}

// TODO: Implement atom dedup
// TODO: Implement support for arbitrary atoms
// TODO: Allocate Form from an array for efficiency
ParsedQuery booleanQuery(string query, ref ubyte bitshift) {
    import std.array;
    ParsedQuery q;
    debug writeln("subquery", query);
    query = query.strip();
    auto start = query.split(" ")[0];
    if (start == "{and:") {
        q.form.op = Op.AND;
    } else if (start == "{or:") {
        q.form.op = Op.OR;
    } else if (start == "{not:") {
        q.form.op = Op.NOT;
    } else {
        throw new Exception("Unrecognized keyword" ~ start);
    }
    // (\[\[.+\]\])|(".+")
    // recursive call
    // using the rest of the words, build a form
    int[] indexes;
    int ntoskip = 0;
    foreach (i, token; query[start.length..$].split("]]")) {
        debug writeln("Parse token", token);
        if (ntoskip > 0) {
            ntoskip--;
            continue;
        }
        if (token.startsWith("[[") || token.startsWith(" [[")) {
            auto text = token.strip() ~ "]]";
            q.terms ~= text;
            Form inner = { Op.ATOM, bitshift: bitshift++ };
            debug bitshift.writeln;
            q.form.operands ~= inner;
        } else if (token.strip().startsWith("}")) {
            return q;
        } else {
            auto subquery = booleanQuery(
                query[start.length..$].split("]]")[i..$].join("]]"),
                bitshift
            );
            q.terms ~= subquery.terms;
            q.form.operands ~= subquery.form;
            ntoskip = cast(int)subquery.terms.length + 1;
        }
    }
    return q;
}
unittest {
    ubyte bitshift = 0;
    auto pq = booleanQuery("{and: [[Hi]] {or: [[Blue]] [[White]] } }", bitshift);
    assert(pq.terms == ["[[Hi]]", "[[Blue]]", "[[White]]"]);
    assert(pq.form.operands[1].op == Op.OR);
    assert(pq.form.operands[1].operands[0].bitshift == 1);
    assert(pq.form.operands[1].operands[1].bitshift == 2);
}

string escape(string text) {
    return text.replace(`\`, `\\`)
        .replace(`"`, `\"`)
        .replace(`\\n`, `\n`)
        .replace(`\\t`, `\t`);
}
unittest {
    import std.stdio;
    ubyte n  = 0;
    auto parsed = booleanQuery("{and: [[Hi]] [[Hello]] }", n);
    assert(parsed.terms == ["[[Hi]]", "[[Hello]]"]);
}
private struct WithConstructor {
        string[] member;
        this(string[] arg, Form a) {
            member = arg;
        }
        void start(string text) {
        }
        void end() {
        }
    }
unittest {
    import parser;
    Form form;
    parse!(WithConstructor)
            ("Test", 4, "Title", ["arg"], form);
}

int main(string[] args) {
    import std.getopt, std.file, std.stdio;
    // Parse arguments
    string query;
    if (args[1].strip.startsWith("{")) {
        query = args[1];
        args = args[2..$];
    } else {
        throw new Exception("Query must be first parameter");
    }
    // Read query immediately. If the user has written an invalid query, show
    // an error before we read in all files.
    ubyte n = 0;
    ParsedQuery qu = booleanQuery(query, n);
    string[] inputs;
    string[] inputnames;
    if (args.length == 0) {
        // stdin
        string input;
        string line;
        while ((line = readln()) !is null)
            input ~= line;
        inputnames ~= "stdin";
        inputs ~= input;
    }
    foreach (filename; args) {
        if (filename.isDir) {
            import std.algorithm.iteration;
            filename.dirEntries(SpanMode.depth).filter!isFile.each!((string filename) {
                // TODO: Proper mechanism to detect and avoid binary files
                import std.utf;
                try {
                    inputnames ~= filename;
                    // TODO: Stream input from files for cache locality, instead of reading everything in at once
                    inputs ~= filename.readText;
                } catch (UTFException) {
                    inputnames.length--;
                }
            });
        } else {
            assert(filename.exists);
            inputnames ~= filename;
            inputs ~= filename.readText;
        }
    }
    for (int i = 0; i < inputs.length; ++i) {
        import parser;
        import std.meta;
        parse!(QueryHandler, doNothing, doNothing, true)(inputs[i], 4, inputnames[i], qu.terms, qu.form);
        // Write each on a separate lines
    }
    return 0;
}
