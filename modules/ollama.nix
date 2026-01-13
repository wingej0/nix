{ config, pkgs, username, ... }:
{
  # Install ollama CLI tools
  environment.systemPackages = with pkgs; [
    ollama
  ];

  # Enable ollama service
  services.ollama = {
    enable = true;

    # Use CUDA-enabled package for NVIDIA GPU acceleration
    package = pkgs.ollama-cuda;

    # Listen on all interfaces to allow access from other machines
    host = "0.0.0.0";

    # Default port is 11434
    port = 11434;

    # Configure models directory
    models = "/var/lib/ollama/models";
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
