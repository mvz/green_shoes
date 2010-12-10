require 'tmpdir'
require 'pathname'
require 'gir_ffi'
require 'cairo'
require 'pango'

GirFFI.setup :Gdk
GirFFI.setup :GdkPixbuf
GirFFI.setup :Gtk
Gtk.init

Types = module Shoes; self end

module Shoes
  DIR = Pathname.new(__FILE__).realpath.dirname.to_s
  TMP_PNG_FILE = File.join(Dir.tmpdir, '__green_shoes_temporary_file__')
  HAND = Gdk::Cursor.new(:hand1)
  ARROW = Gdk::Cursor.new(:arrow)
  FONTS = [] #Gtk::Invisible.new.pango_context.families.map(&:name).sort
  LINK_DEFAULT = "<span underline='single' underline_color='#06E' foreground='#06E'>"
  LINKHOVER_DEFAULT = "<span underline='single' underline_color='#039' foreground='#039'>"
end

class Object
  remove_const :Shoes
end

require_relative 'shoes/ruby'
require_relative 'shoes/helper_methods'
require_relative 'shoes/colors'
require_relative 'shoes/basic'
require_relative 'shoes/main'
require_relative 'shoes/app'
require_relative 'shoes/anim'
require_relative 'shoes/slot'
require_relative 'shoes/text'
require_relative 'shoes/mask'
require_relative 'shoes/widget'

autoload :ChipMunk, File.join(Shoes::DIR, 'ext/chipmunk')
autoload :Bloops, File.join(Shoes::DIR, 'ext/bloops')
