database_executables=("psql")
set_action "backup_databases" "project_name? instance_name?"                   \
"Perform a dump of active instances inside its folder."                        \
"Usage:"                                                                       \
"  %program_name% %action_name% [%project_name%] [%instance_name%]"            \
""                                                                             \
"This command operates over the following databases:"                          \
"${database_executables[@]}"                                                   \
""

backup_databases(){(
    backup_instance_database(){(
        local project="$1"
        local instance="$2"
        instance_folder="$instances_folder/$project.d/$instance"
        instance_backup_folder="$backup_folder/$project.d/$instance"
        for executable in "${database_executables[@]}"; do
            executable_path="$(
            cd "$instance_folder"
            docker-compose run --rm -u 0 --entrypoint /bin/bash \
                "$project_name" -c "which \"$executable\""
            )"
            if [ ! "$executable_path" == "" ]; then
                backup_path="$instance_backup_folder/$executable.bak"
                backup_file="$(date +%Y-%m-%d_%H-%M-%S).$executable.dump"
                [ ! -d "$backup_path" ] && mkdir -p "$backup_path"
                case "$executable" in
                    psql)
                        (cd "$instance_folder"
                        touch "$backup_path/$backup_file"
                        docker-compose run --rm -u 0 \
                            -v "$backup_path/$backup_file:/tmp/db.dump:rw" \
                            --entrypoint /bin/bash "$project_name" -c '
                            psql -lqt | cut -d \| -f 1 | grep -qw "$PGDATABASE";
                            [ $? == 0 ] && pg_dump >/tmp/db.dump;
                            exit $?'
                        )
                        ;;

                esac

            fi

        done
    )}

    backup_project_databases(){(
        local project="$1"
        [ -d "$(project locate "$project")" ] && \
        for i in $(project list "$project"); do
            backup_instance_database "$project" "$i"
        done
    )}

    if [ ! "$project_name" == "" ] && [ ! "$instance_name" == "" ]; then
        backup_instance_database "$project_name" "$instance_name"
    else
        if [ ! "$project_name" == "" ]; then
            backup_project_databases "$project_name"
        else
            for p in $(project list); do
                backup_project_databases "$p"
            done
        fi
    fi

)}
