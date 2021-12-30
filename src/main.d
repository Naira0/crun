module src.main;

import std.stdio;
import std.file;
import std.array : appender;
import std.process;
import core.runtime : Runtime;
import core.stdc.stdlib;

import token;
import lexer;
import parser;

void fatal(string message)
{
    writeln("Fatal Error: ", message);
    exit(-1);
}

string command_args(string cmd_name, string[] args)
{
    auto builder = appender!string;

    builder.reserve(args.length+1);

    builder.put(cmd_name);
    builder.put(" ");

    foreach (arg; args)
    {
        builder.put(arg);
        builder.put(" ");
    }

    return builder.data;
}

void run(string contents)
{
    Lexer lexer = new Lexer(contents);

    auto tokens = lexer.scan();

    string[string] cmd_map;

    try
    {
        cmd_map = parse(tokens);
    }
    catch(Exception e)
    {
        fatal(e.msg);
    }

    string[] args = Runtime.args;

    if(args.length == 1)
        fatal("A command name must be provided");

    if(args[1] !in cmd_map) 
        fatal("invalid command name provided");

    string command = cmd_map[args[1]];

    auto exec = executeShell(command_args(command, args[2..$]));

    exec.output.writeln;
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
        fatal(e.msg);
    }
    
    run(contents);
}