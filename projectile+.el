;;; projectile+.el --- Enhance projectile with root directory marking wildcard support

;; Copyright © 2011-2019 Bozhidar Batsov <bozhidar@batsov.com>

;; Author: Ron Parker <rdparker@gmail.com>
;; URL: https://github.com/rdparker/projectile+
;; Keywords: project, convenience

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; This library provides enhanced support for detecting project roots in
;; projectile.

;;; Code:

(require 'projectile)

(defcustom projectile-dotnet-project-root-wildcards
  '("?*.sln"    ; dotnet solution
    "?*.csproj" ; dotnet C# project
    "?*.fsproj" ; dotnet F# project
    )
  "A list of wildcards that may mark the root of a dotnet project.
The parent-most match has precedence."
  :group 'projectile
  :type '(repeat string))

(defun projectile-matches-dotnet-wildcard (dir)
  "Check if any files match `projectile-dotnet-project-root-wildcards' in DIR."
  (cl-some (lambda (wildcard)
             (file-expand-wildcards (expand-file-name wildcard dir)))
           projectile-dotnet-project-root-wildcards))

(defun projectile-locate-parent-most-file (file name)
  "Look up the directory hierarchy from FILE for a directory containing NAME.
Return the parent-most directory containing a file NAME. Return
nil if not found.

Instead of a string, NAME can also be a predicate taking one argument
\(a directory) and returning a non-nil value if that directory is the one for
which we're looking."
  ;; copied from projectile.el and adjusted to return the parent-most result.
  (setq file (abbreviate-file-name file))
  (let ((root nil)
        try)
    (while (not (or (null file)
                    (string-match locate-dominating-stop-dir-regexp file)))
      (setq try (if (stringp name)
                    (projectile-file-exists-p (expand-file-name name file))
                  (funcall name file)))
      (if try (setq root file))
      (cond ((equal file (setq file (file-name-directory
                                     (directory-file-name file))))
             (setq file nil))))
    (and root (expand-file-name (file-name-as-directory root)))))

(defun projectile-root-dotnet (dir &optional list)
  "Identify a project root in DIR by bottom-up search for files in LIST.
If LIST is nil, use `projectile-project-root-files-bottom-up' instead.
Return the first (bottommost) matched directory or nil if not found."
  (projectile-locate-parent-most-file dir #'projectile-matches-dotnet-wildcard))

(add-to-list 'projectile-project-root-files-functions
             #'projectile-root-dotnet)

(provide 'projectile+)

;;; projectile+.el ends here
