set_action "remove_data" "project_name instance_name -f"                       \
"Removes the “data” folder generated inside an instance, clearing the persistency" \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name% [-f]"           \
""                                                                             \
"The -f (force) flag turn off confirmation."                                   \
""

remove_data(){(
    target_folder="$instances_folder/$project_name.d"

    if [[ $f -gt 0 ]]; then
        confirmed_action=true
        shift;
    fi

    if [[ ! $confirmed_action == true ]]; then
        while true; do
            read -p "Are you sure you want to permanently remove instance “$instance_name”'s data of project “$project_name”?" yn
            case $yn in
                [Yy]* ) confirmed_action=true; break;;
                [Nn]* ) confirmed_action=false; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi

    instance_folder="$target_folder/$instance_name"
    if [ $confirmed_action == true ]; then
        if [ ! -d "$instance_folder" ]; then
            echo "ERROR: Project $instance_name does not exist.";
            return -1;
        else
            if [ ! -d "$instance_folder/data" ]; then
                echo "ERROR: Project $instance_name does not have a data folder.";
                return -1;
            else
                rm -rf "$instance_folder/data";
                return $?
            fi
        fi
    else
        return 0
    fi
)}
