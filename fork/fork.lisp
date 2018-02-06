(require :sb-posix)

(defun child-task ()
  (setf *random-state* (make-random-state t))
  (let ((sleep-time (+ 5 (random 16)))
        (pid (sb-posix:getpid)))
    (format t "child: my pid is ~a~%" pid)
    (sleep sleep-time)
    (format t "child [~a]: done sleeping! Slept for ~a seconds~%" pid sleep-time)
    (sb-posix:exit sleep-time)))

(defun fork-child ()
  (when (zerop (sb-posix:fork))
    (child-task)))

(defun main ()
  (format t "This is parent speaking.~%")
  (fork-child)
  (fork-child)
  (let* ((status* (make-array '(1) :element-type '(signed-byte 32)))
         (pid (sb-posix:wait status*))
         (status (aref status* 0)))
    (format t "child [~a] has finished. Child slept for ~a seconds~%"
            pid (sb-posix:wexitstatus status)))
  (format t "Parent is done.~%"))

(main)
        
