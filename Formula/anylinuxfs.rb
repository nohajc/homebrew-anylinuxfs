class Anylinuxfs < Formula
  VERSION = "0.21.1".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "74248385ed1b2ef36abc42849b9dd6fb4b7494f2ea1b6c2a4e8ed757e8c358f6"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_golden_gate: "1eafb2db48298b996b0e6b020c21eae0a264f9d37b18a1e0e41349b7b430ea09"
    sha256 cellar: :any, arm64_tahoe:       "c47d10abca00d04cb486afb77545a5d0de85ae797488e3675c438bbcf32467c5"
    sha256 cellar: :any, arm64_sequoia:     "dbaf0aa83acc737b2b24f1ae1653ffafe565d91b36f6fd015f6c7c597cef357b"
  end

  depends_on "go" => :build
  depends_on "lld" => :build
  depends_on "llvm" => :build
  depends_on "make" => :build
  depends_on "pkgconf" => :build
  depends_on "rustup" => :build
  depends_on "xz" => :build

  # libkrun only supports Hypervisor.framework on arm64
  depends_on arch: :arm64
  depends_on :macos
  depends_on "util-linux"

  resource "gvproxy" do
    url "https://github.com/containers/gvisor-tap-vsock/archive/refs/tags/v0.8.9.tar.gz"
    sha256 "6cbcb7959a5d90b59253ea6d8bdf0285e2cfbc3b301398704b41e3069293f4fb"
  end

  resource "vmnet-helper" do
    url "https://github.com/nirs/vmnet-helper/releases/download/v0.12.0/vmnet-helper.tar.gz"
    sha256 "0f123c29565e36278aca57e13917d3a7db098e8c1552389f9332331c9dfc6381"
  end

  resource "linux-image" do
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62-rev2/linux-aarch64-Images-v6.12.62-anylinuxfs.tar.gz"
    sha256 "2ec37a1eca080fc0ad27b340764787007f2b06eca80e07d4eca1ae9f801e0834"
  end

  resource "linux-modules" do
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62-rev2/modules.squashfs"
    sha256 "037eddf6df5c3ade201838bb4e5a52c6ac2198bac95c88392251d3903cbaefc3"
  end

  resource "libkrun-init-bsd" do
    url "https://github.com/nohajc/libkrun/archive/refs/tags/v1.17.0-init-bsd-r1.tar.gz"
    sha256 "b6c96760dbd0e9760d2e6c469ead98a060c9f6f92708f8cb47c68fb7c2fec1d3"
  end

  def install
    system "rustup", "default", "stable"
    system "rustup", "target", "add", "aarch64-unknown-linux-musl"
    system "rustup", "+nightly-2026-01-25", "component", "add", "rust-src"
    system "./build-app.sh", "--release"
    system "./install.sh", prefix

    etc.install "etc/anylinuxfs.toml" => "anylinuxfs.toml"

    (share/"alpine").install "share/alpine/rootfs.ver"
    (share/"freebsd").install "share/freebsd/rootfs.ver"

    resource("gvproxy").stage do
      system "gmake", "gvproxy"
      libexec.install "bin/gvproxy"
    end

    resource("vmnet-helper").stage do
      libexec.install "vmnet-helper/bin/vmnet-helper"
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
      system "sed -I '' 's_/usr/bin/clang_/opt/homebrew/opt/llvm/bin/clang_' Makefile"
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
