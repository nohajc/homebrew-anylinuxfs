class Anylinuxfs < Formula
  VERSION = "0.2.1".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "e875a65cf6a98315308f3594f304216830d3ca6c8e8ecd23910903e66502d424"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_sequoia: "12eabc61bb982631934dd7f542c681d13520a18507149ccfb1008775350b6aeb"
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
    url "https://github.com/containers/gvisor-tap-vsock/archive/refs/tags/v0.8.6.tar.gz"
    sha256 "eb08309d452823ca7e309da2f58c031bb42bb1b1f2f0bf09ca98b299e326b215"
  end

  resource "linux-image" do
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.6-nfs-lvm/linux-aarch64-Image-v6.6-nfs-lvm.tar.gz"
    sha256 "d85fbc29162c601ef55cec52dda3c168780608c7a6536ee434e070f875102310"
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
