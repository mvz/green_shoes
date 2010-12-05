class Shoes
  include Types
  @apps = []

  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'green shoes'
    args[:left] ||= 0
    args[:top] ||= 0

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
      define_method(:width){win.size[0]}
      define_method(:height){win.size[1]}
    end

    # FIXME: A less verbose interface would be preferable.
    win.set_events Gdk::EventMask[:button_press_mask] | Gdk::EventMask[:button_release_mask] | Gdk::EventMask[:pointer_motion_mask]

    GObject.signal_connect(win, "delete-event") do
      false
    end

    GObject.signal_connect win, "destroy" do
      Gtk.main_quit
      File.delete TMP_PNG_FILE if File.exist? TMP_PNG_FILE
    end if @apps.size == 1

    GObject.signal_connect(win, "button-press-event") do
      mouse_click_control app
    end
    
    GObject.signal_connect(win, "button-release-event") do
      mouse_release_control app
    end

    GObject.signal_connect(win, "motion-notify-event") do
      mouse_motion_control app
    end

    app.canvas = Gtk::Layout.new
    win.add app.canvas
    app.canvas.style = style
    app.win = win

    app.instance_eval &blk if blk

    Gtk.timeout_add 100 do
      if size_allocated? app
        call_back_procs app
        app.width_pre, app.height_pre = app.width, app.height
      end
      set_cursor_type app
      true
    end

    call_back_procs app
    
    win.show_all
    @apps.pop
    Gtk.main if @apps.empty?
    app
  end
end
