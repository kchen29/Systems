(require :sb-posix)

;;alien is a char array
;;write the string to stdout
(defun print-alien-string (alien)
  (format t "~a~%" (alien-to-string alien)))

;;makes string from alien char array
;;iterate through until an eof is reached
(defun alien-to-string (alien)
  (do* ((str (make-array 0 :element-type 'character :fill-pointer 0 :adjustable t))
        (i 0 (1+ i))
        (code (deref alien i) (deref alien i))
        (char (code-char code) (code-char code)))
       ((zerop code) str)
    (vector-push-extend char str)))

(defun child-task (in out)
  (sb-posix:close out)
  (with-alien ((buf (array char 20)))
    (sb-posix:read in (addr buf) 20)
    (print-alien-string buf)
    (sb-posix:close in)))

(defun parent-task (in out)
  (sb-posix:close in)
  (let* ((message "this is a message")
         (message-size (1+ (length message)))
         (buf (make-alien-string message)))
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
