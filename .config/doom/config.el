;; ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗
;;██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║
;;██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║
;;██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║
;;╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗
;; ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝


;; User
(setq user-full-name "Tommy Hoang"
	user-email-address "tommqh62@gmail.com")

;; Appearance
(setq doom-theme 'dracula)
(setq display-line-numbers-type t)

;; Functionality
(setq auto-save-default t
      make-backup-files t)



;; ██████╗ ██████╗  ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗
;;██╔═══██╗██╔══██╗██╔════╝     ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
;;██║   ██║██████╔╝██║  ███╗    ██╔████╔██║██║   ██║██║  ██║█████╗
;;██║   ██║██╔══██╗██║   ██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝
;;╚██████╔╝██║  ██║╚██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗
;; ╚═════╝ ╚═╝  ╚═╝ ╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝

;; General
(setq org-directory "~/org")
(setq org-roam-directory (file-truename "~/org"))
(org-roam-db-autosync-mode)
(setq org-hide-emphasis-markers t)


(after! org
  ;; Agenda files
  (setq org-agenda-files '("~/org/agendas"))
  ;; Habit
  (add-to-list 'org-modules 'org-habit)
  (org-load-modules-maybe t)
  (setq org-habit-show-habits t
        org-habit-graph-column 60
        org-habit-preceding-days 100
        org-habit-following-days 100
        org-habit-show-habits-only-for-today nil)
  ;; Agenda display
  (setq org-agenda-todo-ignore-scheduled 'all
        org-agenda-todo-ignore-deadlines 'all))

;; Org Daily
(defun my/get-items-from-file (file type today)
  "Get todo items from a specific agenda file."
  (let ((results '()))
    (when (file-exists-p file)
      (with-current-buffer (find-file-noselect file)
        (org-map-entries
         (lambda ()
           (let* ((todo (org-get-todo-state))
                  (heading (org-get-heading t t t t))
                  (scheduled (org-entry-get nil "SCHEDULED"))
                  (style (string-trim (or (org-entry-get nil "STYLE") ""))))
             (when (and todo
                        (or (string= style "habit")
                            (and scheduled
                                 (string-match today scheduled))))
               (let ((id (org-id-get-create)))
                 (push (list type heading id) results)))))
         nil 'file)))
    results))

(defun my/insert-today-tasks ()
  "Insert today's tasks from all agenda files as linked sections."
  (let* ((today (format-time-string "%Y-%m-%d"))
         (habits   (my/get-items-from-file "~/org/agendas/Habits.org" "habit" today))
         (study    (my/get-items-from-file "~/org/agendas/Study-Tasks.org" "study" today))
         (projects (my/get-items-from-file "~/org/agendas/Project-Tasks.org" "project" today))
         (inbox    (my/get-items-from-file "~/org/agendas/Uncategorised.org" "uncategorised" today)))
    ;; Habits
    (insert "* Habit Check\n")
    (if habits
        (dolist (item habits)
          (insert (format "** TODO [[id:%s][%s]]\n" (nth 2 item) (nth 1 item))))
      (insert "** No habits for today\n"))
    ;; Study
    (insert "\n* Study Tasks\n")
    (if study
        (dolist (item study)
          (insert (format "** TODO [[id:%s][%s]]\n" (nth 2 item) (nth 1 item))))
      (insert "** No study tasks for today\n"))
    ;; Projects
    (insert "\n* Project Tasks\n")
    (if projects
        (dolist (item projects)
          (insert (format "** TODO [[id:%s][%s]]\n" (nth 2 item) (nth 1 item))))
      (insert "** No project tasks for today\n"))
    ;; Inbox
    (insert "\n* Inbox\n")
    (if inbox
        (dolist (item inbox)
          (insert (format "** TODO [[id:%s][%s]]\n" (nth 2 item) (nth 1 item))))
      (insert "** Inbox is clear\n"))
    ;; Journal sections
    (insert "\n* Notes\n\n* Evening Review\n- What went well:\n- What didn't:\n- Carry forward:\n")))

(defun my/sync-daily-note ()
  "Append any new tasks to today's daily note under the correct section."
  (interactive)
  (let* ((today (format-time-string "%Y-%m-%d"))
         (daily-file (expand-file-name (concat today ".org") "~/org/daily/"))
         (section-map '(("habit"        . "* Habit Check")
                        ("study"        . "* Study Tasks")
                        ("project"      . "* Project Tasks")
                        ("uncategorised" . "* Inbox")))
         (all-items (append
                     (my/get-items-from-file "~/org/agendas/Habits.org" "habit" today)
                     (my/get-items-from-file "~/org/agendas/Study-Tasks.org" "study" today)
                     (my/get-items-from-file "~/org/agendas/Project-Tasks.org" "project" today)
                     (my/get-items-from-file "~/org/agendas/Uncategorised.org" "uncategorised" today))))
    (with-current-buffer (find-file-noselect daily-file)
      (dolist (item all-items)
        (let* ((type    (nth 0 item))
               (heading (nth 1 item))
               (id      (nth 2 item))
               (section (cdr (assoc type section-map))))
          (goto-char (point-min))
          (unless (search-forward heading nil t)
            ;; find the right section header
            (goto-char (point-min))
            (if (search-forward section nil t)
                (progn
                  (end-of-line)
                  (newline)
                  (insert (format "** TODO [[id:%s][%s]]" id heading)))
              ;; section not found, append to end
              (goto-char (point-max))
              (insert (format "\n** TODO [[id:%s][%s]]" id heading))))))
      (save-buffer))
    (message "Daily note synced.")))

(defun my/daily-propagate-todo-state ()
  "When a TODO in the daily note is marked DONE, propagate to the linked entry."
  (when (and (string= org-state "DONE")
             (string-match "/daily/" (or (buffer-file-name) "")))
    (let* ((heading (org-get-heading t t t t))
           (id (when (string-match "\\[\\[id:\\([^][]+\\)\\]" heading)
                 (match-string 1 heading))))
      (when id
        (save-excursion
          (org-id-goto id)
          (org-todo "DONE")
          (save-buffer))))))

(add-hook 'org-after-todo-state-change-hook #'my/daily-propagate-todo-state)

(after! org-roam
  (setq org-roam-dailies-directory "~/org/daily/"
        org-roam-dailies-capture-templates
        '(("d" "daily" plain
           (function my/insert-today-tasks)
           :target (file+head "%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d>\n#+filetags: daily\n\n")
           :unnarrowed t))))

(defun my/open-daily-and-agenda ()
  "Open today's daily note and agenda side by side."
  (interactive)
  (delete-other-windows)
  (let* ((today (format-time-string "%Y-%m-%d"))
         (daily-file (expand-file-name (concat today ".org") "~/org/daily/")))
    (if (file-exists-p daily-file)
        (find-file daily-file)
      (find-file daily-file)
      (insert (format "#+title: %s\n#+filetags: daily\n\n" today))
      (my/insert-today-tasks)))
  (split-window-right)
  (other-window 1)
  (org-agenda nil "a"))

(map! :leader
      :desc "Open daily + agenda"  "o D"   #'my/open-daily-and-agenda
      :desc "Sync daily note"      "o S" #'my/sync-daily-note)


;; Org Roam
(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :hook (org-roam-mode . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))

;; Appearance
(global-hl-line-mode t) ;; This highlights the current line in the buffer

(use-package beacon ;; This applies a beacon effect to the highlighted line
   :ensure t
   :config
   (beacon-mode 1))

(use-package org-superstar  ;; Improved version of org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1))))

(setq org-capture-templates
      '(("s" "Study task" entry
         (file "~/org/agendas/Study-Tasks.org")
         "* TODO [#%^{Priority|B|A|C}] %^{Task}  :%^{Tag|SchoolStudy|PersonalStudy}:\nSCHEDULED: %^{Scheduled}t\n:PROPERTIES:\n:CATEGORY: study\n:END:\n")

        ("p" "Project task" entry
         (file "~/org/agendas/Project-Tasks.org")
         "* TODO [#%^{Priority|B|A|C}] %^{Task}  :%^{Tag|SchoolProject|PersonalProject|WorkProject}:\nSCHEDULED: %^{Scheduled}t\n:PROPERTIES:\n:CATEGORY: project\n:END:\n")

        ("h" "Habit" entry
         (file "~/org/agendas/Habits.org")
         "* TODO %^{Habit}\nSCHEDULED: <%<%Y-%m-%d %a .+1d>>\n:PROPERTIES:\n:STYLE:    habit\n:REPEAT_TO_STATE: TODO\n:CATEGORY: habit\n:END:\n")
        
        ("u" "Uncategorised" entry
         (file "~/org/agendas/Uncategorised.org")
         "* TODO [#%^{Priority|B|A|C}] %^{Task}\nSCHEDULED: %^{Scheduled}t\n:PROPERTIES:\n:CATEGORY: inbox\n:END:\n")))

(after! org
  (setq org-tag-alist
        '((:startgroup . nil)
          ("SchoolStudy"    . ?s)
          ("PersonalStudy"  . ?x)
          (:endgroup . nil)
          (:startgroup . nil)
          ("SchoolProject"  . ?k)
          ("PersonalProject" . ?p)
          ("WorkProject"    . ?w)
          (:endgroup . nil)
          (:startgroup . nil)
          ("urgent"    . ?u)
          ("important" . ?i)
          (:endgroup . nil))))

(setq org-roam-capture-templates
      '(("m" "Main Note" plain "%?"
         :target (file+head "~/org/notes/${slug}.org"
                            ":PROPERTIES:\n:ROAM_ALIASES: %^{Aliases||}\n:END:\n#+title: ${title}\n#+date: %<%Y-%m-%d>\n#+filetags: %^{Tags||}")
         :unnarrowed t)))



(defun my/org-roam-capture-main-note ()
  "Capture using the 'm' template."
  (interactive)
  (org-roam-capture :keys "m"))

(map! :leader
      (:prefix ("n r" . "org-roam")
       :desc "Completion at point"   "c" #'completion-at-point
       :desc "Find node"             "f" #'org-roam-node-find
       :desc "Show graph"            "g" #'org-roam-graph
       :desc "Insert node"           "i" #'org-roam-node-insert
       :desc "Capture to node"       "n" #'org-roam-capture
       :desc "Toggle roam buffer"    "r" #'org-roam-buffer-toggle
       :desc "Capture to main node"  "m" #'my/org-roam-capture-main-note))

(setq org-preview-latex-default-process 'dvipng)

(setq org-preview-latex-process-alist
      '((dvipng :programs ("latex" "dvipng")
                :description "dvi > png"
                :message "you need to install latex and dvipng."
                :image-input-type "dvi"
                :image-output-type "png"
                :image-size-adjust (1.0 . 1.0)
                :latex-compiler ("latex -interaction nonstopmode -output-directory %o %f")
                :image-converter ("dvipng -D %D -T tight -o %O %f"))))
