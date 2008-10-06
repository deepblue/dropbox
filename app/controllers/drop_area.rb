class DropArea < OSX::NSImageView
  def register_drop(controller)
    @controller = controller
    registerForDraggedTypes available_types
  end
  
  def draggingEntered(sender)
    # puts 'draggingEntered'
    OSX::NSDragOperationCopy
  end
  
  def draggingExited(sender)
    # puts 'draggingExited'
  end
  
  def prepareForDragOperation(sender)
    # puts 'prepareForDragOperation'
    true
  end
  
  def performDragOperation(sender)
    # puts 'performDragOperation'
    pb = sender.draggingPasteboard
    return false unless pb.availableTypeFromArray(available_types)
    
    paths = pb.propertyListForType(OSX::NSFilenamesPboardType).to_ruby
    paths.each do |path|
      @controller.import_mode? ?
        import(path) : attach(path)
    end if paths.respond_to?(:to_ary)
    true
  end
  
  def concludeDragOperation(sender)
    # puts 'concludeDragOperation'
  end
  
  def import(path)
    url = @controller.springnote_client.import(path)
    url_obj = OSX::NSURL.URLWithString(url)
    OSX::NSWorkspace.sharedWorkspace.openURL url_obj
  end
  
  def attach(path)
    @controller.springnote_client.attach(path)
  end
    
protected
  def available_types
    # OSX::NSFileContentsPboardType
    OSX::NSArray.arrayWithObjects(OSX::NSFilenamesPboardType, nil)
  end
end