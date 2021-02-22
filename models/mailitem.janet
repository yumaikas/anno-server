(use praxis)
(import stringx :as "str")

(s/defschema
  MailItem
  (s/field :id :number :hidden true)
  (s/field :content :text :title "Message Body"))

(s/defschema
  MailItem/Sending
  (s/field :address :string :title "To")
  (s/field :content :text :title "Message Body"))

(defn new-mail-item [kwargs]
  (as-> (s/cast :to MailItem/Sending :from kwargs :fields [:address :content]) msg
        (s/validate-required msg :address "Address is required")
        (s/validate-fn msg :address |(not (str/blank? $)) "Address cannot be blank")
        (s/validate-fn msg :address |(= (string/find "@" $) 0) "Address must start with @")
        (s/validate-fn msg :content |(not (str/blank? $)) "Content cannot be blank")))

(defn load-mail-item [dbargs] (s/cast :to MailItem :from dbargs :fields [:id :content]))
