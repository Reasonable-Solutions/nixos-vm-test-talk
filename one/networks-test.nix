{
  name = "Let's have several machines, on several networks";

  nodes = {
    machine1 = { pkgs, ... }: { };
    machine2 = { pkgs, ... }: { };
  };

  testScript = ''
    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    machine1.succeed("ping -c 1 machine2")
    machine2.succeed("ping -c 1 machine1")
  '';
}
