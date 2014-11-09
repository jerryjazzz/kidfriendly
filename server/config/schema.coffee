###

How to modify this file

This file is used by SchemaMigration.coffee to automatically perform *non destructive*
migrations to the DB schema.

The following changes ARE supported by automatic migration:

 - Insertion of a new column
 - Addition of a new table

Changes that are NOT supported by automatic migration:

 - Column rename or removal
 - Column reorder
 - Type or 'options' change

###

module.exports = schema = []

id_type = 'int(10) unsigned'
ip_address_type = 'varchar(15)'

# Some common row definitions
standard_id =
  name: 'id'
  type: id_type
  options: 'not null primary key'

created_at =
  name: 'created_at'
  type: 'datetime'
  options: 'not null'

source_ver =
  name: 'source_ver'
  type: 'int(11)'

# User table #

schema.user = [standard_id]

schema.user.push
  name: 'email'
  type: 'varchar(255)'
  options: 'not null unique key'

schema.user.push(created_at)

schema.user.push
  name: 'created_by_ip'
  type: ip_address_type

schema.user.push(source_ver)

# Email_signup table #

schema.email_signup = [standard_id]

schema.email_signup.push
  name: 'email'
  type: 'varchar(255)'
  options: 'not null'

schema.email_signup.push
  name: 'ip'
  type: ip_address_type

schema.email_signup.push
  name: 'created_at'
  type: 'datetime'
  options: 'not null'

schema.email_signup.push(source_ver)

# Place table #

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

# Review table #

schema.review = [standard_id]

schema.review.push
  name: 'user_id'
  type: id_type
  options: 'not null'

schema.review.push
  name: 'place_id'
  type: id_type
  options: 'not null'

schema.review.push(source_ver)

# Source_version table #

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
