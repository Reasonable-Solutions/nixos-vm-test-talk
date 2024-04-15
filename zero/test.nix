# TODO: Build rust package

# TODO: An Oracle testing example - for service rewrites

# TODO: have things call each other in a v. polyglot mode. Service is Increase request number by one

{
  # The Name of the test
  name = "we can hello";

  # the machines in the test: none, one, or many
  nodes = {
    # This is a hostname
    myCoolTestMachine = { pkgs, ... }: { };

  };

  # The test script, in python
  # just normal python.
  testScript = ''
    def files():
       _, files = myCoolTestMachine.execute("ls | wc -l")
       return files

    myCoolTestMachine.start()
    myCoolTestMachine.wait_for_unit("default.target")

    myCoolTestMachine.shutdown()
    myCoolTestMachine.start()


    with subtest("Great success"):
      myCoolTestMachine.succeed("exit 0")

    with subtest("fails too"):
      myCoolTestMachine.fail("exit 2")

    print(files())
    stdout = files()
    assert stdout == '5\n' , f"got: {stdout}"
  '';
}
