# SJSD Data Pipeline - Scheduled Tasks
# Runs the ETL pipeline every weekday at 5:00 PM
{ config, lib, pkgs, ... }:

{
  # Systemd service for SJSD data pipeline
  systemd.services.sjsd-data-pipeline = {
    description = "SJSD Data Pipeline - Student Assessment ETL";
    serviceConfig = {
      Type = "oneshot";
      User = "jwinget";
      Group = "users";
      WorkingDirectory = "/home/jwinget/Desktop/sjsd_data_pipeline";

      # Run the pipeline with cleanup and email notifications
      # Use full path to nix-shell from the nix package
      ExecStart = "${pkgs.bash}/bin/bash -c 'cd /home/jwinget/Desktop/sjsd_data_pipeline && ${pkgs.nix}/bin/nix-shell --run \"python main.py --cleanup --notify\"'";

      # Set up environment for nix commands
      Environment = [
        "PATH=/run/current-system/sw/bin:/usr/bin:/bin"
        "NIX_PATH=nixpkgs=${pkgs.path}"
      ];

      # Logging
      StandardOutput = "journal";
      StandardError = "journal";

      # Security settings
      PrivateTmp = true;
      NoNewPrivileges = true;
    };

    # Don't start on boot, only via timer
    wantedBy = [ ];
  };

  # Systemd timer for scheduling (weekdays at 5:00 PM)
  systemd.timers.sjsd-data-pipeline = {
    description = "Timer for SJSD Data Pipeline";
    wantedBy = [ "timers.target" ];

    timerConfig = {
      # Run every weekday (Monday-Friday) at 5:00 PM Mountain Time
      OnCalendar = "Mon,Tue,Wed,Thu,Fri *-*-* 17:00:00";

      # If the system was off when the timer should have run, run it on next boot
      Persistent = true;

      # Timezone
      # Note: System timezone is set to America/Denver in configuration.nix
    };
  };

  # Optional: Enable cron for traditional cron job support (if needed for other tasks)
  # services.cron.enable = true;
}
