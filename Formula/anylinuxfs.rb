class Anylinuxfs < Formula
  VERSION = "0.1.7".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "7fbd4eecffde99ed2d2266997a42d245cbca8c2fd0a1ffe6100ed2440122df68"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_sequoia: "cfba6ca9a21c5cd53894ba95367df29db498c2e854db421c898d69e4fe193567"
  end

  depends_on "filosottile/musl-cross/musl-cross" => :build
  depends_on "go" => :build
  depends_on "make" => :build
  depends_on "pkgconf" => :build
  depends_on "rustup" => :build

  # libkrun only supports Hypervisor.framework on arm64
  depends_on arch: :arm64
  depends_on :macos
  depends_on "slp/krun/libkrun"
  depends_on "util-linux"

  resource "gvproxy" do
    url "https://github.com/containers/gvisor-tap-vsock/archive/refs/tags/v0.8.5.tar.gz"
    sha256 "549dcb319fdd9813eba525bd67ad224a4b561211a940cbdc0e2c94bd2b59b9c9"
  end

  resource "linux-image" do
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.6-nfs/linux-aarch64-Image-v6.6-nfs.tar.gz"
    sha256 "fb660a9d1d9ab6c6a0b2e4b48a7777b5ddddc739a244a6f4e4551c8d62a93808"
  end

  def install
    system "rustup", "default", "stable"
    system "rustup", "target", "add", "aarch64-unknown-linux-musl"
    system "./build-app.sh", "--release"
    system "./install.sh", prefix

    resource("gvproxy").stage do
      system "gmake", "gvproxy"
      libexec.install "bin/gvproxy"
    end

    resource("linux-image").stage do
      chmod 0644, "Image"
      libexec.install "Image"
    end
  end

  test do
    system "true"
  end
end
