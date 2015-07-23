class GobjectIntrospection < Formula
  desc "Generate interface introspection data for GObject libraries"
  homepage "https://live.gnome.org/GObjectIntrospection"
  url "https://download.gnome.org/sources/gobject-introspection/1.44/gobject-introspection-1.44.0.tar.xz"
  sha256 "6f0c2c28aeaa37b5037acbf21558098c4f95029b666db755d3a12c2f1e1627ad"

  head do
    url "https://github.com/GNOME/gobject-introspection.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  depends_on "pkg-config" => :run
  depends_on "glib"
  depends_on "libffi"

  resource "tutorial" do
    url "https://gist.github.com/7a0023656ccfe309337a.git",
        :revision => "499ac89f8a9ad17d250e907f74912159ea216416"
  end

  def patches
    DATA
  end

  def install
    system "./autogen.sh" if build.head?

    ENV["GI_SCANNER_DISABLE_CACHE"] = "true"
    ENV.universal_binary if build.universal?
    inreplace "giscanner/transformer.py", "/usr/share", "#{HOMEBREW_PREFIX}/share"
    inreplace "configure" do |s|
      s.change_make_var! "GOBJECT_INTROSPECTION_LIBDIR", "#{HOMEBREW_PREFIX}/lib"
    end

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libffi"].opt_lib/"pkgconfig"
    resource("tutorial").stage testpath
    system "make"
    assert (testpath/"Tut-0.1.typelib").exist?
  end
end

__END__

diff --git a/giscanner/scannerlexer.l b/giscanner/scannerlexer.l
index 835b92c..78e2bbd 100644
--- a/giscanner/scannerlexer.l
+++ b/giscanner/scannerlexer.l
@@ -165,6 +165,7 @@ stringtext				([^\\\"])|(\\.)
 "__inline"				{ return INLINE; }
 "__nonnull" 			        { if (!parse_ignored_macro()) REJECT; }
 "_Noreturn" 			        { /* Ignore */ }
+"__signed"				{ return SIGNED; }
 "__signed__"				{ return SIGNED; }
 "__restrict"				{ return RESTRICT; }
 "__restrict__"				{ return RESTRICT; }
