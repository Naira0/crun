module src.parser;

import token;
import std.format;

export string[string] parse(Token[] tokens)
{
    string[string] output;

    foreach (i, token; tokens)
    {
        if(token.type == Token.Type.COLON)
        {
            if(i+1 != tokens.length && tokens[i+1].type != Token.Type.CMD)
            {
                Token t = tokens[i+1];
                string message = format("Error parsing line %d expected a command but got '%s'", t.line, t.type);
                throw new Exception(message);
            }
            
            string key = tokens[i-1].lexeme;
            string value = tokens[i+1].lexeme;

            output[key] = value;
        }
    }

    return output;
}

