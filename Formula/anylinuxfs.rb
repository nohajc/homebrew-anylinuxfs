class Anylinuxfs < Formula
  desc "Mount any linux-supported filesystem read/write using nfs and a microVM"
  homepage "https://github.com/nohajc/anylinuxfs"
  url "https://github.com/nohajc/anylinuxfs/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "60a946c0acca232fa34218c8a4b82a1482e5a0467a1398c8e4c1a84fe457977f"
  license "GPL-3.0-or-later"

  # bottle do
  #   root_url "https://raw.githubusercontent.com/nohajc/homebrew-anylinuxfs/master/bottles"
  #   sha256 cellar: :any, arm64_sequoia: "2eedc8025c4253c29e60be3c21637720f6bb9e2789667880bc012c437a920d93"
  # end

  depends_on "go" => :build
  depends_on "messense/macos-cross-toolchains/aarch64-unknown-linux-musl" => :build
  depends_on "pkgconf" => :build
  depends_on "rustup" => :build
  # Upstream only supports Hypervisor.framework on arm64
  depends_on arch: :arm64
  depends_on "slp/krun/libkrun"
  depends_on "util-linux"

  # Additional dependency
  # resource "" do
  #   url ""
  #   sha256 ""
  # end

  def install
    system "rustup", "default", "stable"
    # system "rustup", "target", "add", "aarch64-apple-darwin"
    system "rustup", "target", "add", "aarch64-unknown-linux-musl"
    system "./build-app.sh", "--release"
    system "./install.sh", prefix
  end

  test do
    system "true"
  end
end
