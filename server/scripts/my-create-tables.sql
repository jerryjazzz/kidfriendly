
create table user (
  id INT unsigned not null primary key,
  email VARCHAR(255) not null unique key,
  json TEXT not null,
  modified_at TIMESTAMP not null
    on update CURRENT_TIMESTAMP,
  created_at TIMESTAMP not null
);
