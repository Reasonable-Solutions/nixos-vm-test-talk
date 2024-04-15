{
  name = "netroll-test";

  nodes = {
    k8sNode = { pkgs, ... }:
      let

        naiserator = pkgs.buildGoModule {
          name = "naiserator";
          hash = "sha256-24JMMwkCa7Uinyi5xpUvk/RMOjZfSN0b8QZ1CNRpITA=";
          doCheck = false; # I don't wanna do the whole kubebuilder dance
          src = pkgs.fetchFromGitHub {
            owner = "nais";
            repo = "naiserator";
            rev = "d0e112f2302f0af6b6c8ea8f2fa437ff69830835";
            hash = "sha256-24JMMwkCa7Uinyi5xpUvk/RMOjZfSN0b8QZ1CNRpITA=";
          };

          vendorHash = "sha256-OkSvMBo+TSRTIaPF6+wCOQ7YiaAoa+eU2ft5Z4E7Fpw=";
          postInstall = ''
            mkdir -p $out/resources
            cp $src/hack/resources/* $out/resources
          '';
        };

        netroll = pkgs.buildGoModule {
          name = "netroll";
          hash = "sha256-uBt/BVZf5N83YV8arrEtIk5d1F2gS6rwq5bANJC6RZo=";
          src = pkgs.fetchFromGitHub {
            owner = "nais";
            repo = "netroll";
            rev = "d5e9b505114e1d2ce8fd17ce45b29554ffe8921b";
            hash = "sha256-uBt/BVZf5N83YV8arrEtIk5d1F2gS6rwq5bANJC6RZo=";
          };
          vendorHash = "sha256-zKxZuHNF1vArKw8lBfON62Lz/pLAYPGIRNeNt23iSyA";
          postInstall = ''
            mkdir -p $out/charts
            mkdir -p $out/resources
            stat $src/hack/sqlinstance.yaml
            cp -r $src/hack/sqlinstance.yaml $out/resources/
            cp -r $src/charts/* $out/charts/
          '';

        };
      in {
        virtualisation = {
          cores = 8;
          memorySize = 8000;
        };

        networking.firewall.allowedTCPPorts = [
          6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
        ];
        services.k3s.enable = true;
        services.k3s.role = "server";
        services.k3s.extraFlags = toString [ ];

        environment.systemPackages =
          [ pkgs.k3s pkgs.kubernetes-helm netroll naiserator ];

      };
  };

  testScript = ''
    k8sNode.wait_for_unit("k3s")
    k8sNode.succeed("export KUBECONFIG=/etc/rancher/k3s/k3s.yaml")
    k8sNode.succeed("helm version")
    k8sNode.succeed("kubectl get ns")
    #    k8sNode.succeed("echo foo > /tmp/out")
    k8sNode.succeed("ls /nix/store/ | grep naiserator > /tmp/out")
    k8sNode.succeed("ls /nix/store/$(ls /nix/store/ | grep naiserator$)")
    k8sNode.succeed("kubectl apply -f /nix/store/$(ls /nix/store/ | grep naiserator$)/resources/")
    # k8sNode.succeed("kubectl apply -f /nix/store/$(ls /nix/store/ | grep netroll$)/resources/sqlinstance.yaml")


    k8sNode.succeed("ls /nix/store/ | grep netroll$ > /tmp/kube")
    k8sNode.succeed("ls /nix/store/$(ls /nix/store/ | grep netroll$)/resources/ >> /tmp/kube")

    machine.copy_from_vm("/tmp/kube", "")

    # k8sNode.succeed("cd /nix/store/$(ls /nix/store/ | grep netroll$)/charts && helm install -f .  netroll > /tmp/out")
    machine.copy_from_vm("/tmp/out", "")
    # dwxfdcfmaf898f2f7djv3iixy66bvggx-netroll
  '';
}
