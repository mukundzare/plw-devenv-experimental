;; -*- coding: windows-1252 -*- 
;; COPYRIGHT (C) PLANISWARE 2017
;; Distributed under the MIT License
;; See accompanying file LICENSE file or copy at http://opensource.org/licenses/MIT

;;; no stupid message about abbrevs
(setq save-abbrevs 'silently)

(defun fullpath-relative-to-current-file (file-relative-path)  
  (concat (file-name-directory (or load-file-name buffer-file-name)) file-relative-path))

(defvar *javascript-evaluator-mode* :repl)
;; use opx2-js-mode
(defvar *use-opx2-js-mode* t)

(load (fullpath-relative-to-current-file "el/packages.el"))
(load (fullpath-relative-to-current-file "el/common-plw.el"))
(load (fullpath-relative-to-current-file "el/connect-is.el"))
(load (fullpath-relative-to-current-file "el/source-code-plw.el"))
(load (fullpath-relative-to-current-file "el/source-colorization.el"))
(load (fullpath-relative-to-current-file "el/eli-plw.el"))


(when *use-opx2-js-mode*
  (load (fullpath-relative-to-current-file "el/opx2-js-cache.el"))
  (load (fullpath-relative-to-current-file "el/opx2-js-mode-syntax.el"))
  (load (fullpath-relative-to-current-file "el/opx2-js-mode.el"))
  (load (fullpath-relative-to-current-file "el/ac-opx2js.el"))

;;  (load (fullpath-relative-to-current-file "el/pjs-semantic.el"))
  (load (fullpath-relative-to-current-file "el/pjs-mode-syntax.el"))
  (load (fullpath-relative-to-current-file "el/pjs-semantic.el"))
  (load (fullpath-relative-to-current-file "el/ac-pjs.el"))
  (load (fullpath-relative-to-current-file "el/pjs-mode.el"))
  ;;  (load (fullpath-relative-to-current-file "el/yasnippet.el"))
  )

(load (fullpath-relative-to-current-file "el/ac-config.el"))

(when (eq *javascript-evaluator-mode* :repl)
  (load (fullpath-relative-to-current-file "el/javascript-evaluator.el")))

;;------------- general emacs configuration ----------------

;;make sure emacs does not ask us to apply these parameters
(custom-set-variables
 '(safe-local-variable-values (quote
                               ((Package . OPX2-USER)
                                (Syntax . Common-Lisp)))))

(setq js-indent-level 2)

;;Ctrl+right mouse click = copy symbol/sexp
(defun mouse-get-thing (click)
  (interactive "e")
  (let ((str nil)
	(window (selected-window)))
    (save-current-buffer
      (save-excursion 
	(mouse-set-point click)
	(setq str (or (thing-at-point 'symbol)
		      (thing-at-point 'sexp)))
	(select-window window)))
    (when str
      (insert str))))

(global-unset-key [(control down-mouse-3)]) ;;to allow mouse-3 to work
(global-set-key [(control mouse-3)] 'mouse-get-thing)

;;---------------------- CVS bindings ----------------------------

(require 'vc)
(require 'vc-cvs)

(defun cvs-commit()  
  (interactive)
  (let* ((filename (buffer-file-name))
	 (scname (when (string-match "\\(sc[0-9]\\{4\\}\\)\\.lisp" filename)
		   (match-string 1 filename)))
	 (files (list filename)))    
    (vc-checkin files 'CVS)))

;; use yasnippets
(when (require 'yasnippet nil 'noerror)

  (pushnew (fullpath-relative-to-current-file "el/yasnippet") yas-snippet-dirs :test 'string=)
  (yas-reload-all)

  ;; yasnippet configuration

  ;; only expand snippet after typing
  (setq yas-expand-only-for-last-commands '(self-insert-command))
  
  (add-hook 'prog-mode-hook #'yas-minor-mode))  
