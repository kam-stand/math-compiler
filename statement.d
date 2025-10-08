module statement;
import token;
import expr;

enum StatementType
{
    Var,
    Return,
    Expression

}

struct VarStatement
{

    Token* ident;
    Expression* expr;
}

struct ReturnStatement
{
    Expression* expr;
}

struct ExpressionStatement
{
    Expression* expr;
}

struct Statement
{
    StatementType type;
    union
    {
        VarStatement* var;
        ReturnStatement* ret;
        ExpressionStatement* expr;
    }
}

Statement* makeReturnStmt(Expression* expr)
{
    auto ret = new ReturnStatement(expr);
    auto stmt = new Statement();
    stmt.type = StatementType.Return;
    stmt.ret = ret;
    return stmt;
}

Statement* makeVarStmt(Token* ident, Expression* expr)
{
    auto var = new VarStatement(ident, expr);
    auto stmt = new Statement();
    stmt.type = StatementType.Var;
    stmt.var = var;
    return stmt;
}

Statement* makeExpressionStmt(Expression* expr)
{
    auto exprStmt = new ExpressionStatement(expr);
    auto stmt = new Statement();
    stmt.type = StatementType.Expression;
    stmt.expr = exprStmt;
    return stmt;
}
