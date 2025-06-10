;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Set theme to Catppuccin with Mocha flavor
(setq catppuccin-flavor 'mocha)
(setq doom-theme 'catppuccin)
;; Set the font
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font Mono" :size 18)
      ;; Set dynamic font for headers.
      doom-variable-pitch-font (font-spec :family "JetBrainsMono Nerd Font Mono" :size 18))
;; Spped of which-key popup
(setq which-key-idle-delay 0.0)

(defun my-weebery-is-always-greater ()
  (let* ((banner '("███████╗ ███╗   ███╗  █████╗   ██████╗ ███████╗  "
                   "██╔════╝ ████╗ ████║ ██╔══██╗ ██╔════╝ ██╔════╝  "
                   "█████╗   ██╔████╔██║ ███████║ ██║      ███████╗  "
                   "██╔══╝   ██║╚██╔╝██║ ██╔══██║ ██║      ╚════██║  "
                   "███████╗ ██║ ╚═╝ ██║ ██║  ██║ ╚██████╗ ███████║  "
                   "╚══════╝ ╚═╝     ╚═╝ ╚═╝  ╚═╝  ╚═════╝ ╚══════╝  "))
         (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
                +doom-dashboard--width
                (concat line (make-string (max 0 (- longest-line (length line))) 32)))
               "\n"))
     'face 'doom-dashboard-banner)))

