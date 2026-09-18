cask "irudiag" do
  version "1.0.0"
  sha256 "0bbd4956838c060b64a3ba86acbe54122f936102afdd5185c9ff3b7de70c41cd"

  url "https://github.com/aardman/iruDiag/releases/download/v#{version}/IruDiag.pkg"
  name "IruDiag"
  desc "Menu bar diagnostics and maintenance tool for the Iru client agent"
  homepage "https://github.com/aardman/iruDiag"

  pkg "IruDiag.pkg"

  uninstall quit:    "org.aardman.IruDiag",
            pkgutil: "org.aardman.IruDiag.pkg",
            delete:  [
              "/Applications/IruDiag.app",
              "/etc/sudoers.d/iru-diag",
            ]
end
