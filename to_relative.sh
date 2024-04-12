#!/bin/bash

directories=("./src/client" "./src/common" "./src/protocol")

# Replace openzeppelin-contracts for the npm version @openzepellin
function refactorOpenZeppelin(){
    for dir in "${directories[@]}"; do
        for file in "${dir}"/*.sol; do
            if [ -f "$file" ]; then
                echo "${file}"
                # Replace the old string with the new string and overwrite the file
                sed -i "" 's%openzeppelin-contracts-upgradeable/contracts/%@openzeppelin/contracts-upgradeable/%g' "$file"
                sed -i "" 's%openzeppelin-contracts%@openzeppelin%g' "$file"
                sed -i "" 's%@openzeppelin-upgradeable/contracts/%@openzeppelin/contracts-upgradeable/%g' "$file"
                # echo "Replaced openzeppelin-contracts"
            fi
        done
    done
}

function fromAbsolutetoRelative(){
    # Fix from absolute to relative path
    for dir in "${directories[@]}"; do
        total_levels=$(grep -o '/' <<< "$dir" | wc -l)
        initial_levels=$(grep -o '/' <<< "." | wc -l)
        levels=$((total_levels-initial_levels))
        echo "$dir has $total_levels slashes and $initial_levels initial levels: total $levels"
        iterateAllFilesInDir $dir $levels
    done
}

function iterateAllFilesInDir() {
    for file in "$1"/*; do
        echo "$file"
        if [ -d "$file" ]; then
            iterateAllFilesInDir $file $(($2+1))
        fi
        if [ -f "$file" ]; then
            refactorPath $2 $file
            refactorDiamondSTDPath $2 $file
        fi
    done
    
}

function refactorDiamondSTDPath(){
    if [ "$1" -eq 2 ]; then
        sed -i "" 's|"diamond-std/|"../../lib/diamond-std/|g' "$2"
        echo "Replaced 2 level"
    elif [ "$1" -eq 3 ]; then
        sed -i "" 's|"diamond-std/|"../../../lib/diamond-std/|g' "$2"
        echo "Replaced 3 level"
    elif [ "$1" -eq 4 ]; then
        sed -i "" 's|"diamond-std/|"../../../../lib/diamond-std/|g' "$2"
        echo "Replaced 4 level"
    elif [ "$1" -eq 5 ]; then
        sed -i "" 's|"diamond-std/|"../../../../../lib/diamond-std/|g' "$2"
        echo "Replaced 4 level"
    elif [ "$1" -eq 6 ]; then
        sed -i "" 's|"diamond-std/|"../../../../../../lib/diamond-std/|g' "$2"
        echo "Replaced 4 level"
    fi
}

function refactorPath(){
    if [ "$1" -eq 2 ]; then
        sed -i "" 's|"src/|"../|g' "$2"
        echo "Replaced 2 level"
    elif [ "$1" -eq 3 ]; then
        sed -i "" 's|"src/|"../../|g' "$2"
        echo "Replaced 3 level"
    elif [ "$1" -eq 4 ]; then
        sed -i "" 's|"src/|"../../../|g' "$2"
        echo "Replaced 4 level"
    elif [ "$1" -eq 5 ]; then
        sed -i "" 's|"src/|"../../../../|g' "$2"
        echo "Replaced 4 level"
    fi
}

refactorOpenZeppelin
fromAbsolutetoRelative
echo 'Treated files successfully'