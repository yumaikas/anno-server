-- up
create table mail_items_to_boxes (
  id integer primary key,
  guid TEXT not null,
  mailboxes_id integer,
  mailitems_id integer, 
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  FOREIGN KEY (mailboxes_id) REFERENCES mailboxes(id),
  FOREIGN KEY (mailitems_id) REFERENCES mailitems(id)
)

-- down
drop table mail_items_to_boxes
