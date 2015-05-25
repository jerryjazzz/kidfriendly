
class Token
  @table:
    name: 'user_token'

  @fields:
    token_id:
      type: 'id'
    token_str:
      type: 'varchar(30)'
    user_id:
      type: 'id'
    facebook_token:
      type: 'varchar(60)'
    created_at:
      type: 'timestamp'
    expires_at:
      type: 'timestamp'

provide('model/Token', -> Token)
