module parser;
import token;
import expr;
import std.stdio;
import lexer;
import statement;

enum Precedence
{
    Lowest = 0,
    Comparison, // <  > >= <= != ==
    Additive, // + -
    Multiplicative, // * /
    Exponent, // ^
    Prefix, // -
    Postfix, // !
}

immutable Precedence[TokenType] precedences = [
    // additive
    TokenType.Plus: Precedence.Additive,
    TokenType.Minus: Precedence.Additive,
    // multiplicative
    TokenType.Asterisk: Precedence.Multiplicative,
    TokenType.Slash: Precedence.Multiplicative,
    // exponent
    TokenType.Carrot: Precedence.Exponent,
    // comparison
    TokenType.Less: Precedence.Comparison,
    TokenType.Greater: Precedence.Comparison,
    TokenType.LessEqual: Precedence.Comparison,
    TokenType.GreaterEqual: Precedence.Comparison,
    TokenType.BangEqual: Precedence.Comparison,
    TokenType.EqualEqual: Precedence.Comparison,
    // postfix
    TokenType.Bang: Precedence.Postfix,
];

class Parser
{

public:
    Expression* ast;
    Statement*[] stmts;
    this(Token*[] tokens)
    {
        this.tokens = tokens;
        this.stmts = this.parseProgram();
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

    Statement*[] parseProgram()
    {
        Statement*[] statements;
        while (notAtEnd() && peek().type != TokenType.Eof)
        {
            statements ~= parseStatement();
        }
        return statements;
    }

    Statement* parseStatement()
    {
        switch (peek().type)
        {
        case TokenType.Var:
            return parseVarStmt();
        case TokenType.Return:
            return parseReturnStmt();
        default:
            return parseExpressionStmt();
        }
    }

    Statement* parseVarStmt()
    {
        advance(); // consume 'var'
        auto ident = peek();
        advance(); // consume identifier

        // Expect '='
        if (peek().type != TokenType.Equal)
        {
            writeln("Syntax Error: expected '=' after variable name");
            return null;
        }

        advance(); // consume '='
        auto expr = parse(Precedence.Lowest);

        return makeVarStmt(ident, expr);
    }

    // TODO: CHECK for guards in null
    Statement* parseReturnStmt()
    {
        advance(); // consume 'return'
        auto expr = parse(Precedence.Lowest);
        return makeReturnStmt(expr);
    }

    Statement* parseExpressionStmt()
    {
        auto expr = parse(Precedence.Lowest);
        auto stmt = makeExpressionStmt(expr);
        advance(); // move to next statement
        return stmt;
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
            // literals
        case TokenType.Int:
        case TokenType.Double:
        case TokenType.Float:
        case TokenType.String:
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
        case TokenType.LessEqual:
        case TokenType.GreaterEqual:
        case TokenType.BangEqual:
        case TokenType.EqualEqual:
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
    displayParenRPN(p.stmts[0].expr.expr);
    writeln();
    writeln("Parsed successfully!");
}

unittest
{
    string line = "-12!";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    displayParenRPN((p.stmts[0].expr.expr));
    writeln();
    assert(p.stmts[0].expr.expr.type is ExpressionType.Prefix);
    assert(p.stmts[0].expr.expr.prefix.op.type is TokenType.Minus);
    assert(p.stmts[0].expr.expr.prefix.rhs.type is ExpressionType.Postfix);
    writeln("Parsed successfully!");
}

unittest
{
    string line = "2^2^3";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);

    displayParenRPN((p.stmts[0].expr.expr));
    writeln();

    assert(p.stmts[0].expr.expr.type == ExpressionType.Infix);
    assert(p.stmts[0].expr.expr.infix.op.type == TokenType.Carrot);
    assert(p.stmts[0].expr.expr.infix.rhs.type == ExpressionType.Infix);
    assert(p.stmts[0].expr.expr.infix.rhs.infix.op.type == TokenType.Carrot);

    writeln("Parsed successfully!");
}

unittest
{
    string line = "2>3";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    displayParenRPN((p.stmts[0].expr.expr));
    assert(p.stmts[0].expr.expr.infix.op.type is TokenType.Greater);
    writeln();
    writeln("Parsed successfully!");
}

unittest
{
    string line = "6 != 7";
    byte[] input = cast(byte[]) line;
    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    displayParenRPN(p.stmts[0].expr.expr);
    assert(p.stmts[0].expr.expr.infix.op.type is TokenType.BangEqual);
    writeln();
    writeln("Parsed successfully!");
}

unittest
{
    string line = "12 + 3";
    byte[] input = cast(byte[]) line;

    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    assert(p.stmts[0].type is StatementType.Expression);

}

unittest
{
    string line = "var x = 12";
    byte[] input = cast(byte[]) line;

    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    assert(p.stmts[0].type is StatementType.Var);

}

unittest
{
    string line = "return 12 > 12";
    byte[] input = cast(byte[]) line;

    Lexer l = new Lexer(input);
    Parser p = new Parser(l.tokens);
    assert(p.stmts[0].type is StatementType.Return);
    assert(p.stmts[0].expr.expr.infix.rhs.lit.num.type is TokenType.Int);

}
