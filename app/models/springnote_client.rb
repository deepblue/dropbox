require 'springnote_resources'
require 'yaml'

class SpringnoteClient
  attr_accessor :token, :url
  
  def initialize(tok = nil)
    @token = tok
  end
    
  def parse_url
    @url.to_s.scan(%r!http://(.*?)\.springnote\.com/pages/(\d+)!)[0]
  end
  
  def import(path)
    note, pid = parse_url
    init(note)

    Springnote::Page.import_file(path).uri
  end
  
  def attach(path)
    note, pid = parse_url
    init(note)

    Springnote::Attachment.import_file(path, :relation_is_part_of => pid.to_i)
  end
    
  def init(note)
    config = {
      :access_token  => @token.token, :access_secret => @token.secret,
      :consumer_token  => @token.consumer.key, :consumer_secret => @token.consumer.secret
    }
    config[:domain] = note if note
    
    Springnote::Base.configuration.set config
  end  
end