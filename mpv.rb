# frozen_string_literal: true

class Mpv < Formula
  desc "Media player based on MPlayer and mplayer2"
  homepage "https://mpv.io"
  url "https://github.com/mpv-player/mpv/archive/v0.33.1.tar.gz"
  sha256 "100a116b9f23bdcda3a596e9f26be3a69f166a4f1d00910d1789b6571c46f3a9"
  license :cannot_represent
  head "https://github.com/mpv-player/mpv.git", branch: "master"

  bottle :unneeded

  depends_on "docutils" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.9" => :build
  depends_on xcode: :build

  depends_on "openssl@1.1"
  depends_on "lz4"
  depends_on "xz"
  depends_on "zstd"
  depends_on "pkg-config"
  depends_on "python@3.8"
  depends_on "libffi"
  depends_on "libpng"
  depends_on "freetype"
  depends_on "fontconfig"
  depends_on "pcre"
  depends_on "glib"
  depends_on "gmp"
  depends_on "libunistring"
  depends_on "libidn2"
  depends_on "nettle"
  depends_on "gettext"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "little-cms2"
  depends_on "libtasn1"
  depends_on "gnutls"
  depends_on "p11-kit"
  depends_on "rtmpdump"
  depends_on "sdl2"
  depends_on "libb2"
  depends_on "libbluray"
  depends_on "fribidi"
  depends_on "giflib"
  depends_on "graphite2"
  depends_on "harfbuzz"
  depends_on "x264"
  depends_on "x265"
  depends_on "docutils"
  depends_on "libarchive"
  depends_on "libass"
  depends_on "luajit"
  depends_on "mujs"
  depends_on "uchardet"
  depends_on "youtube-dl"
  depends_on "zimg"
  depends_on "openjpeg"
  depends_on "lame"
  depends_on "webp"
  depends_on "leptonica"
  depends_on "srt"
  depends_on "libogg"
  depends_on "speex"
  depends_on "tesseract"
  depends_on "xvid"
  depends_on "snappy"
  depends_on "libvorbis"
  depends_on "flac"
  depends_on "libsndfile"
  depends_on "libsamplerate"
  depends_on "rubberband"
  depends_on "opus"
  depends_on "opencore-amr"
  depends_on "libvpx"
  depends_on "libvidstab"
  depends_on "libsoxr"
  depends_on "frei0r"
  depends_on "aom"
  depends_on "theora"
  depends_on "dav1d"
  depends_on "rav1e"
  depends_on "ffmpeg"

  on_macos do
    depends_on "coreutils" => :recommended
    depends_on "dockutil" => :recommended
    depends_on "tag" => :recommended
    depends_on "trash" => :recommended
  end

  def install
    opts  = Hardware::CPU.arm? ? "-mcpu=native " : "-march=native -mtune=native "
    opts += "-Ofast -flto=thin -funroll-loops -fomit-frame-pointer "
    opts += "-ffunction-sections -fdata-sections -fstrict-vtable-pointers -fwhole-program-vtables "
    opts += "-fforce-emit-vtables " if MacOS.version >= :mojave
    ENV.append "CFLAGS",      opts
    ENV.append "CPPFLAGS",    opts
    ENV.append "CXXFLAGS",    opts
    ENV.append "OBJCFLAGS",   opts
    ENV.append "OBJCXXFLAGS", opts
    ENV.append "LDFLAGS",     opts + " -dead_strip"

    # LANG is unset by default on macOS and causes issues when calling getlocale
    # or getdefaultlocale in docutils. Force the default c/posix locale since
    # that's good enough for building the manpage.
    ENV["LC_ALL"] = "en_US.UTF-8"
    ENV["LANG"]   = "en_US.UTF-8"

    # libarchive is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["libarchive"].opt_lib/"pkgconfig"
    # luajit-openresty is keg-only
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["luajit-openresty"].opt_lib/"pkgconfig"

    args = %W[
      --prefix=#{prefix}
      --confdir=#{etc}/mpv
      --datadir=#{pkgshare}
      --docdir=#{doc}
      --mandir=#{man}
      --zshdir=#{zsh_completion}

      --disable-html-build
      --enable-libmpv-shared
    ]
    args << "--swift-flags=-O -wmo"

    system Formula["python@3.9"].opt_bin/"python3", "bootstrap.py"
    system Formula["python@3.9"].opt_bin/"python3", "waf", "configure", *args
    system Formula["python@3.9"].opt_bin/"python3", "waf", "install"
    system Formula["python@3.9"].opt_bin/"python3", "TOOLS/osxbundle.py", "build/mpv"
    prefix.install "build/mpv.app"
  end

  test do
    system bin/"mpv", "--ao=null", test_fixtures("test.wav")
    assert_match "vapoursynth", shell_output(bin/"mpv --vf=help")
  end
end
