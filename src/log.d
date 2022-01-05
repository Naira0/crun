module log;

import std.stdio;
import core.stdc.stdlib;

import token;

export void fatal(A...)(A args)
{
    stderr.writeln("Fatal Error: ", args);
    exit(-1);
}

export void syntax_error(A...)(Token token, A args)
{
    stderr.writeln("Syntax error on line ", token.line, " with token '", token.lexeme, "'\n\tMessage: ", args);
    exit(-1);
}

export void lex_error(A...)(int line, string lexeme, A args)
{
    stderr.writeln("lexing error on line ", line, " with token '", lexeme, "'\n\tMessage: ", args);
    exit(-1);
}
