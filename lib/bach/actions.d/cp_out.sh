set_action "cp_out" "project_name instance_name target_inner_file destination?" \
"Copy a file from inside a already generated docker-compose instance of a project" \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name% \\\\"           \
"      <target_inner_file> [<destination>] [arguments]"                        \
""

cp_out(){(
    target_folder="$instances_folder/$project_name.d"

    instance_folder="$target_folder/$instance_name"
    if [ ! -d "$instance_folder" ]; then
        echo "ERROR: Project $instance_name does not exist.";
        return -1;
    else
        if [ "$target_inner_file" == "" ]; then
            echo "You need to specify the file to export, and also you may do so with the destination as well."
            return -1;
        fi

        file="$target_inner_file"
        target="$(realpath "${destination:-.}")"

        docker cp "$(cd "$instance_folder"; docker-compose ps -q "$project_name")":"$file" "$target" $@;
        return $?
    fi
)}
