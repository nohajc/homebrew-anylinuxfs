class Anylinuxfs < Formula
  VERSION = "0.9.4".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "a62a6d2b6eee9ae57706bdb1afad299f72bb18ef87ba9acd9c4739beac9f501b"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_tahoe:   "d2a427dc59e0830fe45a704d9690e9578a977d12acfcbe5596a7cec566ec508e"
    sha256 cellar: :any, arm64_sequoia: "188eec6850200ac363a193f0a4b5308f08c2fa1413a5d49f73eae4b0a032dce5"
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

  # resource "libkrun-init-bsd" do
  #   url "https://github.com/nohajc/libkrun/archive/refs/tags/v1.16.0-init-bsd.tar.gz"
  #   sha256 "b9dc2e0e95afbb8eb78647043bd9afe90bbbb82da06a0252053a9e7456be7289"
  # end

  def install
    system "rustup", "default", "stable"
    system "rustup", "target", "add", "aarch64-unknown-linux-musl"
    # system "rustup", "+nightly", "component", "add", "rust-src"
    system "./build-app.sh", "--release"
    system "./install.sh", prefix

    etc.install "etc/anylinuxfs.toml" => "anylinuxfs.toml"
    # share.install "etc/anylinuxfs.toml" => "anylinuxfs.default.toml"

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

    # resource("libkrun-init-bsd").stage do
    #   system "./build_freebsd_init.sh"
    #   libexec.install "init/init-freebsd"
    # end

    post_install
  end

  def post_install
    system "#{bin}/anylinuxfs", "upgrade-config", "#{etc}/anylinuxfs.toml", "-o", "#{etc}/anylinuxfs.toml"
  end

  test do
    system "true"
  end
end
