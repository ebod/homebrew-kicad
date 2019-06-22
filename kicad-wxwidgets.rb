class KicadWxwidgets < Formula
  desc "Custom patched version of wxwidgets, only for use by KiCad."
  homepage "https://kicad-pcb.org"
  url "https://github.com/KiCad/wxWidgets/archive/kicad/macos-wx-3.0.zip"
  sha256 "56f49449849b9cae15e44ed4d57c9f7c088767d2e503e9c1b9aa83edf698b3aa"
  head "https://github.com/KiCad/wxWidgets.git", :branch => "kicad/macos-wx-3.0"
  keg_only "custom patched version of wxWidgets, only for use by KiCad"


  depends_on "cairo"
  depends_on "swig" => :build
  depends_on "pkg-config" => :build
  depends_on "pcre"
  depends_on "glew"

  fails_with :gcc

  def install
    if MacOS.version > :sierra
      ENV.append "CPPFLAGS", "-D__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES=1"
    end

    mkdir "wx-build" do
      ENV["ARCHFLAGS"] = "-Wunused-command-line-argument-hard-error-in-future"
      ENV.append "LDFLAGS", "-headerpad_max_install_names"
      ENV["MAC_OS_X_VERSION_MIN_REQUIRED"] = MacOS.version
      if MacOS.version < :mavericks
        ENV.libstdcxx
      else
        ENV.libcxx
      end

      args = [
        "--prefix=#{prefix}",
        "--with-opengl",
        "--enable-aui",
        "--enable-utf8",
        "--enable-html",
        "--enable-stl",
        "--with-libjpeg=builtin",
        "--with-libpng=builtin",
        "--with-regex=builtin",
        "--with-libtiff=builtin",
        "--with-zlib=builtin",
        "--with-expat=builtin",
        "--without-liblzma",
        "--with-macosx-version-min=#{MacOS.version}",
      ]

      args << "CC=#{ENV.cc}"
      args << "CXX=#{ENV.cxx}"
      args << "--enable-universal_binary=i386,x86_64"

      system "../configure", *args
      system "make", "-j#{ENV.make_jobs}"
      system "make", "install"
    end

    include.install_symlink include/"wx-3.0"/"wx"
    (prefix/"wx-build").install Dir["wx-build/*"]
  end

  test do
    1 # FIXME pls
  end
end
