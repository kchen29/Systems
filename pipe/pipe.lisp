(require :sb-posix)

(defun child-task (in out)
  (sb-posix:close out)
  (let ((buf (make-alien (array char 1))))
    (sb-posix:read in buf 20)
    (do* ((ar (deref buf 0))
          (i 0 (1+ i))
          (code (deref ar i) (deref ar i)))
         ((zerop code))
      (format t "~a" (code-char code)))
    (format t "~%")
    (sb-posix:close in)
    (free-alien buf)))

(defun parent-task (in out)
  (sb-posix:close in)
  (let* ((message "this is a message")
         (message-size (1+ (length message)))
         (buf (make-alien-string message)))
    ;;(print buf)
    (sb-posix:write out buf message-size)
    (sb-posix:close out)
    (free-alien buf)))

(defun piping ()
  (multiple-value-bind (in0 out0) (sb-posix:pipe)
    (format t "input: ~a~20Toutput: ~a~%" in0 out0)
    (if (zerop (sb-posix:fork))
        (child-task in0 out0)
        (parent-task in0 out0))))

(piping)
