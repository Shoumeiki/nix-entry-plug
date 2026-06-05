{ config, pkgs, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    dataDir = "${config.home.homeDirectory}/.local/share/mpd";

    extraConfig = ''
      audio_output {
        type    "pipewire"
        name    "PipeWire Output"
      }

      # FIFO output for ncmpcpp visualizer
      audio_output {
        type            "fifo"
        name            "Visualizer"
        path            "/tmp/mpd.fifo"
        format          "44100:16:2"
      }
    '';
  };

  programs.ncmpcpp = {
    enable = true;
    settings = {
      mpd_music_dir = "${config.home.homeDirectory}/Music";

      # Visualizer
      visualizer_data_source     = "/tmp/mpd.fifo";
      visualizer_output_name     = "Visualizer";
      visualizer_in_stereo       = "yes";
      visualizer_type            = "spectrum";
      visualizer_look            = "+|";
      visualizer_color           = "magenta,cyan,green,yellow,red";

      # UI
      user_interface             = "alternative";
      browser_display_mode       = "columns";
      search_engine_display_mode = "columns";
      playlist_display_mode      = "columns";

      # Behaviour
      follow_now_playing_lyrics  = "yes";
      lyrics_fetchers            = "genius,musixmatch";
      seek_time                  = 5;
      volume_change_step         = 5;
    };

    bindings = [
      { key = "j"; command = "scroll_down"; }
      { key = "k"; command = "scroll_up"; }
      { key = "J"; command = "move_sort_order_down"; }
      { key = "K"; command = "move_sort_order_up"; }
      { key = "h"; command = "previous_column"; }
      { key = "l"; command = "next_column"; }
      { key = "ctrl-f"; command = "page_down"; }
      { key = "ctrl-b"; command = "page_up"; }
    ];
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture  # PipeWire audio source
      obs-vaapi                   # AMD hardware encode via VAAPI
    ];
  };

  home.packages = with pkgs; [
    tenacity
  ];
}
