import std.stdio;
import lexer;
import parser;

enum PROMPT = ">> ";

int main(string[] args)
{

    bool printAst = false;

    while (true)
    {
        write(PROMPT);
        string line = readln();
        if (line is null)
        {
            return 1;
        }
        if (line == "exit\n")
        {
            return 0;
        }
        if (line == "ast\n")
        {
            printAst = !printAst;
            writefln("AST printing %s", printAst);
            continue;
        }
        byte[] input = cast(byte[]) line;
        Lexer l = new Lexer(input);
        Parser p = new Parser(l.tokens);
        // TODO: fix print to add stmts
        // if (printAst)
        //     displayParenRPN(p.stmts[0].expr.expr);
        // writeln();

    }

    return 0;
}
