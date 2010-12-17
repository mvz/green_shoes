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
