module token;

enum TokenType
{
    Illegal,
    Eof,

    // Base types
    Int,
    Double,
    Float,

    // Operators
    Plus,
    Minus,
    Asterisk,
    Slash
}

struct Token
{
    TokenType type;
    size_t start;
    size_t end;
    byte[] slice;
}

unittest
{
    Token t = Token(TokenType.Int, 1, 1, null);
    assert(t.type == TokenType.Int);
    assert(t.start == 1 && t.end == 1);
}

unittest
{
    byte[] input = ['1', '+', '2'];
    enum MAX_SIZE = 4;
    Token[MAX_SIZE] tokens;
    size_t index = 0;
    size_t i = 0;
    for (i = 0; i < 3; i++)
    {
        import std.ascii;

        if (isDigit(input[i]))
        {
            tokens[index++] = Token(TokenType.Int, i, i, input[i .. i + 1]);
        }
        else
        {
            tokens[index++] = Token(TokenType.Plus, i, i, input[i .. i + 1]);
        }

    }
    tokens[index] = Token(TokenType.Eof, i, i);
    assert(tokens[3].type == TokenType.Eof);
    assert(tokens[0].type == TokenType.Int);

}

unittest
{
    byte[] input = ['1', '+', '2'];
    enum MAX_SIZE = 4;
    Token[MAX_SIZE] tokens;
    size_t index = 0;
    size_t i = 0;
    for (i = 0; i < 3; i++)
    {
        import std.ascii;

        if (isDigit(input[i]))
        {
            tokens[index++] = Token(TokenType.Int, i, i, input[i .. i + 1]);
        }
        else
        {
            tokens[index++] = Token(TokenType.Plus, i, i, input[i .. i + 1]);
        }

    }
    tokens[index] = Token(TokenType.Eof, i, i);
    assert(tokens[0].slice == input[0 .. 1]);
    assert(tokens[2].slice == input[2 .. $]);

}

unittest
{
    byte[] input = ['3', '+', '4'];
    enum MAX_SIZE = 4;
    Token[MAX_SIZE] tokens;
    size_t index = 0;
    size_t i = 0;
    for (i = 0; i < 3; i++)
    {
        import std.ascii;

        if (isDigit(input[i]))
        {
            tokens[index++] = Token(TokenType.Int, i, i, input[i .. i + 1]);
        }
        else
        {
            tokens[index++] = Token(TokenType.Plus, i, i, input[i .. i + 1]);
        }

    }
    tokens[index] = Token(TokenType.Eof, i, i);
    assert(cast(string) tokens[0].slice == "3");
    assert(cast(string) tokens[1].slice != "-");
    assert(cast(string) tokens[2].slice == "4");

}
