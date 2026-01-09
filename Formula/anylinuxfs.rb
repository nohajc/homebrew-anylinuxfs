class Anylinuxfs < Formula
  VERSION = "0.9.3".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "fdf5250712ae5c7bf712ae857054c41898ae294b4ac08ad258ae8061080d59b7"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_tahoe:   "b08b1b3ef3d9c6ea2396ff5af661fb8cd4675d7729cadbb184c9a02993fd9ea4"
    sha256 cellar: :any, arm64_sequoia: "eb5bba17943e4c60d26a3fcfa56ed0b7f0d93d5d71f66a8276a1ea0495c7a28a"
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
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62/linux-aarch64-Image-v6.12.62-anylinuxfs.tar.gz"
    sha256 "48038f83a41e7e57ec0444e8496fda7de5e4fb0525795c3deaa7df67b966de0d"
  end

  resource "linux-modules" do
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.62/modules.squashfs"
    sha256 "2f5a6c4a78ed953b4ac30abe093dc9f3ba901ee2deff5fe3384945f29cc95587"
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
      libexec.install "Image"
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
