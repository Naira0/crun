# Crun

command run is a simple command runner

### Usage

a file with the name of CRUN must be located in the dir you ran the command in

then run `CRUN command-name`

any args you supply after the command name will be given to the orignal command

```
print:
    echo 

build:
    gcc -release -O -std=C++20 *.cpp
```

new lines and spaces are insignificant you can format it as you wish


