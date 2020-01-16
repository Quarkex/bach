set_action "cp_in" "project_name instance_name target_file instance_inner_destination?" \
"Copy a file into a docker-compose already generated instance of a project"    \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name% \\\\"           \
"      %target_file% [%instance_inner_destination%] [arguments]"               \
""

cp_in(){(
    target_folder="$instances_folder/$project_name.d"

    instance_folder="$target_folder/$instance_name"
    if [ ! -d "$instance_folder" ]; then
        echo "ERROR: Project $instance_name does not exist.";
        return -1;
    else
        if [ "$target_file" == "" ]; then
            echo "You need to specify the file to import, and also you may do so with the destination as well."
            return -1;
        fi

        file="$(realpath "$target_file")"
        target="${instance_inner_destination:-.}"

        docker cp "$file" "$(cd "$instance_folder"; docker-compose ps -q "$project_name")":"$target" $@;
        return $?
    fi
)}
