class Harfbuzz < Formula
  desc "OpenType text shaping engine"
  homepage "https://wiki.freedesktop.org/www/Software/HarfBuzz/"
  url "http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.41.tar.bz2"
  sha256 "d81aa53d0c02b437beeaac159d7fc16394d676bbce0860fb6f6a10b587dc057c"

  bottle do
    sha256 "127226ca79eb2225b2e96a2919541466b4f93a7ead04dbbbf6b605ac2e7deb43" => :yosemite
    sha256 "0ee1b49cbb64c20dfd4ac5822a89e0e85168e249fe24ca7c35b8f8814899682c" => :mavericks
    sha256 "06116bc1ac3ac010211f2c56193e144b242ca4a45988f38637e215be3670e956" => :mountain_lion
  end

  head do
    url "https://github.com/anthrotype/harfbuzz.git"

    depends_on "ragel" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "anthrotype/taps/glib"
  depends_on "anthrotype/taps/cairo"
  depends_on "icu4c" => :recommended
  depends_on "graphite2" => :optional
  depends_on "freetype"
  depends_on "anthrotype/taps/gobject-introspection"

  option "with-coretext", "Compile with CoreText bindings"

  resource "ttf" do
    url "https://github.com/behdad/harfbuzz/raw/fc0daafab0336b847ac14682e581a8838f36a0bf/test/shaping/fonts/sha1sum/270b89df543a7e48e206a2d830c0e10e5265c630.ttf"
    sha256 "9535d35dab9e002963eef56757c46881f6b3d3b27db24eefcc80929781856c77"
  end

  def patches
    DATA
  end

  def install
    configure_args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-introspection=yes
      --with-gobject=yes
    ]

    make_args = %W[]

    if build.head?
      system "./autogen.sh"
      make_args << "CPPFLAGS+=-DHB_DEFINE_STDINT"
    end

    configure_args << "--with-icu" if build.with? "icu4c"
    configure_args << "--with-graphite2" if build.with? "graphite2"
    configure_args << "--with-coretext" if build.with? "coretext"
    system "./configure", *configure_args
    system "make", "install", *make_args
  end

  test do
    resource("ttf").stage do
      shape = `echo 'സ്റ്റ്' | #{bin}/hb-shape 270b89df543a7e48e206a2d830c0e10e5265c630.ttf`.chomp
      assert_equal "[glyph201=0+1183|U0D4D=0+0]", shape
    end
  end
end

__END__

diff --git a/src/hb-common.h b/src/hb-common.h
index d160be5..5eda2a9 100644
--- a/src/hb-common.h
+++ b/src/hb-common.h
@@ -61,6 +61,15 @@ typedef __int32 int32_t;
 typedef unsigned __int32 uint32_t;
 typedef __int64 int64_t;
 typedef unsigned __int64 uint64_t;
+#elif defined (HB_DEFINE_STDINT)
+typedef signed char int8_t;
+typedef unsigned char uint8_t;
+typedef short int16_t;
+typedef unsigned short uint16_t;
+typedef int int32_t;
+typedef unsigned uint32_t;
+typedef long long int64_t;
+typedef unsigned long long uint64_t;
 #else
 #  include <stdint.h>
 #endif
