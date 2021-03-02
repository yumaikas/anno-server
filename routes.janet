(import route-helpers :as r)

(r/routes 
  home "/"
  show-box "/box/:addr"
  send-to-box "/send/:addr"
  add-mailbox "/add-mailbox"
  view-message "/message/:id")

