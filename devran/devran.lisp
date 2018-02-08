;;returns a random number gotten from /dev/ran
(defun get-dev-ran ()
  (with-open-file (stream "/dev/random" :element-type '(signed-byte 32))
    (read-byte stream)))

(defun devran ()
  (let (lst)
    (dotimes (x 10)
      (push (get-dev-ran) lst))
    (with-open-file (stream "file.txt" :direction :output :if-exists :supersede)
      (write lst :stream stream))
    (format t "wrote ~a~%" lst))
  (let (lst2)
    (with-open-file (stream "file.txt")
      (setf lst2 (read stream)))
    (format t "read ~a~%" lst2)))

(devran)
