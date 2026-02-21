class Anylinuxfs < Formula
  VERSION = "0.12.0".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "660d9a664939ddf5337890f4d328a00d9aef6739313524ee0f1d8f5b0db1f24f"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_tahoe:   "6050d5136ae16f5f29b05757a7dd2107e15d45bc3a6440be957c8eb57e11f391"
    sha256 cellar: :any, arm64_sequoia: "584542566bda1fc57e4a677eae72c429b778460f6a46a1b0b75017e1c0ce4f31"
  end

  depends_on "go" => :build
  depends_on "lld" => :build
  depends_on "llvm" => :build
  depends_on "make" => :build
  depends_on "pkgconf" => :build
  depends_on "rustup" => :build

  # libkrun only supports Hypervisor.framework on arm64
  depends_on arch: :arm64
  depends_on :macos
  depends_on "slp/krun/libkrun"
  depends_on "util-linux"

  resource "gvproxy" do
    url "https://github.com/containers/gvisor-tap-vsock/archive/refs/tags/v0.8.8.tar.gz"
    sha256 "4f7c4885225d71b21f6b547b94d92fc6da4a4fef9d382fdd19c8ea67f67be839"
  end

  resource "vmnet-helper" do
    url "https://github.com/nirs/vmnet-helper/releases/download/v0.9.0/vmnet-helper.tar.gz"
    sha256 "5c76413428a09ce45faf719f7fb2f621e9b3a0b103024837aecdb8319cdcf32c"
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
