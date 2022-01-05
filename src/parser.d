module parser;

import token;
import std.format;
import std.stdio;
import std.variant;

import log;

export class Runtime
{
public:
    this(Token[] tokens)
    {
        this.tokens = tokens;
    }

    void parse()
    {
        string cmd_name;
        int    start = 0;

        for(i = 0; i < tokens.length; i++)
        {
            Token token = tokens[i];

            if(token.type == Token.Type.EQUAL)
            {
                parse_var();
                continue;
            }
            if(token.type == Token.Type.CMD || token.type == Token.Type.EOF)
            {
                if(start != 0)
                {
                    if(cmd_name in commands)
                        fatal("command '", cmd_name, "' has already been defined");

                    commands[cmd_name] = tokens[start..i-1];
                }

                cmd_name = token.lexeme;
                start = i+1;
            }
        }
    }

    string[][string]  variables;
    Token[][string]  commands;

private:
    Token[] tokens;
    size_t  i;

    void parse_var()
    {
        Token last = last_token;
        Token next = next_token;

        if(last is null || last.type == Token.Type.END || next is null || next.type == Token.Type.END)
            fatal("A variable name and value must be provided on line ", peek.line);

        string varname = last.lexeme;

        if(varname in variables)
            fatal("variable '", varname, "' has already been defined");

        i++; // moves forward to not include the equal token

        string[] values;

        while(!at_end && peek.type != Token.Type.END)
        {
            values ~= peek.lexeme;
            i++;
        }

        variables[varname] = values;
    }

    bool at_end()
    {
        return i == tokens.length;
    }

    Token peek()
    {
        if(i >= tokens.length)
            return null;
        return tokens[i];
    }

    Token last_token()
    {
        // catchs potential underflow errors
        if(i-1 < 0 || i-1 == i.max)
            return null;
        return tokens[i-1];
    }

    Token next_token()
    {
        if(i+1 >= tokens.length)
            return null;
        return tokens[i+1];
    }
}


