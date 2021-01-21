(import ../mail)
(import db) 

(defn assert-length [arr len & msg] 
    (assert (= (length arr) len) msg)
)

(def DB_URL "test\\tests.db.sqlite3")
# Clear out the test db, if it exists
(when (= (get (os/stat DB_URL) :mode nil) :file) 
    (os/rm DB_URL)
)
# Read in the db migrations, but quietly
(print "migrating")
(with-dyns [:db/migration-dir "db\\migrations" :out @""] 
    (db/migrate DB_URL)
)


(def box-addr "@appointment")

(with-dyns [:db/connection (db/connect DB_URL)] 
    (mail/create-box box-addr "Mailbox for appointments")
    (def to-update (mail/receive-item box-addr {:content "@appt[An appointment to visit the doc |on: 2021-5-20]"}))
    (def to-copy (mail/receive-item box-addr {:content "@appt[An appointment to shop for crafts |on: 2021-5-20]"}))

    (def box-items (mail/read-box box-addr))

    (assert (= (length box-items) 2) (string "We should have 2 appointments, but we have " (length box-items) " appointments"))
    
    (def shopping-box "@shopping")
    (mail/create-box shopping-box "Mailbox for shopping items")
    
    (mail/update-item (to-update :id) "@appt[An appointment to visit the therapist |on: 2021-6-23]")
    
    (mail/receive-item shopping-box {:content "@item[Milk|quantity: 1]"} )
    (mail/receive-item shopping-box {:content "@item[Lunchables|quantity: 5]"} )
    
    (mail/create-box "@emilycalendar" "Appointments that Emily's calendar needs")
    
    (mail/copy-item "@emilycalendar" (to-copy :id))
    
    (def emilyappts (mail/read-box "@emilycalendar"))
    (assert-length emilyappts 1 "Emily's calendar should only have 1 appointment now")
)
