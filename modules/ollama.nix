{ config, pkgs, ... }:
{
    services.ollama = {
        enable = true;
        acceleration = "cuda";
        loadModels = [
            "deepseek-r1"
            "codellama"
            "mistral"
            "phi4"
        ];
    };

    services.open-webui.enable = true;
}
