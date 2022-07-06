# PyXec
## A Python to standalone binary converter

#### Currently supported platforms
- MacOS (Intel & Apple Silicon)
- Linux (theoretically all flavors)
- *nix (not tested)

#### Requirements
- bash
- brew compatibility (auto installed)
- terminal
- python3 (must be callable as python3 and not python)
- pip3 (as above)

### What does it do?

The script reads build.config file to understand which packages are needed and which files to include.

It then creates a script inlining all the needed data and transform it into a single executable (double click proof!).

### Warnings

The resulting executable IS NOT faster than the script, and DOES NOT obfuscate your script.

It is simply easier to use and more portable than forcing your customers or friends to open terminal and install stuff.

Also, the script installs brew, vim and shc. If you are not ok with it, well this is not your tool.

Last warning: due to tar.gz inlining, be aware that large files might crash the whole stuff.

### Usage
Edit build.config to set your parameters, then launch build.sh and test it into builds/