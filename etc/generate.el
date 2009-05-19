
(defun make-cell-html (cellsym)
  (if cellsym
      (format "<td class=\"symbol-image\">%s</td>\n<td class=\"symbol-command\">%s</td>\n"
	      (format "<img src=\"./images/%s.png\" />" cellsym)
	      (format "<code>\\%s</code>" cellsym))
    "<td>&nbsp;</td><td>&nbsp;</td>"))

(defun insert-symbols (syms)
  (newline)
  (setq syms (reverse (reverse syms)))
  
  (let ((rows nil) fst snd)
    (while syms
      (setq fst (pop syms))
      (if syms
	  (progn (setq snd (pop syms))
		 (push (cons fst snd) rows))
	(push (cons fst nil) rows)))
    (setq rows (reverse rows))

    (insert "<table class=\"symbols\">\n")
    (dolist (row rows)
      (insert
       (format "<tr class=\"subentry\">%s%s</tr>\n"
	       (make-cell-html (car row))
	       (make-cell-html (cdr row))
	       )))
    (insert "</table>")
    ))

(insert-symbols '(le leq prec preceq ll subset subseteq sqsubseteq
		     vdash smile in notin ge geq succ succeq gg supset supseteq
		     frown sqsupseteq dashv ni equiv sim simeq asymp approx
		     cong neq doteq propto models perp mid parallel bowtie ))

(insert-symbols  '(pm mp times div ast star circ bullet cdot cap cup uplus sqcap
		      sqcup vee wedge setminus wr diamond bigtriangleup bigtriangledown
		      triangleleft triangleright oplus ominus otimes oslash odot bigcirc amalg ))

(insert-symbols '(backsim backsimeq approxeq eqsim because between blacktriangleleft 
			  circeq eqcirc blacktriangleright bumpeq Bumpeq curlyeqprec curlyeqsucc 
			  preccurlyeq eqslantless eqslantgtr succcurlyeq leqq geqq gtrsim 
			  shortmid leqslant geqslant gtreqless gtreqqless gtrapprox lesseqgtr 
			  lesseqqgtr lessgtr lll llless ggg gggtr gtrless lesssim 
			  lessapprox multimap precsim succsim pitchfork doteqdot fallingdotseq
			  risingdotseq shortparallel smallsmile smallfrown Subset Supset
			  thicksim subseteqq supseteqq backepsilon vartriangleleft succapprox
			  thickapprox vartriangleright precapprox triangleq trianglelefteq
			  trianglerighteq vartriangle Vdash Vvdash vDash varpropto ))
