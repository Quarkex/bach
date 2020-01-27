set_action "upgrade" "-i"                                                      \
"Update the templates folder or the image sources folder"                      \
"Usage:"                                                                       \
"  %program_name% %action_name% [-i]"                                          \
""                                                                             \
"To update the image sources folder:"                                          \
"  %program_name% %action_name% -i"                                            \
""

upgrade(){(
    target_folder="$sources_folder"
    [ ${i:=0} -gt 0 ] && target_folder="$images_folder"

    if [ ! -d "$target_folder" ]; then
        echo "ERROR: “$target_folder” folder does not exist."
        return -1
    fi

    if [ ! -d "$target_folder/.git" ]; then
        echo "ERROR: “$target_folder” is not a git project."
        return -1
    fi

    cd "$target_folder" && \
    git pull --recurse-submodules && \
    git submodule update --recursive --remote && \
    git add * && \
    git commit -m "Updated submodules" && \
    git push;
    return $?;
)}
