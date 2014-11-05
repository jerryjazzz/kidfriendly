
module.exports = schema = []

# some common row definitions:
standard_id =
  name: 'id'
  type: 'int(10) unsigned'
  options: 'not null primary key'

source_ver =
  name: 'source_ver'
  type: 'int(11)'

# email_signup #

schema.email_signup = [standard_id]

schema.email_signup.push
  name: 'email'
  type: 'varchar(255)'
  options: 'not null'

schema.email_signup.push
  name: 'ip'
  type: 'varchar(15)'

schema.email_signup.push
  name: 'created_at'
  type: 'datetime'
  options: 'not null'

schema.email_signup.push(source_ver)

# place #

schema.place = [standard_id]
schema.place.push
  name: 'name'
  type: 'varchar(255)'

schema.place.push
  name: 'location'
  type: 'varchar(30)'

schema.place.push
  name: 'google_id'
  type: 'varchar(41)'
  options: 'unique key'

schema.place.push
  name: 'created_at'
  type: 'timestamp'
  options: 'not null'

schema.place.push
  name: 'updated_at'
  type: 'timestamp'
  options: 'not null'
  
schema.place.push(source_ver)

# source_version #

schema.source_version = []

schema.source_version.push
  name: 'id'
  type: 'int(10) unsigned'
  options: 'not null primary key auto_increment'

schema.source_version.push
  name: 'sha1'
  type: 'varchar(40)'
  options: 'not null unique key'

schema.source_version.push
  name: 'commit_date'
  type: 'timestamp'

schema.source_version.push
  name: 'first_deployed_at'
  type: 'timestamp'
