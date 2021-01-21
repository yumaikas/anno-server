(use osprey) 
(import db)
(import ./mail)

(enable :static-files)
(db/connect)

(defn layout [body] 
    (ok text/html
        (html/encode 
            (doctype :html5)
            [:html {:lang "en"}
                [:head
                    [:meta :charset "utf-8"]
                    [:meta 
                        :name "viewport" 
                        :content "width=device-width, initial-scale=1.0"
                    ]
                    [:link {:rel "stylesheet" :href "/base.css" }]
                ]
                [:body body]
            ]
        )
    )
)

(defn vw-table [headers row-spec] 
    (tracev headers)
    (def {:ord row-ord :rows rows } row-spec)
    
    [:table
        [:tr (map |[ :td $] headers)]
        (seq [r :in rows ] 
            [:tr
                (seq [k :in row-ord]
                    [:td {:data-col-name k} (string (r k))]
                )
            ]
        )
    ]
)

(defn vw-field [label name type &opt value] 
    (def input-spec (if value
        {:id name :name name :type type :value value}
        {:id name :name name :type type}
    ))
    
    [
        [:label {:class "block" :for name } label]
        [:br]
        [:input (merge {:style "margin-left 10px;"} input-spec)]
        [:br]
    ]
)

# @task[Document/fix (form) better, write more docs on how to work with Oprey]

(defn vw-add-box [] 
    (form nil {:action "/add-mailbox"}
      (splice (vw-field "Address:" "address" "text"))
      (splice (vw-field "Description:" "description" "text"))
      [:input {:type "submit" :value "Create Mailbox!"}]
    )
)


(GET "/" 
    (def boxes (mail/boxes))
    (layout [:div
        [:h2 "Current mailboxes"]
        (vw-table ["Id" "Address" "Description"] {
            :rows boxes
            :ord [:id :address :description] 
        })
        [:br]
        [:h2 "Add new mailbox"]
        (vw-add-box)
        ]
    )
)

(POST "/add-mailbox" 
    (def data (form/decode (request :body)))
    (mail/create-box (data :address) (data :description))
    (redirect "/")
)

(os/shell "start http://localhost:9001")
(server 9001)
