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
}
