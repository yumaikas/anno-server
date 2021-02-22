(import janet-html :as html)
(use praxis)
(use ../models/mailbox)
(use ../models/mailitem)
(import ../routes :as rt)

(defn s. [& args] (string ;args))

(defn layout [body] 
  (html/encode 
    (html/doctype :html5)
    [:html {:lang "en"}
     [:head
      [:meta :charset "utf-8"]
      [:meta 
       :name "viewport" 
       :content "width=device-width, initial-scale=1.0" ]
      [:link {:rel "stylesheet" :href "/base.css" }] ]
     [:body body]]))


(defn home [boxes &keys {:box box}] 
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


(defn mailbox [box messages] 
  (def item-link 
    {:title "View Message"
     :fn |[:a {:href (rt/view-item<- (or ($ :id) "NIL"))} "View"] })
  (def item-header
    {:title "Content"
     :fn |[:div ($ :content)]})
  (tracev box)
  
  (layout
    [:div
     [:h2 (box :address)]
     [:div (box :description)]
     [:br]
     [:br]

     (r/table MailItem messages
              :ord [ :link :header ]
              :computed {:link item-link :header item-header })
    (r/form (as-> (s/empty-of MailItem/Sending) it 
                  (put-in it [:vals :address] (box  :address)))
            :action (rt/send-to-box<- (box :address))
            :submit-txt "Send message")]))

(defn fix-mail-item [item addr] 
  (layout 
    [:div
     [:h2 "Please correct errors with this message"]
     (r/form item
             :action (rt/send-to-box<- addr)
             :submit-txt "Send message")]))
