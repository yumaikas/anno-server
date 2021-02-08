(use osprey) 
(use praxis)
(import db)
(import ./mail)

# @task[Start using praxis in this]

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
           :content "width=device-width, initial-scale=1.0" ]
          [:link {:rel "stylesheet" :href "/base.css" }] ]
         [:body body]])))

# @task[Document/fix (form) better, write more docs on how to work with Oprey]
# @task[So, (tuple) isn't a good thing to try to use? It sees to interact with html/encode poorly]


(s/defschema Mailbox 
  (s/field :id :number :hidden true)
  (s/field :address :string  :title "Address")
  (s/field :description :text :title "Description"))

(defn Mailbox/view-link [mbox] 
  (def addr (mbox :address))
  (assert (bytes? addr) "Mailbox have bytes :address to link!")
  [:a {:href (string "/box/" addr)} (string addr)])

(GET "/" 
    (def boxes 
      (map |(s/cast :to Mailbox :from $ :fields [:address :description])  
           (mail/boxes)))

    (layout 
      [:div
       [:h2 "Current mailboxes"]
       (r/table Mailbox boxes 
                :ord [ :address :description ]
                :computed { :address {:title "Mailbox Address" :fn |(Mailbox/view-link $)}}) 
       [:br]
       [:h2 "Add new mailbox"]
       (r/form (s/empty-of Mailbox) 
               :action "/add-mailbox"
               :submit-txt "Create Mailbox!")]))

(GET "/box/:addr" 
     # TODO: Pull all of the messages out of the mailbox here
     # TODO: Get things moving along.
     (layout [:div (params :addr)])

(POST "/add-mailbox" 
    (def data (form/decode (request :body)))
    (mail/create-box (data :address) (data :description))
    (redirect "/"))

(os/shell "start http://localhost:9001")
(server 9001)
