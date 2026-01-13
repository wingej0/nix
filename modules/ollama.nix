{ config, pkgs, username, ... }:
{
  # Install ollama CLI tools
  environment.systemPackages = with pkgs; [
    ollama
  ];

  # Enable ollama service
  services.ollama = {
    enable = true;

    # Enable GPU acceleration (NVIDIA CUDA support)
    acceleration = "cuda";

    # Listen on all interfaces to allow access from other machines
    host = "0.0.0.0";

    # Default port is 11434
    port = 11434;

    # Configure models directory
    models = "/var/lib/ollama/models";

    # Additional environment variables for GPU support
    environmentVariables = {
      # Use CUDA for acceleration
      OLLAMA_USE_GPU = "1";
      # Set compute capability (adjust if needed for your GPU)
      OLLAMA_CUDA_COMPUTE = "8.6";
    };
  };

  # Persist ollama data (models can be large)
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/ollama"
    ];
    users.${username} = {
      directories = [
        ".ollama"
      ];
    };
  };

  # Open Ollama port in firewall
  networking.firewall.allowedTCPPorts = [ 11434 ];
}
