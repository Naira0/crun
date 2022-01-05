module main;

import std.stdio;
import std.file;
import std.process;
import core.runtime : Runtime;
import std.datetime.stopwatch;

import token;
import lexer;
import parser;
import log;
import command;

void run(string contents)
{
    Lexer lexer = new Lexer(contents);

    auto tokens = lexer.scan();

    auto runtime = new parser.Runtime(tokens);

    runtime.parse();

    string[] args = Runtime.args;

    bool has_default = cast(bool)("default" in runtime.commands);

    if((args.length == 1 && !has_default) || (args.length > 1 && args[1] !in runtime.commands))
        fatal("must provide a command name");

    Token[] cmd = runtime.commands[has_default ? "default" : args[1]];

    runtime.variables["args"] = args[(has_default ? 1 : 2)..$];

    auto command = new Command(cmd, runtime.variables, runtime.commands);

    command.parse();

    command.run();
}

void main()
{
    string contents;
    
    try 
    {
        contents = readText("CRUN");
    }
    catch(FileException e)
    {
        fatal("A valid CRUN file must exist in the directory");
    }

    run(contents);
}