(require :sb-posix)

(let ((pid (sb-posix:fork)))
  (print pid))
