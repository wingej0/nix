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

  # Disable DynamicUser to avoid conflicts with impermanence bind mounts
  # Remove the models path from ReadWritePaths since it doesn't exist at namespace setup time
  systemd.services.ollama = {
    preStart = ''
      mkdir -p /var/lib/ollama/models
    '';
    serviceConfig = {
      DynamicUser = pkgs.lib.mkForce false;
      User = "ollama";
      Group = "ollama";
      ReadWritePaths = pkgs.lib.mkForce [ "/var/lib/ollama" ];
    };
  };

  # Create ollama user and group
  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    home = "/var/lib/ollama";
    createHome = false;
  };
  users.groups.ollama = {};

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
