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
 - Any change to constraints (such as 'not null', 'unique', 'foreign key', etc)

###

module.exports = schema = {}

# Common types
id_type = 'varchar(10)'
ip_address_type = 'varchar(15)'

# Common row definitions
standard_id =
  type: id_type
  options: 'not null primary key'

user_id =
  type: 'varchar(30)'
  options: 'not null'
  change_type_from: [id_type]

created_at =
  type: 'timestamp'
  options: 'not null'

updated_at =
  type: 'timestamp'

source_ver =
  type: 'integer'

# User table #

###
schema.users = {primary_key: 'user_id'}
schema.users.columns = {
  user_id
  email: {type: 'varchar(255)', options: 'not null unique'}
  created_at
  created_by_ip: {type: ip_address_type}
  updated_at
  source_ver
}
###

# Email_signup table #

schema.email_signup = {primary_key: 'id'}
schema.email_signup.columns = {
  id: standard_id
  email: {type: 'varchar(255)', options: 'not null'}
  ip: {type: ip_address_type}
  created_at
  source_ver
}

# Survey_answer #
schema.survey_answer = {}
schema.survey_answer.columns = {
  signup_id: {type: 'text'}
  body: {type: 'json', options: 'not null'}
  created_at
  source_ver
}

# Place table #

schema.place = {primary_key: 'place_id'}
schema.place.columns = {
  place_id: standard_id
  name: {type: 'varchar(255)'}
  location: {type: 'varchar(30)'}
  google_id: {type: 'varchar(41)', options: 'unique'}
  factual_id: {type: 'varchar(61)', options: 'unique'}
  details: {type: 'json'}
  lat: {type: 'real'}
  long: {type: 'real'}
  rating: {type: 'integer'}
  created_at
  updated_at
  source_ver
}

# Review table #

schema.review = {primary_key: 'review_id'}
schema.review.columns = {
  review_id: standard_id
  user_id
  place_id: {type: id_type, options: 'not null'}
  body: {type: 'json'}
  created_at
  updated_at
  source_ver
}

# Source_version table #
#
#   Maps git sha1 strings to an increasing version number. Server will find (or initialize)
#   the current source version on startup.

schema.source_version = {primary_key: 'id'}
schema.source_version.columns = {
  id: {type: 'serial', options: 'primary key'}
  sha1: {type: 'varchar(40)', options: 'not null unique'}
  commit_date: {type: 'timestamp', change_type_from: ['timestamp']}
  first_deployed_at: {type: 'timestamp', change_type_from: ['timestamp']}
}
