{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # cli stuff
    qmk

    # Ansible with hvac support
    (python3.withPackages (
      ps: with ps; [
        ansible-core
        hvac
        cryptography
        jinja2
      ]
    ))

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
      ps.framed # Shaded environment behind highlighted code blocks
      ps.fvextra # breaklines/breakanywhere so code wraps instead of overflowing
      ps.tcolorbox # rounded, page-breakable code boxes
      # tcolorbox's dependency closure is NOT pulled in automatically here:
      ps.tikzfill
      ps.pdfcol # needed by tcolorbox's `breakable` library
      ps.environ
      ps.trimspaces
      ps.pgf
      ps.titlesec # heading spacing
      ps.needspace # keeps headings from being orphaned at a page break
      ps.xurl # long URLs break instead of running off the margin
      ps.newunicodechar # per-glyph font fallback (arrows, box drawing, symbols)
    ]))
    ghostscript_headless
    poppler-utils # pdftoppm/pdftotext - PDF QA (render pages, check overflow)
  ];
}
