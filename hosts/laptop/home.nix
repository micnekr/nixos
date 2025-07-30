{ config, pkgs, system, localflakes, ... }:

{
  home.packages = [ pkgs.telegram-desktop ];
}
