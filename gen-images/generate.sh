#!/bin/bash

function tex_file_basename(){
    echo "$1"
}

function make_tex_file(){
    basename=$1
    texstring=$2
    
    echo "${texstring}" | ruby -e 'puts File.open("./template.tex","r").read.gsub(/%%%%%%%%/, $stdin.read)' > ${basename}.tex
}

function make_img(){
    if [ $# -lt 2 ]; then
	echo "Error: make_img requires two arguments"
	exit 1
    fi
    name=$1
    basename=$(tex_file_basename $1)
    texstring=$2

    make_tex_file ${basename} ${texstring}
    
    command platex -interaction=nonstopmode ${basename}.tex || exit 1
    command dvipdfmx ${basename}.dvi
    command convert -trim +repage ${basename}.pdf ${basename}.png
    command install ${basename}.png ../images/
    command rm -f ${basename}.*
}


# binary operators
binops=$(echo land lor cap cup cdot pm ast times div)

for binop in ${binops}; do
    make_img ${binop} "$\\${binop}$"
done

