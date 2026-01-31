class Anylinuxfs < Formula
  VERSION = "0.10.3".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "6f07e8a16779b8b7e219615beecf15c08aed44454206681e909ef891c1034dcf"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_tahoe:   "22d005097e1c257470361087044e46b7a493a68bddd8e60469f0a3cd6a7607d3"
    sha256 cellar: :any, arm64_sequoia: "9c4dee179dd4db186e434c4ae26678730e095c40cff44621431f65e3e7e66bcd"
  end

  depends_on "go" => :build
  depends_on "lld" => :build
  depends_on "make" => :build
  depends_on "pkgconf" => :build
  depends_on "rustup" => :build

  # libkrun only supports Hypervisor.framework on arm64
  depends_on arch: :arm64
  depends_on :macos
  depends_on "slp/krun/libkrun"
  depends_on "util-linux"

  resource "gvproxy" do
    url "https://github.com/containers/gvisor-tap-vsock/archive/refs/tags/v0.8.7.tar.gz"
    sha256 "ef9765d24bc3339014dd4a8f2e2224f039823278c249fb9bd1416ba8bbab590b"
  end

  resource "linux-image" do
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62-rev1/linux-aarch64-Images-v6.12.62-anylinuxfs.tar.gz"
    sha256 "1de75a3d4ef2eccd41df10f2eac8435dbaba52371fa42b0b0384fd9cf9a1f3ce"
  end

  resource "linux-modules" do
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62-rev1/modules.squashfs"
    sha256 "86ed485e4e46ba265261a55e25c92ea15f6118003fcec95a8bafde8ad39f697f"
  end

  resource "libkrun-init-bsd" do
    url "https://github.com/nohajc/libkrun/archive/refs/tags/v1.17.0-init-bsd.tar.gz"
    sha256 "a5e2ea3e82f80e1a83b67de2916065b12ec489c59e1e11bcd1689c4607269c90"
  end

  def install
    system "rustup", "default", "stable"
    system "rustup", "target", "add", "aarch64-unknown-linux-musl"
    system "rustup", "+nightly-2026-01-25", "component", "add", "rust-src"
    system "./build-app.sh", "--release"
    system "./install.sh", prefix

    etc.install "etc/anylinuxfs.toml" => "anylinuxfs.toml"

    resource("gvproxy").stage do
      system "gmake", "gvproxy"
      libexec.install "bin/gvproxy"
    end

    resource("linux-image").stage do
      chmod 0644, "Image"
      chmod 0644, "Image-4K"
      libexec.install "Image"
      libexec.install "Image-4K"
    end

    resource("linux-modules").stage do
      chmod 0644, "modules.squashfs"
      lib.install "modules.squashfs"
    end

    resource("libkrun-init-bsd").stage do
      system "gmake BUILD_BSD_INIT=1 -- init/init-freebsd"
      libexec.install "init/init-freebsd"
    end

    post_install
  end

  def post_install
    system "#{bin}/anylinuxfs", "upgrade-config", "#{etc}/anylinuxfs.toml", "-o", "#{etc}/anylinuxfs.toml"
  end

  test do
    system "true"
  end
end
