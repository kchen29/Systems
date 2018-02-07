(require :sb-posix)

(defmacro multi-close (&rest fds)
  `(progn
     ,@(loop for fd in fds collect `(sb-posix:close ,fd))))

(defun child-task (in0 out0 in1 out1)
  (multi-close out0 in1)
  (with-alien ((buf integer 0))
    (sb-posix:read in0 (addr buf) 1)
    (format t "child got ~a~%"  buf)
    (incf buf)
    (sb-posix:write out1 (addr buf) 1)
    (format t "child sent ~a~%" buf))
  (multi-close in0 out1))

(defun parent-task (in0 out0 in1 out1)
  (multi-close in0 out1)
  (with-alien ((buf integer 2))
    (sb-posix:write out0 (addr buf) 1)
    (format t "parent sent ~a~%" buf)
    (sb-posix:read in1 (addr buf) 1)
    (format t "parent got ~a~%" buf))
  (multi-close out0 in1))

(defun piping ()
  (multiple-value-bind (in0 out0) (sb-posix:pipe)
    (multiple-value-bind (in1 out1) (sb-posix:pipe)
      (if (zerop (sb-posix:fork))
          (child-task in0 out0 in1 out1)
          (parent-task in0 out0 in1 out1)))))

(piping)
