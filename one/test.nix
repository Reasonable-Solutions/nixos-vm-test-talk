{
  # The name of the test
  name = "Let's have several machines";

  # We can have many nodes
  nodes = {
    # These attrs are hostnames
    machine1 = { pkgs, ... }: { };
    machine2 = { pkgs, ... }: { };
  };

  testScript = ''
    # The hostnames above exist in the hostfiles on the machines, conveniently
    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    machine1.succeed("ping -c 1 machine2")
    machine2.succeed("ping -c 1 machine1")
  '';
}
