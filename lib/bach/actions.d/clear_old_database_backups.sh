set_action "clear_old_database_backups" ""                                     \
"Remove files older than %days_to_backup% days from the database backups folder" \
"Usage:"                                                                       \
"  %program_name% %action_name%"                                               \
""

clear_old_database_backups(){(
    for project in $(project list); do

        [ -d "$(project locate "$project")" ] && \
        for instance in $(project list "$project"); do

            directory="$(project locate "$project" "$instance")"
            IDs="$(project compose "$project" "$instance" ps -q)"
            [ ! "$IDs" == "" ] && \
            for executable in "${database_executables[@]}"; do

                executable_path="$(project execute "$project" "$instance" which "$executable")"
                if [ ! $executable_path == "" ]; then

                    backup_path="$directory/$executable.bak"
                    case "$executable" in

                        psql)
                            if [[ -d "$backup_path" ]]; then
                                echo "Working in path “$backup_path”"
                                echo "Cleaning database backup files older than $days_to_backup days..."
                                find "${backup_path}"/* -type f -mtime +$(( $days_to_backup - 1 )) -print | xargs rm -rf
                            fi
                            ;;

                    esac

                fi

            done

        done

    done
)}
