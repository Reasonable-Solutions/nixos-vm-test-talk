{
  name = "we can hello";

  nodes = {
    myCoolTestMachine = { pkgs, ... }: { };

  };

  testScript = ''
    myCoolTestMachine.succeed("exit 1")
  '';
}
