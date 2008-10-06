class LoginController < Rucola::RCWindowController
  ib_outlet :webview, :login_window
  
  def awakeFromNib
    @consumer = Consumer.get
  end
      
  def get_access_token
    @access_token = @request_token.get_access_token
    Consumer.add_key_chain(@access_token)
  end
  
  def show
    @login_window.makeKeyAndOrderFront(self)

    @request_token = @consumer.get_request_token
    @webview.setMainFrameURL @request_token.authorize_url
  end
    
  def notify_and_close(msg)
    @login_window.orderOut self
    nc = OSX::NSNotificationCenter.defaultCenter    
    nc.postNotificationName_object(msg, self)
  end
  
  def webView_didFinishLoadForFrame(sender, frame)
    case @webview.mainFrameURL.to_s
    when 'https://api.openmaru.com/oauth/authorize_success'
      get_access_token
      notify_and_close('LoginSuccess')
    when 'https://api.openmaru.com/oauth/authorize_failure'
      OSX::NSRunAlertPanel('스프링노트 로그인', '실패했습니다', '확인', nil, nil)
      notify_and_close('LoginFailed')
    end
  end
end