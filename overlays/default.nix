{ pkgs, inputs }:

{
  prise = pkgs.callPackage ../pkgs/prise.nix {
    inherit pkgs;
    prise = inputs.prise;
  };
}
