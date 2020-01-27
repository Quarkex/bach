set_action "install" "git_source_url submodule_name? -i -b="                   \
"Install a project template or docker image as a submodule."                   \
"Usage:"                                                                       \
"  %git_source_url% [%submodule_name%] [-i]"                                   \
""                                                                             \
"Flags:"                                                                       \
"  -i  Install git project as a docker image instead of a project template"    \
""                                                                             \
"  -b  Use a particular branch for the submodule"                              \
""

install(){(

    [ ${i:=0} -gt 0 ] \
        && target_folder="$($0 locate -i)" \
        || target_folder="$($0 locate -t)" ;

    if [ -d "$target_folder" ]; then
        cd "$target_folder"
        if [ -d "$target_folder/.git" ]; then
            if [ "$submodule_name" != "" ]; then
                git submodule add --branch "${b:=master}" $git_source_url "$submodule_name"
                return_code=$?
            else
                git submodule add --branch "${b:=master}" $git_source_url
                return_code=$?
            fi
            git add *; git commit -m "Add a submodule"; git push
        else
            echo "WARNING: The target folder “$target_folder” is not a git project."
            echo "Will only clone the module as-is."
            if [ "$submodule_name" != "" ]; then
                git clone -b "${b:=master}" $git_source_url "$submodule_name"
                return_code=$?
            else
                git clone -b "${b:=master}" $git_source_url
                return_code=$?
            fi
        fi
        return $return_code
    else
        echo "ERROR: The target folder “$target_folder” does not exist."
        return -1
    fi

)}