;; Set it as your banner
(setq +doom-dashboard-ascii-banner-fn #'my-weebery-is-always-greater)

;; Custom headling text font sizes
(after! org
  (custom-set-faces!
    '(org-level-1 :inherit outline-1 :weight bold :height 1.4)
    '(org-level-2 :inherit outline-2 :weight bold :height 1.3)
    '(org-level-3 :inherit outline-3 :weight bold :height 1.2)
    '(org-level-4 :inherit outline-4 :weight bold :height 1.1)
    '(org-level-5 :inherit outline-5 :weight bold)
    '(org-level-6 :inherit outline-6 :weight bold)
    '(org-level-7 :inherit outline-7 :weight bold)
    '(org-level-8 :inherit outline-8 :weight bold)))
;; Simple black background - comprehensive version
(custom-set-faces!
  '(default :background "#000000")
  '(line-number :background "#000000")
  '(line-number-current-line :background "#000000")
  '(fringe :background "#000000")
  '(mode-line :background "#000000")
  '(mode-line-inactive :background "#000000")
  '(vertical-border :background "#000000"))

;; KEYBINDING SETUP
(map! :after evil
      :n "J" #'evil-scroll-down
      :n "K" #'evil-scroll-up
      :n "L" #'evil-end-of-line
      :v "L" #'evil-end-of-line
      :o "L" #'evil-end-of-line
      :n "H" #'evil-first-non-blank
      :v "H" #'evil-first-non-blank
      :o "H" #'evil-first-non-blank
      :n "O" #'+evil/insert-newline-below
      :n "C" #'evil-delete
      :v "C" #'evil-delete
      :o "C" #'evil-delete
      :n "CC" #'evil-delete-line
      :n "d" (lambda () (interactive) (setq evil-this-register ?_) (call-interactively #'evil-delete))
      :v "d" (lambda () (interactive) (setq evil-this-register ?_) (call-interactively #'evil-delete))
      :o "d" (lambda () (interactive) (setq evil-this-register ?_) (call-interactively #'evil-delete))
      :n "dd" (lambda () (interactive) (evil-delete-line (line-beginning-position) (line-beginning-position 2) 'line ?_))
      :n "x" (lambda () (interactive) (evil-delete-char (point) (1+ (point)) 'exclusive ?_))
      :i "<tab>" #'indent-for-tab-command)

;; Launch Doom Emacs in fullscreen mode
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Set relative line numbers
(setq display-line-numbers-type 'relative)

;; DASHBOARD CONFIGURATION: Multiple approaches for black background and red keys
;; Approach 1: Hook into dashboard creation with nuclear face remapping
;; This appears to do NOTHING for changing the color of the elements on the DASH
(add-hook 'doom-dashboard-mode-hook
          (lambda ()
            (setq-local face-remapping-alist
                        '((default (:background "#000000"))
                          (doom-dashboard-menu-title (:foreground "#cba6f7" :weight bold))
                          (doom-dashboard-menu-desc (:foreground "#cba6f7" :weight bold))
                          (doom-dashboard-footer-icon (:foreground "#cba6f7" :weight bold))))
            (buffer-face-mode 1)))

;; This appears to do nothing but make things black maybe?
(after! doom-dashboard
  ;; Try using custom-theme-set-faces! instead to target the theme directly
  ;; Apparently does nothing for the dash elements color
  (custom-theme-set-faces! 'catppuccin
    '(doom-dashboard-banner (:background "#000000"))
    '(doom-dashboard-footer (:background "#000000"))
    '(doom-dashboard-loaded (:background "#000000"))
    '(doom-dashboard-menu-title (:foreground "#000000" :weight bold :background "#000000"))
    '(doom-dashboard-menu-desc (:foreground "#000000" :weight bold :background "#000000"))
    '(doom-dashboard-footer-icon (:foreground "#000000" :weight bold :background "#000000")))

;; Appears to be what is working- dash breaks colors and an error forms when commented out.  
;;   Also use the regular method as backup
;;   DOES NOTHING FOR COLOR of dash icons/ text
  (custom-set-faces!
    '(doom-dashboard-menu-title :foreground "#000000" :weight bold :background "#000000")
    '(doom-dashboard-menu-desc :foreground "#000000" :weight bold :background "#000000")
    '(doom-dashboard-footer-icon :foreground "#000000" :weight bold :background "#000000")))

;; DASH TEXT & ICON custom colors
(add-hook 'after-init-hook
          (lambda ()
            (run-with-timer 0.5 nil
                           (lambda ()
                             (set-face-foreground 'doom-dashboard-menu-title "#b4befe")
                             (set-face-foreground 'doom-dashboard-menu-desc "#f28ba8") 
                             (set-face-foreground 'doom-dashboard-footer-icon "#f28ba8")))))


;; Org-babel configuration
(after! org
  ;; Enable various programming languages for org-babel
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)     ; Emacs Lisp
     (python . t)         ; Python
     (javascript . t)     ; JavaScript
     (shell . t)          ; Shell/Bash
     (sql . t)            ; SQL
     (C . t)              ; C/C++
     (java . t)           ; Java
     (go . t)             ; Go
     (rust . t)           ; Rust
     (ruby . t)           ; Ruby
     (R . t)              ; R
     (julia . t)          ; Julia
     (lua . t)            ; Lua
     (perl . t)           ; Perl
     (php . t)            ; PHP
     (haskell . t)        ; Haskell
     (clojure . t)        ; Clojure
     (scheme . t)         ; Scheme
     (lisp . t)           ; Common Lisp
     (latex . t)          ; LaTeX
     (org . t)            ; Org
     (makefile . t)       ; Makefile
     (dot . t)            ; Graphviz
     (plantuml . t)       ; PlantUML
     (octave . t)         ; Octave/MATLAB
     (gnuplot . t)        ; Gnuplot
     (sed . t)            ; sed
     (awk . t)            ; awk
     (calc . t)           ; Calc
     (ditaa . t)))        ; ditaa diagrams

;; DEBUG FUNCTIONS FOR DASHBOARD
;; Better debug: inspect all faces in dashboard buffer (fixed version)
(global-set-key (kbd "C-c d a") 
  (lambda () (interactive)
    (when (string= (buffer-name) "*doom*")  ; Fixed: check buffer name instead
      (let ((faces '()))
        (save-excursion
          (goto-char (point-min))
          (while (< (point) (point-max))
            (let ((face (get-text-property (point) 'face)))
              (when face
                (push face faces)))
            (forward-char 1)))
        (message "Dashboard faces found: %s" (delete-dups faces))))))

;; Debug: List all dashboard-related faces available
(global-set-key (kbd "C-c d l")
  (lambda () (interactive)
    (let ((dashboard-faces '()))
      (mapatoms 
       (lambda (symbol)
         (when (and (facep symbol)
                   (string-match "dashboard" (symbol-name symbol)))
           (push symbol dashboard-faces))))
      (message "All dashboard faces: %s" dashboard-faces))))

;; Nuclear option: manually force red colors on dashboard faces
';(global-set-key (kbd "C-c d r")
  (lambda () (interactive)
    (when (string= (buffer-name) "*doom*")
      (set-face-foreground 'doom-dashboard-menu-title "#f28ba8")
      (set-face-foreground 'doom-dashboard-menu-desc "#f28ba8") 
      (set-face-foreground 'doom-dashboard-footer-icon "#f28ba8")
      (message "Forced dashboard faces to red - check now!")))) 



;; =============================================================================
;; REMEMBER: Also add these to ~/.doom.d/packages.el:
;; (package! catppuccin-theme)
;; (package! solaire-mode :disable t)
;; =============================================================================

;; =============================================================================
;; TO TEST DASHBOARD DEBUG:
;; 1. Reload config: SPC h r r
;; 2. Go to dashboard: SPC b h
;; 3. Try Ctrl-c d a to see all faces used in dashboard
;; 4. Try Ctrl-c d l to see all available dashboard faces
;; 5. Try Ctrl-c r to reload dashboard
;; =============================================================================
