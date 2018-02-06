(require :sb-posix)

(defun child-task (in out)
  (sb-posix:close out)
  (let ((stream (sb-sys:make-fd-stream in :buffering :none)))
    (loop
       for char = (read-char stream nil nil)
       while char
         do (write-char char))))

(defun parent-task (in out)
  (sb-posix:close in)
  (let* ((message "this is a message")
         (stream (sb-sys:make-fd-stream out :output t)))
    (format stream message)))

(defun piping ()
  (multiple-value-bind (in0 out0) (sb-posix:pipe)
    (format t "input: ~a~20Toutput: ~a~%" in0 out0)
    (if (zerop (sb-posix:fork))
        (child-task in0 out0)
        (parent-task in0 out0))))

(piping)
