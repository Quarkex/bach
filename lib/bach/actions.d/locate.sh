set_action "locate" "project_name? instance_name?"                             \
"Return main path, project path or instance path"                              \
"Usage:"                                                                       \
"  %program_name% %action_name% [%project_name%] [%instance_name%]"            \
""

locate(){(
    if [ ! -d "$instances_folder" ]; then
        echo "ERROR: The instances folder does not exist.";
        return -1;
    else
        if [[ "$instance_name" == "" ]]; then
            if [[ "$project_name" == "" ]]; then
                echo "$instances_folder"
            else
                echo "$instances_folder/$project_name.d"
            fi
        else
            echo "$instances_folder/$project_name.d/$instance_name"
        fi
    fi

)}
