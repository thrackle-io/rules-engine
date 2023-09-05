#!/bin/bash

directories=("./src/application" "./src/interfaces" "./src/data" "./src/example" \
"./src/example/application" "./src/example/liquidity" "./src/example/pricing" \
"./src/example/script" "./src/example/staking" "./src/liquidity" "./src/pricing" \
"./src/staking" "./src/token" "./src/token/data" "./src/economic" \
"./src/economic/ruleStorage" "./src/economic/ruleProcessor")

# Replace openzeppelin-contracts for the npm version @openzepellin
for dir in "${directories[@]}"; do
    echo "${dir}"
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

# Fix from absolute to relative path
for dir in "${directories[@]}"; do
    total_levels=$(grep -o '/' <<< "$dir" | wc -l)
    initial_levels=$(grep -o '/' <<< "." | wc -l)
    levels=$((total_levels-initial_levels))
     echo "$dir has $total_levels slashes and $initial_levels initial levels: total $levels"
    for file in "${dir}"/*; do
        if [ -f "$file" ]; then
            # Replace the old string with the new string and overwrite the file
            if [ "$levels" -eq 2 ]; then
                sed -i "" 's|src/|../|g' "$file"
                 echo "Replaced w level"
            elif [ "$levels" -eq 3 ]; then
                sed -i "" 's|src/|../../|g' "$file"
                 echo "Replaced 3 level"
            elif [ "$levels" -eq 4 ]; then
                sed -i "" 's|src/|../../../|g' "$file"
                 echo "Replaced 4 level"
            fi

        fi
    done
done

echo 'Treated files successfully'