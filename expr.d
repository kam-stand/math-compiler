module expr;
import token;

enum ExpressionType
{
    Literal,
    Prefix,
    Infix,
    Postfix
}

struct Literal
{
    Token* num;
}

struct Prefix
{
    Token* op;
    Expression* rhs;
}

struct Infix
{
    Expression* lhs;
    Token* op;
    Expression* rhs;
}

struct Postfix
{
    Expression* lhs;
    Token* op;
}

struct Expression
{
    ExpressionType type;
    union
    {
        Literal* lit;
        Prefix* prefix;
        Infix* infix;
        Postfix* postfix;
    }
}

Expression* makeLiteral(Token* num)
{
    auto literal = new Literal(num);
    auto expr = new Expression();
    expr.type = ExpressionType.Literal;
    expr.lit = literal;
    return expr;
}

Expression* makePrefix(Token* op, Expression* rhs)
{
    auto prefix = new Prefix(op, rhs);
    auto expr = new Expression();
    expr.type = ExpressionType.Prefix;
    expr.prefix = prefix;
    return expr;

}

Expression* makeInfix(Expression* lhs, Token* op, Expression* rhs)
{
    auto infix = new Infix(lhs, op, rhs);
    auto expr = new Expression();
    expr.type = ExpressionType.Infix;
    expr.infix = infix;
    return expr;

}

Expression* makePostFix(Token* op, Expression* lhs)
{
    auto postfix = new Postfix(lhs, op);
    auto expr = new Expression();
    expr.type = ExpressionType.Postfix;
    expr.postfix = postfix;
    return expr;

}

unittest
{
    byte[] input = ['1'];
    auto lit = makeLiteral(new Token(TokenType.Int, input));
    assert(lit.type is ExpressionType.Literal);
}

unittest
{
    byte[] input = ['-', '2'];
    auto pre = makePrefix(new Token(TokenType.Minus, input[0 .. 1]), makeLiteral(
            new Token(TokenType.Int, input[1 .. $])));
    assert(pre.type is ExpressionType.Prefix);
    assert(pre.prefix.op.type is TokenType.Minus);
}

unittest
{
    byte[] input = ['1', '+', '2'];
    auto lhs = makeLiteral(new Token(TokenType.Int, input[0 .. 1]));
    auto op = (new Token(TokenType.Plus, input[1 .. 2]));
    auto rhs = makeLiteral(new Token(TokenType.Int, input[2 .. $]));
    auto infix = makeInfix(lhs, op, rhs);
    assert(infix.type is ExpressionType.Infix);
    assert(infix.infix.rhs.type is ExpressionType.Literal);
}
