class Anylinuxfs < Formula
  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "60a946c0acca232fa34218c8a4b82a1482e5a0467a1398c8e4c1a84fe457977f"
  license "GPL-3.0-or-later"

  # bottle do
  #   root_url "https://raw.githubusercontent.com/nohajc/homebrew-anylinuxfs/master/bottles"
  #   sha256 cellar: :any, arm64_sequoia: "2eedc8025c4253c29e60be3c21637720f6bb9e2789667880bc012c437a920d93"
  # end

  depends_on "go" => :build
  depends_on "make" => :build
  depends_on "messense/macos-cross-toolchains/aarch64-unknown-linux-musl" => :build
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
      libexec.install "Image"
    end
  end

  test do
    system "true"
  end
end
