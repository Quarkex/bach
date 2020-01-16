set_action "execute" "project_name instance_name"                              \
"Use “docker-compose exec” in the service of the instance with the same name as the project" \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name% [arguments]"    \
""

execute(){(
    target_folder="$instances_folder/$project_name.d"

    instance_folder="$target_folder/$instance_name"
    if [ ! -d "$instance_folder" ]; then
        echo "ERROR: Project $instance_name does not exist.";
        return -1;
    else
        cd "$instance_folder";
        docker-compose exec "$project_name" $@;
        return $?
    fi
)}
