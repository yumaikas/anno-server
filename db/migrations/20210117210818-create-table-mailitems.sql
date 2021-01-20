-- up
create table mailitems (
  id integer primary key,
  content text,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table mailitems
