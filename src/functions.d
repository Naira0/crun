module functions;

import std.array;
import std.stdio;
import core.stdc.stdlib;

import command;

export alias FN = void(Command, string[]);

export FN*[string] function_table;

shared static this()
{
    function_table["print"]             = &print;
    function_table["loop"]              = &loop;
    function_table["end_loop"]          = &end_loop;
    function_table["display_commands"]  = &display_commands;
}

void print(Command cmd, string[] args) 
{
    args.join(" ").writeln;
}

void error(Command cmd, string[] args) 
{
    writeln("CRUN error: ", args.join(" "));
    exit(-1);
}

void display_commands(Command cmd, string[] args) 
{
    foreach (key, _; cmd.commands)
    {
        key.writeln;
    }
}

void loop(Command cmd, string[] args)
{
    cmd.should_loop = true;
}

void end_loop(Command cmd, string[] args)
{
    cmd.should_loop = false;
}

