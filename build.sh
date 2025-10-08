#!/bin/bash

flags="-wi -c"
src="./*.d"
compiler="dmd"
bin="./bin"
app="app"
of="$bin/$app"

# Make bin folder if not exist
mkdir -p "$bin"

# Compile as object files
$compiler $flags $src

# Link object files into final executable
$compiler ./*.o -of="$of"


# move all object file into bin
mv ./*.o $bin