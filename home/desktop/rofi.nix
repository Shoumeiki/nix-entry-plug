{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
  font = config.stylix.fonts.sansSerif.name;
  # Double Stylix's application font size (default 12 → 24pt).
  fontSize = config.stylix.fonts.sizes.applications * 2;

  # Full rasi theme using the Stylix palette. Written as a store path so the
  # exact content is reproducible and home-manager can point rofi straight at it.
  theme = pkgs.writeText "rofi-theme.rasi" ''
    * {
      background-color: transparent;
      text-color:       ${c.base05};
    }

    window {
      background-color: ${c.base00};
      border:           2px solid;
      border-color:     ${c.base0D};
      border-radius:    18px;
      width:            640px;
      padding:          18px;
      location:         center;
      anchor:           center;
    }

    mainbox {
      background-color: transparent;
      children:         [ inputbar, listview ];
      spacing:          12px;
    }

    /* ── Search bar ─────────────────────────────────────────────────────── */
    inputbar {
      background-color: ${c.base01};
      border-radius:    999px;
      padding:          10px 20px;
      children:         [ entry ];
    }

    entry {
      background-color:  transparent;
      text-color:        ${c.base05};
      placeholder:       "  Search…";
      placeholder-color: ${c.base03};
    }

    /* ── Results list ───────────────────────────────────────────────────── */
    listview {
      background-color: transparent;
      lines:            8;
      columns:          1;
      fixed-height:     false;
      spacing:          4px;
    }

    element {
      background-color: transparent;
      border-radius:    10px;
      padding:          10px 16px;
      orientation:      horizontal;
      spacing:          12px;
    }

    element selected {
      background-color: ${c.base01};
      text-color:       ${c.base0D};
    }

    element-icon {
      background-color: transparent;
      size:             1.5em;
      vertical-align:   0.5;
    }

    element-text {
      background-color: transparent;
      text-color:       inherit;
      vertical-align:   0.5;
      expand:           true;
    }

    /* ── Scrollbar ──────────────────────────────────────────────────────── */
    scrollbar {
      background-color: ${c.base01};
      handle-color:     ${c.base03};
      handle-width:     4px;
      border-radius:    2px;
      width:            4px;
      margin:           0 0 0 4px;
    }
  '';
in
{
  # Stylix's rofi target is disabled so we own the full theme.
  stylix.targets.rofi.enable = false;

  programs.rofi = {
    enable = true;
    # Double the Stylix application font size.
    font = "${font} ${toString fontSize}";
    theme = "${theme}";

    extraConfig = {
      modi = "drun,run,filebrowser";
      show-icons = true;
      drun-display-format = "{name}";
      kb-cancel = "Escape,Super+d";
      # Remove the mode label from the search box (user sees only the placeholder).
      display-drun = "";
      display-run = "";
      display-filebrowser = "";
      location = 0; # centre of screen
    };
  };
}
