#!/bin/bash

# Sourcing configuration file
. ./build.config

# SECTION Directory preparation

# Forced overwriting mode
if [ -z "$forced" ]; then
    rm -rf data
    rm -rf dist
    rm -rf build
    mkdir data
    mkdir dist
    mkdir build
else
    # Ask before overwriting
    if [ -z "$(ls -A build/ || echo '')" ]; then
        mkdir build
    else
        echo "WARNING: build directory already exists. Overwrite?"
        read -p "(y/N) " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            rm -rf build
            mkdir build
            REPLY=""
        else
            echo "ERROR: build directory already exists"
            exit -1
        fi
    fi

    if [ -z "$(ls -A dist/ || echo '')" ]; then
        mkdir dist
    else
        echo "WARNING: dist directory already exists. Overwrite? (y/N)"
        read -p "(y/N) " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            rm -rf dist
            mkdir dist
            REPLY=""
        else
            echo "ERROR: dist directory already exists"
            exit -1
        fi
    fi

    if [ -z "$(ls -A data/ || echo '')" ]; then
        mkdir data
    else
        echo "WARNING: data directory already exists. Overwrite? (y/N)"
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            rm -rf data
            mkdir data
            REPLY=""
        else
            echo "ERROR: data directory already exists"
            exit -1
        fi
    fi
fi

# !SECTION

# SECTION Data copy

# Copying main script
cp $script data/

# If specified, copy included files
if [ -z "$include" ]; then
    echo "[!] No includes"
else
    for inc in $include
    do
        cp -r $inc data/
    done
fi

# If specified, build modules installation part
if [ -z "$modules" ]; then
    pipinsall="# No packages to install"
else
    pipinstall="pip3 install"
    for mod in $modules
    do
        pipinstall=$pipinstall" "$mod
    done
fi

# Move into build folder
mv data build/
cd build/

# !SECTION

# SECTION Inline data

# Compress folder
tar -cvzf data.tar.gz data

# Read plain hex from gzipped data
hexdata=$(xxd -c 10000000000 -p data.tar.gz)

# Just some output
echo $hexdata

# !SECTION

# SECTION Writing the script

# Prepare first segment
read -r -d '' ONE << EOM
#!/bin/bash \n
cd "\$(dirname "\$0")";\n
EOM

# Prepare inlined section
MIDDLE="hexdata=$hexdata;\n"

# Prepare last segment
# For in depth explanation wait a day i can write proper documentation
read -r -d '' TWO << EOM
export NONINTERACTIVE=1;\n
export HOMEBREW_BREW_GIT_REMOTE="...";\n
export HOMEBREW_CORE_GIT_REMOTE="...";\n
/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)";\n

brew install vim;\n
brew install python-tk;\n

echo \$hexdata | xxd -r -p > restored.tar.gz;\n
tar -xvf restored.tar.gz
rm -rf restored.tar.gz

$pipinstall

cd data

python3 $script;\n

rm -rf data\n

exit\n

EOM

# Just outputting
echo -e $ONE
echo -e $MIDDLE
echo -e $TWO

# Writing the final script
echo -e "$ONE\n$MIDDLE\n$TWO" > run.sh

# !SECTION

# SECTION Creating executable

# Making it executable
chmod +x run.sh
# C conversion and compilation
shc -f run.sh
# Cleanup
cd ..
mv build/run.sh.x dist/$package

# !SECTION