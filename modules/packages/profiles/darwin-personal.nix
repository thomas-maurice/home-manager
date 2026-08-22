{ config, pkgs, ... }:
let
  # Override Python to always use OpenSSL instead of LibreSSL on macOS
  python3 = pkgs.python3.override {
    openssl = pkgs.openssl;
  };

  # Helper function to create Python environments with OpenSSL support
  pythonWithPackages = packages: python3.withPackages packages;
in
{
  home.packages = with pkgs; [
    # cli stuff
    qmk

    # Ansible with hvac support
    (pythonWithPackages (
      ps: with ps; [
        ansible-core
        hvac
        cryptography
        jinja2
      ]
    ))

    # You can add more Python environments like this:
    # (pythonWithPackages (ps: with ps; [ requests boto3 ]))
    # Or just standalone python3 with OpenSSL:
    # python3

    # tinygo
    tinygo

    # GUI stuff
    # bitwarden-desktop
    # discord
    # element-desktop
    # kicad
    # nextcloud-client
    # slack
    # spotify
    # virt-manager
    # vscode

    # LaTeX
    (texliveSmall.withPackages (ps: [
      # CV (~/git/CV, moderncv-based, French)
      ps.moderncv
      ps.babel-french
      ps.wrapfig
      ps.datenumber
      ps.lettre
      # pandoc -> xelatex PDF builds (md-to-pdf-pandoc skill header.tex).
      # texliveSmall lacks all of these; tlmgr cannot add them (nix store is
      # read-only, and --usermode refuses a 2025 -> 2026 cross-release update),
      # so they have to be combined into the derivation here.
      ps.framed          # Shaded environment behind highlighted code blocks
      ps.fvextra         # breaklines/breakanywhere so code wraps instead of overflowing
      ps.tcolorbox       # rounded, page-breakable code boxes
      ps.tikzfill        # required by tcolorbox
      ps.titlesec        # heading spacing
      ps.needspace       # keeps headings from being orphaned at a page break
      ps.xurl            # long URLs break instead of running off the margin
      ps.newunicodechar  # per-glyph font fallback (arrows, box drawing, symbols)
    ]))
    ghostscript_headless
    poppler_utils # pdftoppm/pdftotext - PDF QA (render pages, check overflow)
  ];
}
