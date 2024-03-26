{ config, pkgs, lib, ... }:
let
  cfg = config.services.echo;
  echo = pkgs.buildGoModule {
    src = ../service;
    name = "echo";
    vendorHash = null;
  };

in {
  options.services.echo = {
    enable = lib.mkEnableOption "http hello as a Service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8090;
      description = "Port to listen on, default 8090";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.echo = {
      description = "Friendly http Echo as a Service Daemon";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.ExecStart = "${echo}/bin/echo-go";
    };
  };
}
