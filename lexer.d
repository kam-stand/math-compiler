module lexer;
import token;
import std.ascii;
import std.stdio;

class Lexer
{
public:
    Token*[] tokens;
    this(byte[] input)
    {
        this.input = input;
        this.index = 0;
        this.tokenize();
    }

private:
    byte[] input;
    size_t index;
    void tokenize()
    {
        while (index < input.length)
        {
            auto c = input[index];

            switch (c)
            {
            case '+':
                tokens ~= new Token(TokenType.Plus, input[index .. index + 1]);
                index++;
                break;

            case '-':
                tokens ~= new Token(TokenType.Minus, input[index .. index + 1]);
                index++;
                break;

            case '*':
                tokens ~= new Token(TokenType.Asterisk, input[index .. index + 1]);
                index++;
                break;

            case '/':
                tokens ~= new Token(TokenType.Slash, input[index .. index + 1]);
                index++;
                break;

            case '^':
                tokens ~= new Token(TokenType.Carrot, input[index .. index + 1]);
                index++;
                break;

            case '<':
                tokens ~= new Token(TokenType.Less, input[index .. index + 1]);
                index++;
                break;

            case '>':
                tokens ~= new Token(TokenType.Greater, input[index .. index + 1]);
                index++;
                break;
            case '(':
                tokens ~= new Token(TokenType.LeftParen, input[index .. index + 1]);
                index++;
                break;
            case ')':
                tokens ~= new Token(TokenType.RightParen, input[index .. index + 1]);
                index++;
                break;
            case '!':
                tokens ~= new Token(TokenType.Bang, input[index .. index + 1]);
                index++;
                break;
            case ' ':
            case '\t':
            case '\r':
                index++;
                break;

            default:
                if (isDigit(c))
                {
                    size_t start = index;

                    while (index < input.length && isDigit(input[index]))
                        index++;

                    auto numText = input[start .. index];
                    tokens ~= new Token(TokenType.Int, numText);
                }
                else
                {
                    tokens ~= new Token(TokenType.Illegal, input[index .. index + 1]);
                    index++;
                }
                break;
            }
        }

        tokens ~= new Token(TokenType.Eof, null);
    }

}

unittest
{
    byte[] input = ['*', '+', '/'];

    Lexer l = new Lexer(input);

    auto t = l.tokens;

    assert(t.length != 0);
    assert(t[3].type == TokenType.Eof);

}

unittest
{
    byte[] input = ['1', '+', '2', '3'];

    Lexer l = new Lexer(input);

    auto t = l.tokens;
    assert(t.length == 4);
    assert(t[0].type == TokenType.Int);
    assert(t[3].type == TokenType.Eof);
    assert(cast(string) t[2].slice == "23");

}

unittest
{
    byte[] input = ['1', '#', '2', '3'];

    Lexer l = new Lexer(input);

    auto t = l.tokens;
    assert(t.length == 4);
    assert(t[0].type == TokenType.Int);
    assert(t[1].type == TokenType.Illegal);

}
