module parser;
import token;
import expr;
import std.stdio;
import lexer;

enum Precedence
{
    Lowest = 0,
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

public:
    Expression* ast;
    this(Token*[] tokens)
    {
        this.tokens = tokens;
        this.ast = parse(Precedence.Lowest);
    }

private:

    Token*[] tokens; // tokens from lexer
    size_t pos = 0; // current position

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
        auto lhs = parseNud(tok);

        while (notAtEnd())
        {
            auto op = peek();
            int prec = precedenceOf(op);

            // stop if next operator binds weaker or equal
            if (op.type == TokenType.Eof || prec <= minPrecedence)
                break;

            advance();
            lhs = parseLed(lhs, op);
        }

        return lhs;
    }

    Expression* parseNud(Token* tok)
    {
        switch (tok.type)
        {
        case TokenType.Int:
            return parseLiteral(tok);

        case TokenType.LeftParen:
            auto expr = parse(Precedence.Lowest);
            advance(); // consume ')'
            return expr;

        case TokenType.Minus: // prefix operator
            return parsePrefix(tok);

        default:
            writeln("Unexpected token in nud: ", tok.type);
            return null;
        }
    }

    Expression* parseLed(Expression* lhs, Token* op)
    {
        switch (op.type)
        {
        case TokenType.Bang: // postfix
            return parsePostfix(lhs, op);
        case TokenType.Plus:
        case TokenType.Minus:
        case TokenType.Slash:
        case TokenType.Asterisk:
        case TokenType.Carrot:
        case TokenType.Less:
        case TokenType.Greater:
            return parseInfix(lhs, op);
        default:
            writeln("Unexpected token in led: ", op.type);
            return lhs;
        }
    }

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
        int precedence = precedenceOf(op);
        if (op.type is TokenType.Carrot)
            precedence -= 1;

        auto rhs = parse(precedence);
        return makeInfix(lhs, op, rhs);
    }

    Expression* parsePostfix(Expression* lhs, Token* op)
    {
        return makePostfix(op, lhs);
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
        write("", cast(string) ast.postfix.op.slice);
        write(")");
        break;
    }
}

unittest
{
    string line = "-12! + 3^2 * 6 / (4 + 4)";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    displayParenRPN(p.ast);
    writeln();
    writeln("Parsed successfully!");
}

unittest
{
    string line = "-12!";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    displayParenRPN(p.ast);
    writeln();
    assert(p.ast.type is ExpressionType.Prefix);
    assert(p.ast.prefix.op.type is TokenType.Minus);
    assert(p.ast.prefix.rhs.type is ExpressionType.Postfix);
    writeln("Parsed successfully!");
}

unittest
{
    string line = "2^2^3";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);

    displayParenRPN(p.ast);
    writeln();

    // The root should be an infix '^'
    assert(p.ast.type == ExpressionType.Infix);
    assert(p.ast.infix.op.type == TokenType.Carrot);
    // Its right-hand side should also be another '^' infix
    assert(p.ast.infix.rhs.type == ExpressionType.Infix);
    assert(p.ast.infix.rhs.infix.op.type == TokenType.Carrot);

    writeln("Parsed successfully!");
}

unittest
{
    string line = "2>3";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    displayParenRPN(p.ast);
    writeln();
    writeln("Parsed successfully!");
}
