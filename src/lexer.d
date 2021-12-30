module src.lexer;

import token;

export class Lexer 
{
public:
    this(string source)
    {
        this.source = source;
    }

    Token[] scan()
    {
        while(current < source.length)
        {
            start = current;
            scan_token();
        }

        Token end_token = new Token(Token.Type.EOF, "", line);
        tokens ~= end_token;

        return tokens;
    }

private:
    string  source;

    Token[] tokens;

    int     start   = 0;
    int     current = 0;
    int     line    = 1;

    void scan_token()
    {
        char c = advance();

        switch(c)
        {
            case ':':  set_token(Token.Type.COLON); break;
            case ' ':  return;
            case '\t': return;
            case '\r': return;
            case '\n': line++;     break;
            default:   read_cmd(); break;
        }
    }

    char advance()
    {
        if(current >= source.length)
            return '\0';
        return source[current++];
    }

    void set_token(Token.Type type)
    {
        Token token = new Token(type, source[start .. current], line);
        tokens ~= token;
    }

    void read_cmd()
    {
        while(current < source.length && valid_cmd_char(source[current]))
            advance();

        set_token(Token.Type.CMD);
    }

    bool valid_cmd_char(char c)
    {
        return (c >= 'a' && c <= 'z') ||
               (c >= 'A' && c <= 'Z') || 
               c == '_' || c == '-';
    }
    
}


