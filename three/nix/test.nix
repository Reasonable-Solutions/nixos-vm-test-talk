{
  name = "Let's have several machines II";

  nodes = {
    server = { pkgs, config, ... }: {
      imports = [ ./module.nix ];
      services.echo.enable = true;
      networking.firewall.allowedTCPPorts = [ config.services.echo.port ];
    };
    client = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [ curl ];

    };
  };

  testScript = ''
    server.wait_for_unit("network-online.target")
    client.wait_for_unit("network-online.target")
    _, output = client.execute("curl server:8090/hello")
    assert output == "hello\n"
  '';
}
