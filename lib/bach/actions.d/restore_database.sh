database_restore_executables=("psql")
set_action "restore_databases" "project_name instance_name database_type? backup_date? backup_time? -f" \
"Restore backups of the databases created with “backup_databases”"             \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name% [-f] [ARGS]"    \
""                                                                             \
"To load the latest backup:"                                                   \
"  %program_name% %action_name% %project_name% %instance_name%"                \
""                                                                             \
"To load the latest backup of a single database:"                              \
"  %program_name% %action_name% %project_name% %instance_name% %database_type%" \
""                                                                             \
"To load the latest backup of a specific day:"                                 \
"  %program_name% %action_name% %project_name% %instance_name%  %database_type%\\\\" \
"    \"<DD-MM-YYYY>\""                                                         \
""                                                                             \
"To load a specific backup:"                                                   \
"  %program_name% %action_name% %project_name% %instance_name%  %database_type%\\\\" \
"    \"<DD-MM-YYYY>\" \"<HH-MM-SS>\""                                          \
""                                                                             \
"This command is DANGEROUS and will ask for confirmation."                     \
"You may override this with the -f (force) flag."                              \
""                                                                             \
"This command operates over the following databases:"                          \
"${database_restore_executables[@]}"                                           \
""

restore_databases(){(
    [[ $f -gt 0 ]] && confirmed_action=true

    output=0

    if [ ! "${backup_date}" == "" ]; then
        backup_date="$(
        echo "${backup_date}" \
        | tr "-" "\n"         \
        | tac -               \
        | tr "\n" "-"         \
        | sed 's/-$//'        \
        )"
    fi
    target_file_identifier="${backup_date:-*}_${backup_time:-*}"
    instance_folder="$instances_folder/$project_name.d/$instance_name"
    instance_backup_folder="$backup_folder/$project_name.d/$instance_name"

    restore_instance_database(){
        executable="${1}"
        target_file_name="${target_file_identifier}.${executable}.dump"
        if [ -d "$instance_backup_folder/${executable}.bak" ]; then

            file=""
            ls -1 -r "$instance_backup_folder/${executable}.bak"/$target_file_name &>/dev/null
            [ $? -eq 0 ] && file="$( ls -1 -r "$instance_backup_folder/${executable}.bak"/$target_file_name | head -n 1 )"

            if [ ! "$file" == "" ]; then
                echo "Restoring file “${file##*/}”"
                perform_restore_database "$file"
                [ ! $? == 0 ] && output=$?
            else
                echo "Backup not found for database type “$executable” while in project “$project_name” and instance “$instance_name”."
            fi
        fi
    }

    if [[ ! $confirmed_action == true ]]; then
        while true; do
            echo "You are about to permanently replace instance “$instance_name”'s databases of project “$project_name”:"
            echo "It is recommendable to perform a backup first."
            echo "This action cannot be undone."
            read -p "Are you sure? " yn
            case $yn in
                [Yy]* ) confirmed_action=true; break;;
                [Nn]* ) confirmed_action=false; break;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi

    if [[ $confirmed_action == true ]]; then
        for database_executable in $database_restore_executables; do

            [ ! "$database_type" == "" ] && \
            [ ! "$database_executable" == "$database_type" ] && \
            continue;

            case "$database_executable" in
                psql)
                    perform_restore_database(){
                        (cd "$instance_folder"
                        docker-compose down
                        docker-compose run --rm -u 0 -v "$1:/tmp/db.dump:ro" --entrypoint /bin/bash "$project_name" -c '
                            psql -lqt | cut -d \| -f 1 | grep -qw "$PGDATABASE";
                            [ $? == 0 ] && dropdb "$PGDATABASE";
                            createdb "$PGDATABASE";
                            psql -f /tmp/db.dump;
                            exit $?'
                        )
                    }
                    ;;
                *)
                    perform_restore_database(){
                        return 0
                    }
                    ;;
            esac

            restore_instance_database "$database_executable"

        done
        return $output
    else
        return 0
    fi
)}
