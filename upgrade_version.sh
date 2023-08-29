#!/bin/bash

################################################################################################################
# Script designed specifically for Tron to change versions in the src and test directories as well as in the   #
# package.json file.                                                                                           #
#                                                                                                              #
# Usage:                                                                                                       #
#           ./upgrade_version.sh <MAJOR.MINOR.MICRO>                                                           #
#                                                                                                              #
# Notice that there are no quote marks in the version.                                                         #
################################################################################################################

# since all the files in source will have the same declaration pattern, we can use it to accurately change versions
replace_version_in_src() {
    local file="$1"
    local new_version="$2"
    
    sed -i "" "s/\(string[[:space:]]*private[[:space:]]*constant[[:space:]]*VERSION[[:space:]]*=[[:space:]]*\"\)[^\"]*\(\"\)/\1$new_version\2/" "$file"
}

# in the case of the tests, we have to make sure we are only changing strings that follows the number.number.number pattern
replace_version_in_test() {
    local file="$1"
    local new_version="$2"
    
    sed -i "" "s/\(\w*([[:space:]]*[^\"]*[[:space:]]*[^\()]*[[:space:]]*\"\)[^\D]*\.[^\D]*\.[^\D]*\(\"[[:space:]]*)\)/\1$new_version\2/" "$file"
    sed -i "" "s/\(\w*([[:space:]]*\"\)[^\D]*\.[^\D]*\.[^\D]*\(\"[[:space:]]*[^\()]*[[:space:]]*[^\"]*[[:space:]]*)\)/\1$new_version\2/" "$file"
}

# we change the package.json file following the regular pattern of this file
replace_version_in_package_json() {
    local file="$1"
    local new_version="$2"

    echo "$file"
    
    sed -i "" "s/\(\"version\":[[:space:]]*\"\)[^\"]*\(\",\)/\1$new_version\2/" "$file"
 }

main() {
    
    local new_version="$1"
    
    if [ -z "$new_version" ]; then
        echo "Usage: $0 <new_version>"
        exit 1
    fi
    
    # replace in src
    while IFS= read -r -d '' file; do
        replace_version_in_src "$file" "$new_version"
    done < <(find "src" -type f -name "*.sol" -print0)

     # replace in test
    while IFS= read -r -d '' file; do
        replace_version_in_test "$file" "$new_version"
    done < <(find "test" -type f -name "*.sol" -print0)

    # replace in package.json
    replace_version_in_package_json "./package.json"  "$new_version"
    
}

main "$@"
