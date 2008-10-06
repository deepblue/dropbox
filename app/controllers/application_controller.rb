class ApplicationController < Rucola::RCController
  ib_outlet :main_window, :drop_window
  
  ib_action :show_login_window
  def show_login_window
    @main_window.orderOut self
    
    login_controller.showWindow(self) unless login_controller.windowLoaded?
    login_controller.show
  end
    
  def check_main_window(reload = false)
    @access_token = nil if reload
    
    win = access_token ? @drop_window : @main_window
    win.makeKeyAndOrderFront self
  end
  
  notify_on('LoginSuccess') {|noti| check_main_window(true)  }
  notify_on('LoginFailed')  {|noti| check_main_window(false) }
  
  def awakeFromNib
    # OSX::NSApp.delegate = self
    check_main_window
    register_drop_target
  end
    
  ########################################################################
  # DropWindow
  
  ib_outlet :url_text, :import_checkbox, :status_image, :background
  
  ib_action :mode_changed
  def mode_changed(sender)
    @status_image.image = load_image(import_mode? ? 'import' : 'attachment')
  end
  
  def import_mode?
    @import_checkbox.state.to_i == 1
  end
  
  ib_action :open_page
  def open_page(sender)
    url = OSX::NSURL.URLWithString(@url_text.stringValue)
    OSX::NSWorkspace.sharedWorkspace.openURL url
  end
        
  def load_image(name)
    @image_loaded ||= {}
    return @image_loaded[name] if @image_loaded[name]
    
    bundle = OSX::NSBundle.mainBundle
    path = bundle.pathForImageResource(name)
    OSX::NSImage.alloc.initWithContentsOfFile(path)
  end
  
  def register_drop_target
    @background.register_drop self
    @status_image.register_drop self
  end  

protected
  def access_token
    @access_token ||= Consumer.token_from_key_chain
  end
  
  def springnote_client
    @sc ||= SpringnoteClient.new(access_token)
    @sc.url = @url_text.stringValue
    @sc
  end
    
  def login_controller
    @login_controller ||= LoginController.alloc.init
  end
  
  
  # NSApplication delegate methods
  # def applicationDidFinishLaunching(notification)
  # end
  # 
  # def applicationWillTerminate(notification)
  # end  
end