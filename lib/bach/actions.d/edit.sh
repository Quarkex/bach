set_action "edit" "project_name instance_name"                                 \
"Edit the project variables file with ${EDITOR:-nano}"                         \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name%"                \
""

edit(){(
    target_folder="$instances_folder/$project_name.d"

    instance_folder="$target_folder/$instance_name"
    if [ ! -d "$instance_folder" ]; then
        echo "ERROR: Project $instance_name does not exist.";
        return -1;
    else
        if [ ! -f "$instance_folder/.env" ]; then
            echo "ERROR: Project $instance_name does not hace an .env file.";
            return -1;
        else
            $(which ${EDITOR:-nano}) "$instance_folder/.env";
            return $?
        fi
    fi
)}
