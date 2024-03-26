{
  # The Name of the test
  name = "we can hello";

  # the machines in the test: none, one, or many
  nodes = {
    # This is a hostname
    myCoolTestMachine = { pkgs, ... }: { };

  };

  # The test script, in python
  testScript = ''
    myCoolTestMachine.succeed("exit 1")
  '';
}
