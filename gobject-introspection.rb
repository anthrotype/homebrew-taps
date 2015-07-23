class GobjectIntrospection < Formula
  desc "Generate interface introspection data for GObject libraries"
  homepage "https://live.gnome.org/GObjectIntrospection"
  url "http://download.gnome.org/sources/gobject-introspection/1.45/gobject-introspection-1.45.3.tar.xz"
  sha256 "3583c3ae5fb70065d7ad2942564974fdbd86ac8a28e9bfae4e4d558f7656556e"

  head do
    url "https://github.com/GNOME/gobject-introspection.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal

  depends_on "pkg-config" => :run
  depends_on "anthrotype/taps/glib"
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
