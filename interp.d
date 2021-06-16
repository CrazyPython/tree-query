/+ A boolean expression interpreter.
 + Used to evaluate boolean bitfields for the query.
 +/
module interp;

import std.variant;
import std.typecons;
// TCO
alias BitType = uint;
enum Op { AND, OR, NOT, ATOM };
bool eval_form(BitType bitstring, Form form) {
    if (form.op == Op.AND) {
        return eval_and(bitstring, form.operands);
    } else if (form.op == Op.OR) {
        return eval_or(bitstring, form.operands);
    } else if (form.op == Op.NOT) {
        return cast(bool)(!(bitstring & (1 << form.operands[0].bitshift)));
        //return cast(bool)(!(bitstring & (1 << form.bitshift)));
    } else {
        return cast(bool)(bitstring & (1 << form.bitshift));
    }
}
struct Form {
    Op op;
    union {
        Form[] operands;
        // What is faster, a ubyte or a byte?
        ubyte bitshift;
    }
}
bool eval_and(BitType bitstring, Form[] terms) {
    if (terms.length == 0) {
        return true;
    }
    if (eval_form(bitstring, terms[0])) {
        return eval_and(bitstring, terms[1..$]);
    } else {
        // short-circuit evaluation
        return false;
    }
}
bool eval_or(BitType bitstring, Form[] terms) {
    if (terms.length == 0) {
        return false;
    }
    if (eval_form(bitstring, terms[0])) {
        // short-circuit evaluation
        return true;
    } else {
        return eval_or(bitstring, terms[1..$]);
    }
}
private Form Atom(ubyte bitshift) {
    Form form = { Op.ATOM, bitshift: bitshift };
    return form;
}
unittest {
    assert(eval_form(0b1, Form(Op.OR, [Atom(0)])) == true);
    assert(eval_form(0b11, Form(Op.AND, [Atom(0), Atom(1)])) == true);
    assert(eval_form(0b10, Form(Op.AND, [Atom(0), Atom(1)])) == false);
    assert(eval_form(0b10, Form(Op.OR , [Atom(0), Atom(1)])) == true);
    assert(eval_form(0b111,Form(Op.AND, [Form(Op.AND, [Atom(0), Atom(2)]), Atom(1)])) == true);
}
