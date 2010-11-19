require 'tmpdir'
require 'pathname'
require 'gir_ffi'

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
