{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    acceleration = "rocm";

    # Listen on loopback only. OpenCode runs on the same host.
    host = "127.0.0.1";
    port = 11434;

    # Pre-pull models on activation so they survive rebuilds.
    loadModels = [
      "qwen3-coder:30b"
      "qwen2.5-coder:14b"
    ];

    environmentVariables = {
      # 7700 XT (gfx1101) -> use the 7900 (gfx1100) codepath
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";

      # Keep models warm so OpenCode does not eat a cold-start every prompt
      OLLAMA_KEEP_ALIVE = "30m";

      # Allow up to 2 concurrent requests, useful if Zed and a TUI both poke at it
      OLLAMA_NUM_PARALLEL = "2";

      # Bigger default context. Coding agents burn through tokens fast.
      OLLAMA_CONTEXT_LENGTH = "32768";

      # Flash attention helps throughput on RDNA3
      OLLAMA_FLASH_ATTENTION = "1";
    };
  };

  # ROCm userspace bits the Ollama service needs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Make sure your user is in the render group for /dev/kfd and /dev/dri
  users.users.ellen.extraGroups = [
    "render"
    "video"
  ];
}
