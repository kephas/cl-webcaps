
(defvar *swiss-number-width* 256)

(let ((exports-by-swiss-number (make-hash-table))
      (exports-by-ocap (make-hash-table)))
  (defun register-capability (ocap)
    (cif swiss-number (gethash ocap exports-by-ocap)
	 swiss-number
	 (let ((swiss-number (random (expt 2 *swiss-number-width*))))
	   (setf (gethash swiss-number exports-by-swiss-number) ocap
		 (gethash ocap exports-by-ocap) swiss-number))))
  (let ((regex (ppcre:create-scanner "^/caps/(.*)")))
    (push (create-regex-dispatcher
	   regex
	   (lambda ()
	     (cif ocap (gethash (base64-string-to-integer
				 (elt (second (multiple-value-list (ppcre:scan-to-strings regex (request-uri*)))) 0))
				exports-by-swiss-number)
		  (funcall ocap)
		  (progn
		    (setf (return-code*) +http-not-found+)
		    ""))))
	  *dispatch-table*)))
