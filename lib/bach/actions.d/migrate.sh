set_action "migrate" "target_host project_name? instance_name?"                \
"Send a project to another installation via ssh"                               \
"Usage:"                                                                       \
"  %program_name% %action_name% %target_host% [%project_name%] [%instance_name%]" \
""

migrate(){(
    ssh $target_host "$program_name" actions &>/dev/null
    if [ ! $? -eq 0 ]; then
        echo "ERROR: something is wrong with the host."
    else
        perform_migration(){( # project, instance #
            remote_backup_folder="$(
                ssh $target_host "$program_name" locate -b "$1" "$2"
            )"
            local_backup_folder="$( $0 locate -b "$1" "$2")"
            local_instance_folder="$( $0 locate "$1" "$2")"

            [ -d "$local_instance_folder" ] && $0 backup "$1" "$2"
            rsync -r "$local_backup_folder" $target_host:"$remote_backup_folder"
        )}

        [ "$project_name" != "" ] && projects="$project_name" || projects="$($0 list)";
        for project in $projects; do
            [ "$instance_name" != "" ] && instances="$instance_name" || instances="$( $0 list "$project" )";
            for instance in $instances; do
                perform_migration "$project" "$instance"
            done
        done
    fi

)}
