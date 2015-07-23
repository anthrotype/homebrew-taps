class Harfbuzz < Formula
  desc "OpenType text shaping engine"
  homepage "https://wiki.freedesktop.org/www/Software/HarfBuzz/"
  url "http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-0.9.41.tar.bz2"
  sha256 "d81aa53d0c02b437beeaac159d7fc16394d676bbce0860fb6f6a10b587dc057c"

  head do
    url "https://github.com/behdad/harfbuzz.git"

    depends_on "ragel" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "cairo"
  depends_on "icu4c" => :recommended
  depends_on "graphite2" => :optional
  depends_on "freetype"
  depends_on "anthrotype/taps/gobject-introspection"

  option "with-coretext", "Compile with CoreText bindings"

  resource "ttf" do
    url "https://github.com/behdad/harfbuzz/raw/fc0daafab0336b847ac14682e581a8838f36a0bf/test/shaping/fonts/sha1sum/270b89df543a7e48e206a2d830c0e10e5265c630.ttf"
    sha256 "9535d35dab9e002963eef56757c46881f6b3d3b27db24eefcc80929781856c77"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-introspection=yes
      --with-gobject=yes
    ]

    if build.head?
      system "./autogen.sh"
    end

    args << "--with-icu" if build.with? "icu4c"
    args << "--with-graphite2" if build.with? "graphite2"
    args << "--with-coretext" if build.with? "coretext"
    system "./configure", *args
    system "make", "install"
  end

  test do
    resource("ttf").stage do
      shape = `echo 'സ്റ്റ്' | #{bin}/hb-shape 270b89df543a7e48e206a2d830c0e10e5265c630.ttf`.chomp
      assert_equal "[glyph201=0+1183|U0D4D=0+0]", shape
    end
  end
end
