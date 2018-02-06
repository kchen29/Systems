(defmacro iterate-through-current-directory (pathname &body body)
  `(dolist (,pathname (directory (make-pathname :name :wild :type :wild)))
     ,@body))

(defun file-size (pathname)
  (with-open-file (stream pathname)
    (file-length stream)))

(defun ls ()
  (iterate-through-current-directory pathname
    (let* ((name (pathname-name pathname))
           (type (pathname-type pathname))
           (filename (format nil "~@[~a~]~@[.~a~]" name type)))
      (if (or name type)
          ;;~& is a hack for tabulation to work properly
          (format t "~&~a~20Tsize: ~a~%" filename (file-size filename))
          (format t "~a~20Tdir!~%" (car (last (pathname-directory pathname))))))))

(ls)
