class Anylinuxfs < Formula
  VERSION = "0.7.0".freeze

  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v#{VERSION}.tar.gz"
  sha256 "294f2e297cf2d90290c9a47edaa3a701c4a801378106792ac078586963606f0b"
  license "GPL-3.0-or-later"

  bottle do
    root_url "https://github.com/nohajc/homebrew-anylinuxfs/releases/download/v#{VERSION}"
    sha256 cellar: :any, arm64_tahoe:   "f80e873b60808be3616a333061a0b8393fac12a22e5e6c5083b2245e53d39b69"
    sha256 cellar: :any, arm64_sequoia: "42b54f44c75f05fd5d625b912acaf58472fe7f16991cecbd9ef413742e76d737"
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
    url "https://github.com/nohajc/libkrunfw/releases/download/v6.12.34-rev3/linux-aarch64-Image-v6.12.34-anylinuxfs.tar.gz"
    sha256 "a09654323087182813312a524e23b6e59335dd1082dc73e38d440c5d287b47be"
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
