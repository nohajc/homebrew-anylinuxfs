class Anylinuxfs < Formula
  VERSION = "0.3.0".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "09b5274e312e5706db8e1de8f961f16e36f3a03eda442aab8267ff1eb0dcdd46"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_sequoia: "477e46e36a8a74467252bd3ab4c2ebeebde522d95c96cdf092dcda9e6dfc48ee"
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
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.34/linux-aarch64-Image-v6.12.34-anylinuxfs.tar.gz"
    sha256 "9d75ae8b8f1866643ffa0261fb097d343dd8586395ffb5e76d1a7b54cd7b606b"
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
