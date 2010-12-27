class Range 
  def rand 
    conv = (Integer === self.end && Integer === self.begin ? :to_i : :to_f)
    ((Kernel.rand * (self.end - self.begin)) + self.begin).send(conv) 
  end 
end

class Object
  def alert msg
    # FIXME: Gtk::MessageDialog has no introspectable constructors.
    #dialog = Gtk::MessageDialog.new(app.win, :modal, :info, :buttons_ok, msg)
    dialog = Gtk::Dialog.new
    dialog.set_transient_for app.win
    dialog.set_modal true
    dialog.add_button "gtk-ok", Gtk::ResponseType[:ok]

    # FIXME: Dynamically get class of returned widgets.
    area = Gtk::VBox.send :_real_new, dialog.get_content_area.to_ptr
    area.add Gtk::Label.new(msg)

    dialog.set_has_separator false
    dialog.set_title "Shoes says:"
    dialog.show_all

    dialog.run
    dialog.destroy
  end
  
  def ask_open_file
    dialog = Gtk::FileChooserDialog.new(
      "Open File",
      app.win,
      Gtk::FileChooser::ACTION_OPEN,
      nil,
      [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
      [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT]
    )
    ret = dialog.run == Gtk::Dialog::RESPONSE_ACCEPT ? dialog.filename : nil
    dialog.destroy
    ret
  end
  
  def exit
    Gtk.main_quit
    File.delete Shoes::TMP_PNG_FILE if File.exist? Shoes::TMP_PNG_FILE
  end
end

class String
  def mindex str
    n, links = 0, []
    loop do
      break unless n= self.index(str, n)
      links << n
      n += 1
    end
    links
  end
end
