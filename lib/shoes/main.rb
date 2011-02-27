class Shoes
  include Types
  @apps = []
  $urls = {}
  APPS = []

  def self.APPS; APPS end

  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'green shoes'
    args[:left] ||= 0
    args[:top] ||= 0
    projector = args[:prjct] = args[:projector]
    args.delete :projector

    app = App.new args
    @apps.push app

    app.top_slot = Flow.new app.slot_attributes(app: app, left: 0, top: 0)

    win = Gtk::Window.new :toplevel
    win.set_icon(GdkPixbuf::Pixbuf.new_from_file File.join(DIR, '../static/gshoes-icon.png'))
    win.set_title args[:title]
    win.set_default_size args[:width], args[:height]

    style = win.get_style
    # FIXME: No equivalent in GirFFI yet.
    #style.set_bg :normal, 65535, 65535, 65535

    class << app; self end.class_eval do
      define_method(:width){win.get_size[0]}
      define_method(:height){win.get_size[1]}
    end

    # FIXME: A less verbose interface would be preferable.
    win.set_events Gdk::EventMask[:button_press_mask] | Gdk::EventMask[:button_release_mask] | Gdk::EventMask[:pointer_motion_mask]

    GObject.signal_connect(win, "delete-event") do
      app.animates.each &:stop
      false
    end

    GObject.signal_connect win, "destroy" do
      app.close
    end if @apps.size == 1

    GObject.signal_connect(win, "button-press-event") do |w, e|
      # FIXME: Perhaps make e already be a Gdk::EventButton.
      app.mouse_button = e[:button][:button]
      app.mouse_pos = app.win.get_pointer
      mouse_click_control app
      mouse_link_control app
    end
    
    GObject.signal_connect(win, "button-release-event") do
      app.mouse_button = 0
      app.mouse_pos = app.win.get_pointer
      mouse_release_control app
    end

    GObject.signal_connect(win, "motion-notify-event") do
      app.mouse_pos = app.win.get_pointer
      mouse_motion_control app
      mouse_hover_control app
      mouse_leave_control app
    end

    # FIXME: #new should allow arguments to be left out (allow-null).
    app.canvas = projector ? Gtk::DrawingArea.new : Gtk::Layout.new(nil, nil)
    swin = Gtk::ScrolledWindow.new nil, nil
    swin.set_policy :never, :automatic
    swin.get_vadjustment.set_step_increment 10
    swin.add app.canvas
    win.add swin
    app.canvas.set_style style
    app.win, app.swin = win, swin

    if blk
      app.instance_eval &blk
    elsif projector
      app.send :projector, projector
    else
      app.instance_eval{$urls[/^#{'/'}$/].call app} #'
    end

    # FIXME: Have gir_ffi autocreate block arguments.
    Gtk.timeout_add 100, (Proc.new do
      # FIXME: Provide a way to check destroyed status.
      unless false # app.win.destroyed?
        download_images_control app
        if size_allocated? app
          call_back_procs app
          app.width_pre, app.height_pre = app.width, app.height
        end
        show_hide_control app
        set_cursor_type app
      end
      true
    end), nil

    call_back_procs app
    
    win.show_all
    @apps.pop
    Gtk.main if @apps.empty?
    app
  end
end
