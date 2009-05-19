#!/bin/bash

function tex_file_basename(){
    echo "$1"
}

function make_tex_file(){
    basename=$1
    ruby -e 'puts File.open("./template.tex","r").read.gsub(/%%%%%%%%/, $stdin.read)' > ${basename}.tex
}

function make_img(){
    if [ $# -lt 1 ]; then
	echo "Error: make_img requires one argument"
	exit 1
    fi
    name=$1
    basename=$(tex_file_basename $1)

    cat | make_tex_file ${basename} ${texstring}
    
    command platex -interaction=nonstopmode ${basename}.tex 1>/dev/null || exit 1
    command dvipdfmx ${basename}.dvi  2>/dev/null 1>/dev/null
    command convert -trim +repage ${basename}.pdf ${basename}.png 2>/dev/null 1>/dev/null
    command install ${basename}.png ../images/
    command rm -f ${basename}.*
    echo "'${name}'" done
}

function make_simple_img(){
    if [ $# -lt 2 ]; then
	echo "Error: make_simple_img requires two arguments"
	exit 1
    fi
    echo $2 | make_img $1
}


# binary operators
binops_relational=$(echo \
    le leq prec preceq ll subset subseteq sqsubseteq \
    vdash smile in notin ge geq succ succeq gg supset supseteq \
    frown sqsupseteq dashv ni equiv sim simeq asymp approx \
    cong neq doteq propto models perp mid parallel bowtie )

binops_operational=$(echo \
    pm mp times div ast star circ bullet cdot cap cup uplus sqcap \
    sqcup vee wedge setminus wr diamond bigtriangleup bigtriangledown \
    triangleleft triangleright oplus ominus otimes oslash odot bigcirc amalg )

binops_amsmath=$(echo \
    backsim backsimeq approxeq eqsim because between blacktriangleleft \
    circeq eqcirc blacktriangleright bumpeq Bumpeq curlyeqprec curlyeqsucc \
    preccurlyeq eqslantless eqslantgtr succcurlyeq leqq geqq gtrsim \
    shortmid leqslant geqslant gtreqless gtreqqless gtrapprox lesseqgtr \
    lesseqqgtr lessgtr lll llless ggg gggtr gtrless lesssim \
    lessapprox multimap precsim succsim pitchfork doteqdot fallingdotseq \
    risingdotseq shortparallel smallsmile smallfrown Subset Supset \
    thicksim subseteqq supseteqq backepsilon vartriangleleft succapprox \
    thickapprox vartriangleright precapprox triangleq trianglelefteq \
    trianglerighteq vartriangle Vdash Vvdash vDash varpropto )

binops=$(echo ${binops_relational} ${binops_operational} ${binops_amsmath})

if [ $# -eq 0 ]; then
    for binop in ${binops}; do
	make_simple_img ${binop} "$\\${binop}$"
    done
elif [ $# -eq 1 ]; then
    cat | make_img "$1"
elif [ $# -eq 2 ]; then
    make_simple_img "$1" "$2"
fi

