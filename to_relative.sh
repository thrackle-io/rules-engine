#!/bin/bash

directories=("$client/application" "$client/interfaces" "$client/data" "$client/example" \
"$client/example/application" "$client/example/liquidity" "$client/example/pricing" \
"$client/example/script" "$client/example/staking" "$client/liquidity" "$client/pricing" \
"$client/staking" "$client/token" "$client/token/data" "$client/economic" \
"$client/economic/ruleStorage" "$client/economic/ruleProcessor" )

# Replace openzeppelin-contracts for the npm version @openzepellin
for dir in "${directories[@]}"; do
    for file in "${dir}"/*.sol; do
        if [ -f "$file" ]; then
            # Replace the old string with the new string and overwrite the file
            sed -i "" 's%openzeppelin-contracts%@openzeppelin%g' "$file"
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