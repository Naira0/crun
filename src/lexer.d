module lexer;

import token;
import log;
import std.stdio;

export class Lexer 
{
public:
    this(string source)
    {
        this.source = source;
    }

    Token[] scan()
    {
        tokens.reserve(source.length);
        
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

    Token last;

    int start   = 0;
    int current = 0;
    int line    = 1;

    bool in_cmd_block = false;

    void scan_token()
    {
        char c = advance();

        switch(c)
        {
            case '=':  scan_equal; break;
            case '@':  scan_valid(Token.Type.VAR); break;
            case '$':  
                if(!in_cmd_block)
                    lex_error(line, "$", "functions are only valid in command blocks");
                scan_valid(Token.Type.FN); break;
            case '"':  scan_quoted; break;
            case '/':  scan_slash; break;
            case '?':  set_token(Token.Type.IF_ERR); break;
            case ' ':  return;
            case '\t': return;
            case '\r': return;
            case '\n': handle_newline;  break;
            default:   scan_until_terminated; break;
        }
    }

    //  wont scan last token if the next is at end of the file
    //  improve token scanning 
    void scan_until_terminated()
    {
        while(!at_end)
        {
            char next = next_char;

            switch(next)
            {
                case ':':
                    current++;
                    set_token(Token.Type.CMD);
                    current++; 
                    in_cmd_block = true;
                    return;
                case ' ':
                    current++;
                    set_token(Token.Type.SYMBOL);
                    current++; 
                    return;
                case '\n':
                    set_token(Token.Type.SYMBOL);
                    return;
                case '\0':
                    current++;
                    set_token(Token.Type.SYMBOL);
                    return;
                default:
                    current++;
            }
        }
        
    }

    void scan_slash()
    {
        if(peek != '/')
            return set_token(Token.Type.SYMBOL);

        while(!at_end && next_char != '\n')
            advance;
    }

    void scan_equal()
    {
        if(peek == '>')
        {
            advance;
            set_token(Token.Type.ARROW);
        }
        else if(in_cmd_block)
            set_token(Token.Type.SYMBOL);
        else
            set_token(Token.Type.EQUAL); 
    }

    void scan_quoted()
    {
        start++;

        while(!at_end && peek != '"')
        {
            if(peek == '\n')
                line++;
            advance;
        }

        set_token(Token.Type.SYMBOL);

        advance;
    }

    void scan_valid(Token.Type type)
    {
        start++;

        while(!at_end && valid_char(peek))
            advance;

        set_token(type);
    }

    void handle_newline()
    {
        if(last !is null && last.line == line && last.type != Token.Type.CMD)
        {
            Token token = new Token(Token.Type.END, "", line);
            tokens ~= token;
        }
        line++;
    }

    char advance()
    {
        if(current >= source.length)
            return '\0';
        return source[current++];
    }

    char next_char()
    {
        if(current+1 >= source.length)
            return '\0';
        return source[current+1];
    }

    bool at_end()
    {
        return current >= source.length;
    }

    char peek()
    {
        if(current >= source.length)
            return '\0';
        return source[current];
    }

    bool valid_char(char c)
    {
        return c != ' ' && c != '\n' && c != '\t' && c != '\r';
    }

    void set_token(Token.Type type)
    {
        Token token = new Token(type, source[start .. current], line);
        tokens ~= token;
        last = token;
    }
    
}


