#!/bin/bash

set -euo pipefail

semverLevel=0
for filename in ./unreleased_changes/*.yml; do
    echo "Processing $filename..."
    while IFS= read -r line; do
        if [ "$line" == "semverPatch: true" ] && [ "$semverLevel" -lt 1 ]; then semverLevel=1; fi
        if [ "$line" == "semverMinor: true" ] && [ "$semverLevel" -lt 2 ]; then semverLevel=2; fi
        if [ "$line" == "semverMajor: true" ] && [ "$semverLevel" -lt 3 ]; then semverLevel=3; fi
        if [ "$line" == "semverEpoch: true" ] && [ "$semverLevel" -lt 4 ]; then semverLevel=4; fi
    done < $filename
done

case "$semverLevel" in
    "0")
        echo "Could not determine semver level. Exiting."
        exit 1
        ;;
    "1")
        echo "Creating Patch Release"
        ;;
    "2")
        echo "Creating Minor Release"
        ;;
    "3")
        echo "Creating Major Release"
        ;;
    "4")
        echo "Creating Epoch Release"
        ;;
esac
