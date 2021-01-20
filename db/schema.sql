CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE mailboxes (
  id integer primary key,
  address text not null,
  description text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE mailitems (
  id integer primary key,
  content text,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE mail_items_to_boxes (
  id integer primary key,
  guid TEXT not null,
  mailboxes_id integer,
  mailitems_id integer, 
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer,
  FOREIGN KEY (mailboxes_id) REFERENCES mailboxes(id),
  FOREIGN KEY (mailitems_id) REFERENCES mailitems(id)
)