class Anylinuxfs < Formula
  VERSION = "0.5.0".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "82b0d331a2b21387faf0da239fd444cc2af4cbd8d8f1a1621e3cbe4f2031cc0f"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_sequoia: "a8d54e578261ee8f7642f3e38053cee7695032d96d8b0060eb1ac828745dad89"
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
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.34-rev1/linux-aarch64-Image-v6.12.34-anylinuxfs.tar.gz"
    sha256 "9d358a75765e32e596194427a0af23c15347255ad983fca30b41b975a460ff0f"
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
