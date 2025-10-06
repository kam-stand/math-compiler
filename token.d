module token;

enum TokenType
{
    Illegal,
    Eof,

    // Base types
    Int,

    // Operators
    Plus,
    Minus,
    Asterisk,
    Slash,
    Carrot
}

struct Token
{
    TokenType type;
    byte[] slice;
}

unittest
{
    Token t = Token(TokenType.Int, null);
    assert(t.type == TokenType.Int);
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
            tokens[index++] = Token(TokenType.Int, input[i .. i + 1]);
        }
        else
        {
            tokens[index++] = Token(TokenType.Plus, input[i .. i + 1]);
        }

    }
    tokens[index] = Token(TokenType.Eof, null);
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
            tokens[index++] = Token(TokenType.Int, input[i .. i + 1]);
        }
        else
        {
            tokens[index++] = Token(TokenType.Plus, input[i .. i + 1]);
        }

    }
    tokens[index] = Token(TokenType.Eof, null);
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
            tokens[index++] = Token(TokenType.Int, input[i .. i + 1]);
        }
        else
        {
            tokens[index++] = Token(TokenType.Plus, input[i .. i + 1]);
        }

    }
    tokens[index] = Token(TokenType.Eof, null);
    assert(cast(string) tokens[0].slice == "3");
    assert(cast(string) tokens[1].slice != "-");
    assert(cast(string) tokens[2].slice == "4");

}
