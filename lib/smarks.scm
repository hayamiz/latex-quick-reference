;; -*- coding: utf-8 -*-

;;; this is a list, because paths parameter of `load' requires a list
(define *entries-path*
  (let1 lqr-root (sys-getenv "LQR_ROOT")
      (if lqr-root
	  (list (string-append lqr-root "/entries"))
	  (let* ((p (current-load-port))
		 (pn (and p (port-name p))))
	    (if (and (string? pn)
		     (file-exists? pn))
		(list
		 (sys-normalize-pathname
		  (string-append (sys-dirname pn) "/../entries")
		  :absolute #t :expand #t :canonicalize #t))
		)))))

(use srfi-1)  ;; List library
(use srfi-13) ;; String library
(use util.match)
(use text.tree)
(use text.html-lite)
(use gauche.parameter)

(define *entry-contents*
  (make-parameter ()))

(define (my-take ls n)
  (let loop((ret ()) (ls ls) (n n))
    (cond ((null? ls) (reverse ret))
	  ((= 0 n) (reverse ret))
	  (else
	   (loop (cons (car ls) ret)
		 (cdr ls) (- n 1))))))

(define (my-drop ls n)
  (let loop((ls ls) (n n))
    (cond ((null? ls) ())
	  ((= n 0) ls)
	  (else
	   (loop (cdr ls) (- n 1))))))

(define (div-list ls d)
  (let loop((ret ()) (ls ls))
    (cond ((null? ls) (reverse ret))
	  (else
	   (loop (cons (my-take ls d) ret) (my-drop ls d))))))

(define (smarks-mathsymbol . args)
  (let-keywords args
      ((title "Mathematical symbols")
       (keyword :keyword ())
       (keywords :keywords ())
       (symbol :symbol ())
       (symbols :symbols ()))
    (let ((symbols (append symbols symbol))
	  (keywords (append keywords keyword)))
      (list :title title :keywords keywords :symbols symbols)
      (let ((symbols (map (lambda (sym)
			    (match sym
			      ((sym descr) (cons sym descr))
			      (sym (cons sym ""))))
			  symbols))
	    (symbol->tds (lambda (symbol)
			   (let ((sym (car symbol))
				 (descr (cdr symbol)))
			     (list (html:td
				    :class "symbol-image"
				    (html:img
				     :src (format #f "./images/~a.png" sym)))
				   (html:td
				    :class "symbol-command"
				    (html:code (format #f "\\~a" sym))
				    (if (> (string-length descr) 0)
					(string-append " - " descr) "")))))))
	(let1 ret (tree->string
		   (html:div
		    :class "entry"
		    (html:h3 title)
		    (html:div :class "keywords" (string-join keywords ", "))
		    (apply html:table
			  :class "symbols"
			  (map (lambda (symbols)
				 (apply
				  html:tr :class "subentry"
				  (apply append (map symbol->tds symbols))))
			       (div-list symbols 2)))))
	  (*entry-contents*
	   (cons ret (*entry-contents*)))
	  ret)
	 ))))

(define (main args)
  (print *entries-path*)
  (when (not (null? (cdr args)))
    (for-each (lambda (file)
		(load file :paths *entries-path*))
	      (cdr args))
    (for-each print (reverse (*entry-contents*)))
    )
  0)
