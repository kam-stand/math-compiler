module parser;
import token;
import expr;
import std.stdio;
import lexer;

enum Precedence
{
    Comparison, // <  >
    Additive, // + -
    Multiplicative, // * /
    Exponent, // ^
    Prefix, // -
    Postfix, // !
}

immutable Precedence[TokenType] precedences = [
    TokenType.Plus: Precedence.Additive,
    TokenType.Minus: Precedence.Additive,
    TokenType.Asterisk: Precedence.Multiplicative,
    TokenType.Slash: Precedence.Multiplicative,
    TokenType.Carrot: Precedence.Exponent,
    TokenType.Less: Precedence.Comparison,
    TokenType.Greater: Precedence.Comparison,
    TokenType.Bang: Precedence.Postfix,
];

class Parser
{
    Token*[] tokens;
    size_t pos = 0; // current position

    this(Token*[] tokens)
    {
        this.tokens = tokens;
    }

    Token* peek()
    {
        return tokens[pos];
    }

    void advance()
    {
        pos++;
    }

    bool notAtEnd()
    {
        return pos < tokens.length;
    }

    void iterate()
    {
        while (notAtEnd())
        {
            writefln("index: %d, type: %s, literal: %s",
                pos, peek().type, cast(string) peek().slice);
            advance();
        }
    }

    int precedenceOf(Token* tok)
    {
        if (tok.type in precedences)
            return precedences[tok.type];
        return 0;
    }

    // -------------------------------------------
    // 🔹 Core parse loop (Pratt parser)
    // -------------------------------------------
    Expression* parse(int minPrecedence = 0)
    {
        auto tok = peek();
        advance();
        auto left = parseNud(tok);

        while (notAtEnd())
        {
            auto next = peek();
            int prec = precedenceOf(next);

            // stop if next operator binds weaker or equal
            if (next.type == TokenType.Eof || prec <= minPrecedence)
                break;

            advance();
            left = parseLed(left, next);
        }

        return left;
    }

    // -------------------------------------------
    // 🔹 parseNud: things that start expressions
    // -------------------------------------------
    Expression* parseNud(Token* tok)
    {
        switch (tok.type)
        {
        case TokenType.Int:
            return parseLiteral(tok);

        case TokenType.LeftParen:
            auto expr = parse(0);
            advance(); // consume ')'
            return expr;

        case TokenType.Minus: // prefix operator
            return parsePrefix(tok);

        default:
            writeln("Unexpected token in nud: ", tok.type);
            return null;
        }
    }

    // -------------------------------------------
    // 🔹 parseLed: handles infix and postfix ops
    // -------------------------------------------
    Expression* parseLed(Expression* lhs, Token* op)
    {
        switch (op.type)
        {
        case TokenType.Bang: // postfix
            return parsePostFix(lhs, op);
        case TokenType.Plus:
        case TokenType.Minus:
        case TokenType.Slash:
        case TokenType.Asterisk:
        case TokenType.Carrot:
            return parseInfix(lhs, op);
        default:
            writeln("Unexpected token in led: ", op.type);
            return lhs;
        }
    }

    // -------------------------------------------
    // Helpers (you could add pretty printers here)
    // -------------------------------------------
    Expression* parseLiteral(Token* tok)
    {
        return makeLiteral(tok);
    }

    Expression* parsePrefix(Token* op)
    {
        auto rhs = parse(Precedence.Prefix);
        return makePrefix(op, rhs);
    }

    Expression* parseInfix(Expression* lhs, Token* op)
    {
        auto rhs = parse(precedenceOf(op));
        return makeInfix(lhs, op, rhs);
    }

    Expression* parsePostFix(Expression* lhs, Token* op)
    {
        return makePostFix(op, lhs);
    }

}

void displayParenRPN(Expression* ast)
{
    import std.stdio;

    final switch (ast.type)
    {
    case ExpressionType.Literal:
        write(cast(string) ast.lit.num.slice);
        break;

    case ExpressionType.Prefix:
        write("(");
        write(cast(string) ast.prefix.op.slice, " ");
        displayParenRPN(ast.prefix.rhs);
        write(")");
        break;

    case ExpressionType.Infix:
        write("(");
        write(cast(string) ast.infix.op.slice, " ");
        displayParenRPN(ast.infix.lhs);
        write(" ");
        displayParenRPN(ast.infix.rhs);
        write(")");
        break;

    case ExpressionType.Postfix:
        write("(");
        displayParenRPN(ast.postfix.lhs);
        write(" ", cast(string) ast.postfix.op.slice);
        write(")");
        break;
    }
}

// -------------------------------------------
// 🔹 Example usage / test
// -------------------------------------------
unittest
{
    string line = "-12! + 3^2 * 6 / (4 + 4)";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    auto expr = p.parse(0);
    displayParenRPN(expr);
    writeln();
    writeln("Parsed successfully!");
}

unittest
{
    string line = "-12!";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    auto expr = p.parse(0);
    displayParenRPN(expr);
    writeln();
    assert(expr.type is ExpressionType.Prefix);
    assert(expr.prefix.op.type is TokenType.Minus);
    assert(expr.prefix.rhs.type is ExpressionType.Postfix);
    writeln("Parsed successfully!");
}
