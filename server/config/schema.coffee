###

How to modify this file

This file is used by SchemaMigration.coffee to automatically perform *non destructive*
migrations to the DB schema.

The following changes ARE supported by automatic migration:

 - Insertion of a new column
 - Addition of a new table
 - Type change (using the 'change_type_from' field)

Changes that are NOT supported by automatic migration:

 - Column rename, removal or reordering
 - Any change to constraints (such as 'not null', 'unique key', 'foreign key', etc)

###

module.exports = schema = {}

# Common types
id_type = 'varchar(10)'
ip_address_type = 'varchar(15)'

# Common row definitions
standard_id = (name) ->
  name: name
  type: id_type
  change_type_from: ['int(10) unsigned']
  options: 'not null primary key'

created_at =
  name: 'created_at'
  type: 'datetime'
  options: 'not null'
  change_type_from: ['timestamp']

updated_at =
  name: 'updated_at'
  type: 'datetime'
  change_type_from: ['timestamp']

source_ver =
  name: 'source_ver'
  type: 'int(11)'

# User table #

schema.user = {primary_key: 'user_id'}
schema.user.columns = [
  standard_id('user_id')
  {name: 'email', type: 'varchar(255)', options: 'not null unique key'}
  created_at
  {name: 'created_by_ip', type: ip_address_type}
  updated_at
  source_ver
]

# Email_signup table #

schema.email_signup = {primary_key: 'id'}
schema.email_signup.columns = [
  standard_id('id')
  {name: 'email', type: 'varchar(255)', options: 'not null'}
  {name: 'ip', type: ip_address_type}
  {name: 'created_at', type: 'datetime', options: 'not null'}
  source_ver
]

# Place table #

schema.place = {primary_key: 'place_id'}
schema.place.columns = [
  standard_id('place_id')
  {name: 'name', type: 'varchar(255)'}
  {name: 'location', type: 'varchar(30)'}
  {name: 'google_id', type: 'varchar(41)', options: 'unique key'}
  {name: 'google_search_result', type: 'blob'} # todo: delete
  {name: 'google_details_result', type: 'blob'} # todo: delete
  {name: 'derived_summary', type: 'blob'} # todo: delete
  created_at
  updated_at
  source_ver
]

# Review table #

schema.review = {primary_key: 'review_id'}
schema.review.columns = [
  standard_id('review_id')
  {name: 'user_id', type: id_type, change_type_from: ['int(10) unsigned'], options: 'not null'}
  {name: 'place_id', type: id_type, change_type_from: ['int(10) unsigned'], options: 'not null'}
  {name: 'json', type: 'blob'}
  created_at
  updated_at
  source_ver
]

# Source_version table #

schema.source_version = {primary_key: 'id'}
schema.source_version.columns = [
  {name: 'id', type: 'int(10) unsigned', options: 'not null primary key auto_increment'}
  {name: 'sha1', type: 'varchar(40)', options: 'not null unique key'}
  {name: 'commit_date', type: 'datetime', change_type_from: ['timestamp']}
  {name: 'first_deployed_at', type: 'datetime', change_type_from: ['timestamp']}
]
