cask "irudiag" do
  version "1.1.0"
  sha256 "1387290df0476dfc8e907685ca762853049ac59979032582eeddb000103665c8"

  url "https://github.com/aardman/iruDiag/releases/download/v#{version}/IruDiag.pkg"
  name "IruDiag"
  desc "Menu bar diagnostics and maintenance tool for the Iru client agent"
  homepage "https://github.com/aardman/iruDiag"

  depends_on :macos

  pkg "IruDiag.pkg"

  uninstall quit:    "org.aardman.IruDiag",
            pkgutil: "org.aardman.IruDiag.pkg",
            delete:  [
              "/Applications/IruDiag.app",
              "/etc/sudoers.d/iru-diag",
            ]
end
