{
  # The test names have to be less than 108 bytes or so.
  name = "less than 107 bytes";

  nodes = {
    machine1 = { pkgs, ... }: {
      networking = {
        interfaces.eth0.ipv4.addresses = [{
          address = "192.168.2.1";
          prefixLength = 24;
        }];
      };

    };
    machine2 = { pkgs, ... }: {
      # Bigger machine goes faster!
      virtualisation = {
        cores = 2;
        memorySize = 1024;
        diskSize = 4096;
      };
      networking = {
        interfaces.eth0.ipv4.addresses = [{
          address = "192.168.1.1";
          prefixLength = 24;
        }];
      };
    };
  };

  testScript = ''
    machine1.wait_for_unit("network-online.target")
    machine2.wait_for_unit("network-online.target")

    machine1.fail("ping -Ieth0 -c1 machine2")
    machine2.succeed("ping -Ieth0 -c1 machine1") # This too should fail wtf.?
  '';
}
