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

    void advance()
    {
        index++;
    }

    char peek()
    {
        return index < input.length ? cast(char) input[index] : '\0';
    }

    char peekNext()
    {
        return index + 1 < input.length ? cast(char) input[index + 1] : '\0';
    }

    void tokenize()
    {
        while (index < input.length)
        {
            auto c = peek();

            switch (c)
            {
            case '+':
                tokens ~= new Token(TokenType.Plus, input[index .. index + 1]);
                advance();
                break;

            case '-':
                tokens ~= new Token(TokenType.Minus, input[index .. index + 1]);
                advance();
                break;

            case '*':
                tokens ~= new Token(TokenType.Asterisk, input[index .. index + 1]);
                advance();
                break;

            case '/':
                tokens ~= new Token(TokenType.Slash, input[index .. index + 1]);
                advance();
                break;

            case '^':
                tokens ~= new Token(TokenType.Carrot, input[index .. index + 1]);
                advance();
                break;
            case '=':
                if (peekNext() == '=')
                {
                    tokens ~= new Token(TokenType.EqualEqual, input[index .. index + 2]);
                    advance(); // consume '='
                    advance(); // consume '='
                }
                else
                {
                    tokens ~= new Token(TokenType.Equal, input[index .. index + 1]);
                    advance(); // consume '!'
                }
                break;

            case '<':
                if (peekNext() == '=')
                {
                    tokens ~= new Token(TokenType.LessEqual, input[index .. index + 2]);
                    advance(); // consume '<'
                    advance(); // consume '='
                }
                else
                {
                    tokens ~= new Token(TokenType.Less, input[index .. index + 1]);
                    advance(); // consume '<'
                }
                break;

            case '>':
                if (peekNext() == '=')
                {
                    tokens ~= new Token(TokenType.GreaterEqual, input[index .. index + 2]);
                    advance(); // consume '>'
                    advance(); // consume '='
                }
                else
                {
                    tokens ~= new Token(TokenType.Greater, input[index .. index + 1]);
                    advance(); // consume '>'
                }
                break;

            case '(':
                tokens ~= new Token(TokenType.LeftParen, input[index .. index + 1]);
                advance();
                break;
            case ')':

                tokens ~= new Token(TokenType.RightParen, input[index .. index + 1]);
                advance();
                break;

            case '?':
                tokens ~= new Token(TokenType.Question, input[index .. index + 1]);
                advance();
                break;

            case '!':
                if (peekNext() == '=')
                {
                    tokens ~= new Token(TokenType.BangEqual, input[index .. index + 2]);
                    advance(); // consume '!'
                    advance(); // consume '='
                }
                else
                {
                    tokens ~= new Token(TokenType.Bang, input[index .. index + 1]);
                    advance(); // consume '!'
                }
                break;
            case ' ':
            case '\t':
            case '\r':
                advance();
                break;

            default:
                if (isDigit(c))
                {
                    size_t start = index;

                    while (index < input.length && isDigit(peek()))
                        advance();

                    auto numText = input[start .. index];
                    tokens ~= new Token(TokenType.Int, numText);
                }
                else
                {
                    tokens ~= new Token(TokenType.Illegal, input[index .. index + 1]);
                    advance();
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

unittest
{
    byte[] input = ['1', '>', '=', '3'];

    Lexer l = new Lexer(input);

    auto t = l.tokens;
    assert(t.length == 4);
    assert(t[0].type == TokenType.Int);
    assert(t[1].type == TokenType.GreaterEqual);

}

unittest
{
    byte[] input = ['1', '!', '=', '3'];

    Lexer l = new Lexer(input);

    auto t = l.tokens;
    assert(t.length == 4);
    assert(t[0].type == TokenType.Int);
    assert(t[1].type == TokenType.BangEqual);

}

unittest
{
    byte[] input = ['1', '=', '=', '3'];

    Lexer l = new Lexer(input);

    auto t = l.tokens;
    assert(t.length == 4);
    assert(t[0].type == TokenType.Int);
    assert(t[1].type == TokenType.EqualEqual);

}

unittest
{
    byte[] input = ['1', '+', '3', '?'];

    Lexer l = new Lexer(input);

    auto t = l.tokens;
    assert(t.length == 5);
    assert(t[0].type == TokenType.Int);
    assert(t[3].type == TokenType.Question);

}
