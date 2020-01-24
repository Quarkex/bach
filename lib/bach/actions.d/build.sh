set_action "build" ""                                                          \
"Build docker images checking image dependencies"                              \
"Usage:"                                                                       \
"  %program_name% %action_name%"                                               \
""                                                                             \
"To build specific images:"                                                    \
"  %program_name% %action_name% %image% %image% %image% ..."                   \
""

build(){(

    if [ ! -d "$images_folder" ]; then
        echo "ERROR: docker images folder does not exist."
        return -1
    fi

    if [ ${#@} -eq 0 ]; then
        images="$(ls "$images_folder")"
    else
        images="$*"
    fi

    get_dependency(){
        dep_name="$(
            grep -i "FROM " "$images_folder/$1/Dockerfile" | sed 's/FROM //'
        )"
        if [ -d "$images_folder/$dep_name" ]; then
            echo $dep_name
        else
            echo ""
        fi
    }

    get_dependencies(){
        output="$(get_dependency "$1")"
        if [ ! "$output" == "" ]; then
            output="$output $(get_dependencies "$output")"
        fi
        echo $output
    }

    build_image(){(
        cd "$images_folder/$1"
        docker build -t "$1" --no-cache .
    )}

    declare -A built_images;
    for image in $images; do
        deps="$image $(get_dependencies "$image")"
        deps="$(echo "$deps" | tr ' ' '\n'| tac | tr '\n' ' ')"
        for dep in $deps; do
            [ ! ${built_images["$dep"]:=0} -gt 0 ] \
                && echo "Building “$dep”" \
                && build_image "$dep"
            built_images["$dep"]=$(( ${built_images["$dep"]:=0} + 1 ))
        done
    done

    echo "Done."
)}
