(use osprey) 
(use praxis)
(use ./models/mailbox)
(use ./models/mailitem)
(import stringx :as "str")
(import db)
(import ./views :as v)
(import ./mail)
(import ./routes :as rt)

(enable :static-files)
(db/connect)

(defn show-html [body] 
  (ok text/html body))


(defn s. [& args] (string ;args))
# @task[Document/fix (form) better, write more docs on how to work with Osprey]

(GET rt/home 
     (show-html (v/home (mail/boxes))))
(GET rt/show-box 
     (def addr (params :addr))
     (def box ((mail/get-box addr) :vals))
     (def messages (mail/read-box addr))
     (show-html (v/mailbox box messages)))

(POST rt/send-to-box
      # Here be hooks
      (def new-item (new-mail-item params))
      (if (s/has-errors? new-item)
        (show-html (v/fix-mail-item new-item (params :addr)))
        (do
          (def linkage (mail/receive-item (params :address) (new-item :vals)))
          (redirect (rt/show-box<- (params :address))))))


(POST rt/add-mailbox 
      (def data (form/decode (request :body)))
      (def mbox (new-mbox data))
      (if (s/has-errors? mbox)
        (show-html (v/home (mail/boxes) :box mbox))
        (do 
          (mail/create-box 
            (get-in mbox [:vals :address]) 
            (get-in mbox [:vals :description]))
          (redirect (rt/home<-)))))


(os/shell "start http://localhost:9001")
(server 9001)
