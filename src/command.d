module command;

import std.variant;
import std.array;
import std.stdio;
import std.process;

import token;
import functions;
import log;

struct Function
{
    this(string name, FN *exec)
    {
        this.name = name;
        this.exec = exec;
    }

    void run(Command cmd)
    {
        exec(cmd, args);
    }

    FN       *exec;
    string    name;
    string[]  args;
}

struct Process 
{
    this(string process)
    {
        this.process = process;
    }

    void run(Command cmd)
    {
        auto result = executeShell(process ~ " " ~ args.join(" "));

        result.output.writeln;

        if(result.status != 0)
            fail_fn.run(cmd);
    }

    Function    fail_fn;
    string      process;
    string[]    args;
}

export class Command
{
public:
    this(Token[] tokens, string[][string] variables, Token[][string]  commands)
    {
        this.tokens     = tokens;
        this.variables  = variables;
        this.commands   = commands;
    }

    void parse()
    {
        Token token;

        for(i = 0; i < tokens.length; i++)
        {
            token = tokens[i];

            if(token.type == Token.Type.FN)
                statements ~= Variant(parse_function(token));
            if(token.type == Token.Type.SYMBOL)
                parse_process(token);
        }
    }

    void run()
    {
        loop: foreach(statement; statements)
        {
            if(statement.type == typeid(Function))
            {
                auto fn = statement.get!Function;
                fn.run(this);
            }
            if(statement.type == typeid(Process))
            {
                auto process = statement.get!Process;
                process.run(this);
            }
        }

        if(should_loop)
            goto loop;
    }

    string[][string] variables;
    Token[][string]  commands;
    
    bool should_loop;
    bool should_async;

private:
    Token[] tokens;
    size_t i;

    Variant[] statements;
    
    Function parse_function(Token token)
    {
        if(token.lexeme !in function_table)
            syntax_error(token, "Function does not exist");

        Function fn = Function(token.lexeme, function_table[token.lexeme]);

        if(i+1 >= tokens.length || tokens[i+1].type != Token.Type.ARROW)
        {
            fn.args = [""];
            return fn;
        }

        i += 2; // moves forward past the function token and arrow token

        string[] args; 

        while(!at_end && tokens[i].type != Token.Type.END)
        {
            if(tokens[i].type == Token.Type.VAR)
                args ~= parse_var(tokens[i]);
            else 
                args ~= tokens[i].lexeme;
            i++;
        } 

        fn.args = args;

        return fn;
    }

    string parse_var(Token token)
    {
        if(token.lexeme !in variables)
            syntax_error(token, "use of undefined variable");
        return variables[token.lexeme].join(" ");
    }

    void parse_process(Token token)
    {
        Process process = Process(token.lexeme);

        string[] args;

        i++;
        while(!at_end && tokens[i].type != Token.Type.END)
        {
            if(tokens[i].type == Token.Type.IF_ERR)
            {
                if(!match_next(Token.Type.FN))
                    syntax_error(tokens[i+1], "if error conditions must be followed by a function");
                process.fail_fn = parse_function(tokens[++i]);
                break;
            }
            else if(tokens[i].type == Token.Type.VAR)
                args ~= parse_var(tokens[i]);
            else 
                args ~= tokens[i].lexeme;
            
            i++;
        }

        process.args = args;

        statements ~= Variant(process);
    }

    bool match_next(Token.Type type)
    {
        if(i+1 >= tokens.length)
            return false;
        return tokens[i+1].type == type;
    }

    bool at_end()
    {
        return i >= tokens.length;
    }
   
}