(import db)
(import uuid)
(import ./errs)

# Only used for debugging
(import globals)

(var dbconn nil)
(when (globals/in-repl)  
    (set dbconn (db/connect))
)

(def *hooks* @{})

(defn get-conn [] 
    (or dbconn (dyn :db/connection))
)

(defn create-box
    "Create a mailbox with the given address and description. Returns the updated mailbox with an :id"
    [address description] 
    (with-dyns [:db/connection (get-conn)] 
    (db/insert :mailboxes {
        :address address
        :description description
    }))
)

(defn read-box 
    "Given an address, list out all of the mail in that box" 
    [address]
    (with-dyns [:db/connection dbconn] 
        (db/query ```
            Select * 
            from mailboxes mb 
            left join mail_items_to_boxes as jt on mb.id = jt.mailboxes_id 
            left join mailitems as mi on mi.id = jt.mailitems_id 
            where mb.address = :address
            ``` 
            {:address address}))) 
            
(defn boxes 
    "List out all of the mailboxes and their addresses connected to this db"
    [] 
    (with-dyns [:db/connection (get-conn)]
        (db/query `Select id, address, description from mailboxes`)
    )
)
            
(defn- create-item 
    "Creates a mail item"
    [item] 
    (with-dyns [:db/connection (get-conn)] 
        (errs/ctx (string "Failed to create a mail item: " (describe item))
            (db/insert :mailitems {:content (item :content)})
        )
    )
)

(defn receive-item 
    "Save an item to a mailbox"
    [address item] 
    (with-dyns [:db/connection (get-conn)] 
        (defn get-mb [] 
            (errs/ctx "Failed in get-mb"
                (def results (db/query `Select id from mailboxes where address = :address` {:address address}))
                (results 0)
            )
        )
        (errs/ctx (string "Failed to recieve an item " item " into a mailbox " address)
            (def box-id ((get-mb) :id))
            (def {:id item-id}  (create-item item))
            (def item-uuid (uuid/new))
            (db/query ```Insert into mail_items_to_boxes (mailboxes_id, mailitems_id, guid) values (:box_id, :item_id, :uuid) ``` { 
                :box_id box-id 
                :item_id item-id 
                :uuid item-uuid
            })
        )
    )
)

