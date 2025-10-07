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
            break;
        }
        if (line == "exit\n")
        {
            break;
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
        auto ast = p.parse(Precedence.Lowest);
        if (printAst)
            displayParenRPN(ast);
        writeln();

    }

    return 0;
}
