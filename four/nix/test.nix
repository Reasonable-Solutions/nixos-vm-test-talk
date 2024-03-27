{
  name = "Netroll test ";

  nodes = {

    k8sNode = { pkgs, ... }:
      let
        netrollSrc = pkgs.fetchFromGitHub {
          owner = "nais";
          repo = "netroll";
          rev = "d5e9b505114e1d2ce8fd17ce45b29554ffe8921b";
          hash = "sha256-uBt/BVZf5N83YV8arrEtIk5d1F2gS6rwq5bANJC6RZo=";
        };

        netroll = pkgs.buildGoModule {
          name = "netroll";
          hash = "sha256-uBt/BVZf5N83YV8arrEtIk5d1F2gS6rwq5bANJC6RZo=";
          src = netrollSrc;
        };
      in {
        networking.firewall.allowedTCPPorts = [
          6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
          # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
          # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
        ];
        services.k3s.enable = true;
        services.k3s.role = "server";
        services.k3s.extraFlags = toString [
          # "--kubelet-arg=v=4" # Optionally add additional args to k3s
        ];
        environment.systemPackages = [ pkgs.k3s pkgs.helm netrollSrc ];
      };
  };
  testScript = ''
    k8sNode.wait_for_unit("k3s")
    k8sNode.succeed("helm --version")
  '';
}
