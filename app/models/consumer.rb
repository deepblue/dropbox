require 'oauth'
require 'oauth/consumer'

class Consumer
  CONSUMER_KEY    = 'hgpbkNhkUdU6ntKZszVtw'
  CONSUMER_SECRET = 'sbLzTLFrOocT8HaQydmtNrPYvnuaD0eGJ2QlqpWMY'  

  def self.get
    @consumer ||= OAuth::Consumer.new CONSUMER_KEY, CONSUMER_SECRET,
      :site => 'https://api.openmaru.com',
      :access_token_path => '/oauth/access_token/springnote'
  end
  
  KEYCHAIN_SERVICE = 'OAuth access token for springnote'
  KEYCHAIN_ACCOUNT = 'springnote'
  KEYCHAIN_SEPERATOR = '--'
  
  def self.add_key_chain(token)
    password = [token.token, KEYCHAIN_SEPERATOR, token.secret].join
    
    OSX::SecKeychainAddGenericPassword nil, 
      KEYCHAIN_SERVICE.length, KEYCHAIN_SERVICE,
      KEYCHAIN_ACCOUNT.length, KEYCHAIN_ACCOUNT,
      password.length, password,
      nil
  end
  
  def self.token_from_key_chain
    status, *data = OSX::SecKeychainFindGenericPassword nil,
      KEYCHAIN_SERVICE.length, KEYCHAIN_SERVICE,
      KEYCHAIN_ACCOUNT.length, KEYCHAIN_ACCOUNT
    return false unless status.to_i == 0
    
    password_length = data.shift
    password_data   = data.shift
    password = password_data.bytestr(password_length)
    
    token, secret = password.split('--')
    return false if !token || !secret
    
    OAuth::AccessToken.new(get, token, secret)
  end
end
