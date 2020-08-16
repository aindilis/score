;;; score.el --- Emacs helper functions for score.

;; Copyright (C) 2006  Free Software Foundation, Inc.

;; Author: Jason Sayne <jasayne@frdcsa>
;; Keywords: 

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; 

;;; Code:

(global-set-key "\C-crtc" 'score-show-goals)

(defun score-show-goals ()
  ""
  (interactive)
  (score-run "-c"))

(defun score-run (arg)
  "Sufficient time has passed, ask whether they have committed any other sins"
  (interactive)
  (let ((buf (get-buffer-create score-buffer-name)))
       (assert (and buf (buffer-live-p buf)))
       (pop-to-buffer buf)
       (erase-buffer)
       (comint-mode)
       (start-process "score" score-buffer-name "score" arg)
   ;; (kill-buffer (get-buffer score-buffer-name))
       ))

;; I would very much like to implement Patterns in Contexts
;; If Justin would like to Visit to Chicago for an extended stay, he
;; and I can implement PicForm, godwilling.

;; should have a whole notion of "current systems"

(provide 'score)
;;; score.el ends here

(defun score-shortcut-mark-as-completed ()
 "Mark the item under point as completed"
 (interactive)
 (kbs-send-command "assert" '("completed" (kbs-eap)))
 )
