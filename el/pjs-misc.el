;;* 
;;  COPYRIGHT (C) PLANISWARE 2016-05-27
;;
;;  All Rights Reserved
;;
;;  This program and the information contained herein are confidential to
;;  and the property of PLANISWARE and are made available only to PLANISWARE
;;  employees for the sole purpose of conducting PLANISWARE business.
;;
;;**************************************************************************
(defvar *profile-font-lock* t)
(defvar *profile-font-lock-threshold* 0.1)
  

(defun font-lock-fontify-keywords-region-with-profiling (start end &optional loudly)
  "Fontify according to `font-lock-keywords' between START and END.
START should be at the beginning of a line.
LOUDLY, if non-nil, allows progress-meter bar."
  (unless (eq (car font-lock-keywords) t)
    (setq font-lock-keywords
	  (font-lock-compile-keywords font-lock-keywords)))
  (let ((case-fold-search font-lock-keywords-case-fold-search)
	(keywords (cddr font-lock-keywords))
	(bufname (buffer-name)) (count 0)
        (pos (make-marker))
	(curtime (float-time (current-time)))
	keyword matcher highlights)
    ;;
    ;; Fontify each item in `font-lock-keywords' from `start' to `end'.
    (while keywords
      (if loudly (message "Fontifying %s... (regexps..%s)" bufname
			  (make-string (cl-incf count) ?.)))
      ;;
      ;; Find an occurrence of `matcher' from `start' to `end'.
      (when *profile-font-lock*
	(let ((exec-time (- (float-time (current-time)) curtime)))
	  (when (> exec-time *profile-font-lock-threshold*)
	    (message "Font lock report %s : %s sec" keyword (- (float-time (current-time)) curtime))))
	(setq curtime (float-time (current-time))))
      (setq keyword (car keywords) matcher (car keyword))
      (goto-char start)
      (while (and (< (point) end)
		  (if (stringp matcher)
		      (re-search-forward matcher end t)
		    (funcall matcher end))
                  ;; Beware empty string matches since they will
                  ;; loop indefinitely.
                  (or (> (point) (match-beginning 0))
                      (progn (forward-char 1) t)))
	(when (and font-lock-multiline
		   (>= (point)
		       (save-excursion (goto-char (match-beginning 0))
				       (forward-line 1) (point))))
	  ;; this is a multiline regexp match
	  ;; (setq font-lock-multiline t)
	  (put-text-property (if (= (point)
				    (save-excursion
				      (goto-char (match-beginning 0))
				      (forward-line 1) (point)))
				 (1- (point))
			       (match-beginning 0))
			     (point)
			     'font-lock-multiline t))
	;; Apply each highlight to this instance of `matcher', which may be
	;; specific highlights or more keywords anchored to `matcher'.
	(setq highlights (cdr keyword))
	(while highlights
	  (if (numberp (car (car highlights)))
	      (font-lock-apply-highlight (car highlights))
	    (set-marker pos (point))
            (font-lock-fontify-anchored-keywords (car highlights) end)
            ;; Ensure forward progress.  `pos' is a marker because anchored
            ;; keyword may add/delete text (this happens e.g. in grep.el).
            (if (< (point) pos) (goto-char pos)))
	  (setq highlights (cdr highlights))))
      (setq keywords (cdr keywords)))
    (set-marker pos nil)))
