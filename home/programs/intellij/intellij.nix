{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    jetbrains.idea
    jetbrains-toolbox
  ];
  home.sessionVariables = {
    IDEA_VM_OPTIONS = "/home/skiexx/.jb_run/vmoptions/idea.vmoptions";
  };
}
