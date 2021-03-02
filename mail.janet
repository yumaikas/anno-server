(import db)
(import uuid)
(import err)
(use praxis)
(use ./models/mailbox)
(use ./models/mailitem)

# @task[]
# Only used for debugging
(import globals)

(var dbconn nil)
(when (globals/in-repl)  
    (set dbconn (db/connect)))

(def *hooks* @{})

(defn get-conn [] 
    (or dbconn (dyn :db/connection)))

(defn create-box
    "Create a mailbox with the given address and description. Returns the updated mailbox with an :id"
    [address description] 
    (with-dyns [:db/connection (get-conn)] 
    (db/insert :mailboxes {
        :address address
        :description description })))

(defn get-box 
  "Given an address, get the metadata for given mailbox"
  [address] 
  (with-dyns [:db/connection (get-conn)]
    (def [mbox] (db/query ```
              Select address, description, created_at, updated_at
              from mailboxes mb
              where mb.address = :address
              ```
              {:address address}))
    (s/cast :to Mailbox :from mbox :fields [:address :description])
    ))
(defn read-box 
    "Given an address, list out all of the mail in that box" 
    [address]
    (with-dyns [:db/connection dbconn] 
      (as?->
        (db/query ```
            Select mi.id, mi.content
            from mailboxes mb 
            left join mail_items_to_boxes as jt on mb.id = jt.mailboxes_id 
            left join mailitems as mi on mi.id = jt.mailitems_id 
            where mb.address = :address
            ``` 
            {:address address}) msgs
        (map load-mail-item msgs))))
            
(defn boxes 
    "List out all of the mailboxes and their addresses connected to this db"
    [] 
    (with-dyns [:db/connection (get-conn)]
      (as?-> 
        (db/query `Select id, address, description from mailboxes`) it
        (map |(s/cast :to Mailbox :from $ :fields [:address :description]) it))))
            (defn- create-item 
    "Creates a mail item"
    [item] 
    (with-dyns [:db/connection (get-conn)] 
      (pp item)
      (err/wrap (string "Failed to create a mail item: " (describe item))
                (db/insert :mailitems {:content (item :content)}))))

(defn get-message 
  "Gets a mail-item by its db id"
  [item_id]
  (with-dyns [:db/connection (get-conn)]
    (def [item] (db/query "Select content from mailitems where id = :id" {:id item_id}))
    (s/cast :to MailItem :from item :fields [:id :content])))

(defn receive-item 
    "Save an item to a mailbox"
    [address item] 
    (with-dyns [:db/connection (get-conn)] 
        (defn get-mb [] 
            (err/wrap "Failed in get-mb"
                (def results (db/query `Select id from mailboxes where address = :address` {:address address}))
                (results 0)))

        (err/wrap (string "Failed to recieve an item " item " into a mailbox " address)
            (def box-id ((get-mb) :id))
            (def {:id item-id}  (create-item item))
            (def item-uuid (uuid/new))
            (db/insert :mail_items_to_boxes { 
                :mailboxes_id box-id 
                :mailitems_id item-id 
                :guid item-uuid }))))

(defn update-item 
    "Update a mailbox item with new content (triggering any relevant hooks)"
    [item_id new-content]
    (db/update :mailitems item_id { :content new-content }))

(defn copy-item 
    "Copy an item to a new mailbox"
    [to-addr item_id] 
    (with-dyns [:db/connection (get-conn)]
      (err/wrap (string "Failed to copy item of id (" item_id ") to " to-addr)
                (pp "XEH")
                (def item (get-message item_id))
                (pp "test")
                (receive-item to-addr { :content (item :content )}))))
