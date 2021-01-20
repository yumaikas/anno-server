-- up
create table mailboxes (
  id integer primary key,
  address text not null,
  description text not null,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table mailboxes;
