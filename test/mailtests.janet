(import ../mail)
(import db) 

(def DB_URL "test\\tests.db.sqlite3")
# Clear out the test db, if it exists
(when (= (get (os/stat DB_URL) :mode nil) :file) 
    (os/rm DB_URL)
)
# Read in the db migrations
(with-dyns [:db/migration-dir "db\\migrations"] 
    (db/migrate DB_URL)
)

(def box-addr "@appointment")

(with-dyns [:db/connection (db/connect DB_URL)] 
    (mail/create-box box-addr "Mailbox for appointments")
    (mail/receive-item box-addr {:content "@appt[An appointment to visit the doc |on: 2021-5-20]"})
    (mail/receive-item box-addr {:content "@appt[An appointment to shop for crafts |on: 2021-5-20]"})

    (def box-items (mail/read-box box-addr))
    (pp box-items)

    (assert (= (length box-items) 2) (string "We should have 2 appointments, but we have " (length box-items) " appointments"))
)
