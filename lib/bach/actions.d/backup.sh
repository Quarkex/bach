set_action "backup" "project_name? instance_name?"                             \
"Performs a backup of an instance, all instances of a project, or everything"  \
"Usage:"                                                                       \
"  %program_name% %action_name%"                                               \
""                                                                             \
"To backup all instances of a project:"                                        \
"  %program_name% %action_name% %project_name%"                                \
""                                                                             \
"To backup a single instance:"                                                 \
"  %program_name% %action_name% %project_name% %instance_name% [arguments]"    \
""                                                                             \
"The bulk backups will skip any project which contain a file named .nobackup." \
"You may perform a backup manually if you specify the name of the instance"    \
"though."                                                                      \
""

backup(){(
    backup_recurse_instances(){(
        folder="${1%/}"
        padding="$2"

        for instance_folder in "$folder"/*; do
            if [[ -d "$instance_folder" ]]; then
                if [[ "${instance_folder##*\.}" == "d" ]]; then
                    echo "${padding}Processing nested folder: $instance_folder"
                    backup_recurse_instances "$instance_folder" "$padding    "
                    size="$(get_folder_size "$instance_folder")"
                    echo "$padding    Nested folder “$instance_folder” size: $size"
                else
                    if [[ ! -f "$instance_folder/.nobackup" ]]; then
                        backup_single_instance "$instance_folder" "$padding"
                    fi
                fi
            fi
        done
    )}

    backup_single_instance(){(
        instance_folder="$1"
        padding="$2"

        instance="${instance_folder%%/}"
        instance="${instance##$instances_folder}"

        instance_name="${instance##*/}"
        project_folder="${instance%%.d/$instance_name}.d"
        project_name="${project_folder%%.d}"
        project_name="${project_name##*/}"

        instance_backup_folder="$backup_folder/$instance"

        timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
        filename="${timestamp}"'.tar.gz'

        echo -n "${padding}Processing ${instance}..."

        if [[ ! -d "$instance_backup_folder" ]]; then
            mkdir -p "$instance_backup_folder"
            if [ ! $? -eq 0 ]; then
                echo "Could not create nonexistent folder “$instance_backup_folder”";
                return -1;
            fi
        fi

        if [ ! "$project_name" == "" ] && [ ! "$instance_name" == "" ]; then
            echo
            "$program_name" backup_databases "$project_name" "$instance_name" \
                | sed "s/^/$padding    /g"
        fi

        tar -zcpf "$instance_backup_folder/$filename" \
            --transform "s,^${instances_folder#/}/${project_folder#/}/${instance_name},," "$instance_folder" \
            &>/dev/null

        size="$(get_folder_size "$instance_backup_folder/$filename")"

        echo "${padding}done. File size: $size"
    )}

    echo "Begining backup process."
    echo "Saving destination: $backup_folder"
    if [ "$project_name" == "" ]; then
        folder_to_backup="$instances_folder/"
    else
        if [ "$instance_name" == "" ]; then
            folder_to_backup="$instances_folder/$project_name.d/"
        else
            folder_to_backup="$instances_folder/$project_name.d/$instance_name"
        fi
    fi
    echo "Folder to backup: $folder_to_backup"

    if [ "$instance_name" == "" ]; then
        backup_recurse_instances "$folder_to_backup" "    "
    else
        backup_single_instance "$folder_to_backup" "    "
    fi

    size="$(get_folder_size "$backup_folder")"

    echo "Total folder size: $size"

    chgrp -R docker "$backup_folder"

    echo "Done."
)}
