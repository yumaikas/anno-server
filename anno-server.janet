(use osprey) 
(use praxis)
(import stringx :as "str")
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

# @task[Document/fix (form) better, write more docs on how to work with Osprey]


(s/defschema Mailbox 
  (s/field :id :number :hidden true)
  (s/field :address :string  :title "Address")
  (s/field :description :text :title "Description"))

(defn Mailbox/view-link [mbox] 
  (def addr (mbox :address))
  (assert (bytes? addr) "Mailbox have bytes :address to link!")
  [:a {:href (string "/box/" addr)} (string addr)])

(defn view/home [boxes &keys {:box box}] 
    (layout 
      [:div
       [:h2 "Current mailboxes"]
       (r/table Mailbox boxes 
                :ord [ :address :description ]
                :computed { :address {:title "Mailbox Address" :fn |(Mailbox/view-link $)}}) 
       [:br]
       [:h2 "Add new mailbox"]
       (r/form (or box (s/empty-of Mailbox))
               :action "/add-mailbox"
               :submit-txt "Create Mailbox!")]))

(defn get-boxes [] 
      (map |(s/cast :to Mailbox :from $ :fields [:address :description])  
           (mail/boxes)))

(defn new-mbox [kwargs] 
  (pp kwargs)
  (as-> (s/cast :to Mailbox :from kwargs :fields [:address :description]) mbox
        (s/validate-fn mbox :address |(not (str/blank? $)) "Address cannot be blank")
        (s/validate-fn mbox :address |(= (string/find "@" $) 0) "Address must start with @")
        (s/validate-fn mbox :description |(not (str/blank? $)) "Description cannot be blank")))

(GET "/" (view/home (get-boxes)))

(GET "/box/:addr" 
     # TODO: Pull all of the messages out of the mailbox here
     # TODO: Get things moving along.
     (layout [:div (params :addr)]))

(POST "/add-mailbox" 
    (def data (form/decode (request :body)))
    (def mbox (new-mbox data))
    (if (s/has-errors? mbox)
      (view/home (get-boxes) :box mbox)
      (do 
        (mail/create-box (get-in mbox [:vals :address]) (get-in mbox [:vals :description]))
        (redirect "/"))))

(os/shell "start http://localhost:9001")
(server 9001)
