class Anylinuxfs < Formula
  VERSION = "0.8.3".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "05ace73b8637453c87bdfe9af0d343acd61fcb32b07596e899275adc5c0d9850"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_tahoe:   "7047ede977567e31f882f53dbeb2c45fe9b3a3ec8743e909c2e5777b9ef0c601"
    sha256 cellar: :any, arm64_sequoia: "82e85157bbe8447224458b1cb7a2a3f5336d7e2a1b29b40a0dce655413a466c3"
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
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.34-rev4/linux-aarch64-Image-v6.12.34-anylinuxfs.tar.gz"
    sha256 "4c5d0d20141915c5cef9d6dddcdb066d34e6a8c9d337e7fa09ebf4b0e82d14fc"
  end

  resource "linux-modules" do
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.34-rev4/modules.squashfs"
    sha256 "89a9389230a007d45da1a62a8d65bb6b116284dddfa00d293445513113f67a0a"
  end

  resource "libkrun-init-bsd" do
    url "https://github.com/nohajc/libkrun/archive/refs/tags/v1.16.0-init-bsd.tar.gz"
    sha256 "b9dc2e0e95afbb8eb78647043bd9afe90bbbb82da06a0252053a9e7456be7289"
  end

  def install
    system "rustup", "default", "stable"
    system "rustup", "target", "add", "aarch64-unknown-linux-musl"
    system "rustup", "+nightly", "component", "add", "rust-src"
    system "./build-app.sh", "--release"
    system "./install.sh", prefix

    etc.install "etc/anylinuxfs.toml" => "anylinuxfs.toml"

    resource("gvproxy").stage do
      system "gmake", "gvproxy"
      libexec.install "bin/gvproxy"
    end

    resource("linux-image").stage do
      chmod 0644, "Image"
      libexec.install "Image"
    end

    resource("linux-modules").stage do
      chmod 0644, "modules.squashfs"
      lib.install "modules.squashfs"
    end

    resource("libkrun-init-bsd").stage do
      system "./build_freebsd_init.sh"
      libexec.install "init/init-freebsd"
    end
  end

  test do
    system "true"
  end
end
