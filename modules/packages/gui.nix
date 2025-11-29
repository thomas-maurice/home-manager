{ pkgs }:

# GUI applications (cross-platform)
# This is just a list that can be imported by both darwin and linux configurations
with pkgs;
[
  firefox
  google-chrome
  keepassxc
]
