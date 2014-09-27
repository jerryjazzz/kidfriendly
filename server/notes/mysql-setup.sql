
-- This script is not usually executed, it's more of a reference. Occasionally we copy-paste
-- from here to the mysql repl.

create table user (
  id INT unsigned not null primary key,
  email VARCHAR(255) not null unique key,
  json TEXT not null,
  modified_at TIMESTAMP not null
    on update CURRENT_TIMESTAMP,
  created_at TIMESTAMP not null
);

create table email_signup (
  id INT unsigned not null primary key,
  email VARCHAR(255) not null,
  created_at DATETIME not null,
  ip VARCHAR(15),
  source_ver int
);

create table source_version (
  id INT unsigned not null primary key auto_increment,
  sha1 VARCHAR(40) not null unique key,
  commit_date timestamp,
  first_deployed_at timestamp
);
