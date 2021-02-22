(use praxis)
(import ../routes :as rt)
(import stringx :as str)

(s/defschema Mailbox 
  (s/field :id :number :hidden true)
  (s/field :address :string  :title "Address")
  (s/field :description :text :title "Description"))

(defn Mailbox/view-link [mbox] 
  (def addr (mbox :address))
  (assert (bytes? addr) "Mailbox have bytes :address to link!")
  [:a {:href (rt/show-box<- addr)} (string addr)])

(defn new-mbox [kwargs] 
  (as-> (s/cast :to Mailbox :from kwargs :fields [:address :description]) mbox
        (s/validate-fn mbox :address |(not (str/blank? $)) "Address cannot be blank")
        (s/validate-fn mbox :address |(= (string/find "@" $) 0) "Address must start with @")
        (s/validate-fn mbox :description |(not (str/blank? $)) "Description cannot be blank")))

