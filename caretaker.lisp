(defun make-http-caretaker (uri)
  (let ((web-client (lambda () (drakma:http-request uri)))) 
    (list
     (lambda ()
       (multiple-value-bind (data code headers)
	   (funcall web-client)
	 (setf (return-code*) code)
	 (cif str-length (cdr (find :content-length headers :key #'car))
	      (setf (content-length*) (parse-integer str-length :junk-allowed t)))
	 (cif type (cdr (find :content-type headers :key #'car))
	      (setf (content-type*) type))
	 data))
     (lambda ()
       (setf web-client
	     (lambda () (values "" 501 nil)))
       (with-html-output-to-string (out)
	 (:html
	  (:head (:title "Rescinded"))
	  (:body
	   (:p "The caretaker to "
	       (:code (esc uri))
	       " has been rescinded!"))))))))
