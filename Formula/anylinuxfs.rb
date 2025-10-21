class Anylinuxfs < Formula
  VERSION = "0.8.1".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "8c9847db3f428af8a9a7f557d0a03adb75d1d40ad87c2c8ac2ce5e4410156ca4"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_tahoe:   "8c402b6381aa2246097d38102ff0a2ee74912a2a54cd9ba66043651737fd311e"
    sha256 cellar: :any, arm64_sequoia: "03639fa353a48c9b0433589295f52006711a96bbb7fcdb949cc6cbe3369fecc9"
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

  def install
    system "rustup", "default", "stable"
    system "rustup", "target", "add", "aarch64-unknown-linux-musl"
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
  end

  test do
    system "true"
  end
end
