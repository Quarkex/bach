set_action "restore" "project_name instance_name backup_date? backup_time? -f" \
"Restore a backup of an instance created with “backup”"                        \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name% [-f] [ARGS]"    \
""                                                                             \
"To load the latest backup:"                                                   \
"  %program_name% %action_name% %project_name% %instance_name%"                \
""                                                                             \
"To load the latest backup of a specific day:"                                 \
"  %program_name% %action_name% %project_name% %instance_name% \\\\"           \
"    \"<DD-MM-YYYY>\""                                                         \
""                                                                             \
"To load a specific backup:"                                                   \
"  %program_name% %action_name% %project_name% %instance_name% \\\\"           \
"    \"<DD-MM-YYYY>\" \"<HH-MM-SS>\""                                          \
""                                                                             \
"This command will ask for confirmation if a project is already in the"        \
"destination folder. You may override this with the -f (force) flag."          \
""

restore(){(
    [[ $f -gt 0 ]] && confirmed_action=true

    backup_date="$(
    echo "${backup_date}" \
    | tr "-" "\n"         \
    | tac -               \
    | tr "\n" "-"         \
    | sed 's/-$//'        \
    )"

    instance_folder="$instances_folder/$project_name.d/$instance_name"
    instance_backup_folder="${backup_folder}$project_name.d/$instance_name"

    if [ -d "$backup_folder/$project_name.d/$instance_name" ]; then

        file=""
        ls -1 -r "${instance_backup_folder}/"${backup_date:-*}_${backup_time:-*}.tar.gz &>/dev/null
        [ $? -eq 0 ] && file="$( ls -1 -r "${instance_backup_folder}/"${backup_date:-*}_${backup_time:-*}.tar.gz | head -n 1 )";

        if [ ! "$file" == "" ]; then
            if [ -d "$instance_folder" ]; then
                if [[ ! $confirmed_action == true ]]; then
                    while true; do
                        echo "You are about to permanently replace instance “$instance_name” of project “$project_name” with this backup:"
                        echo -e "\n\t$(echo "$file" | sed "s;$instance_backup_folder/;;g")\n"
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
            else
                confirmed_action=true
            fi

            if [[ $confirmed_action == true ]]; then

                if [ -d "$instance_folder" ]; then
                    "$0" compose \
                        "$project_name" "$instance_name" down

                    rm -rf "$instance_folder"
                fi

                mkdir -p "$instance_folder" && \
                tar \
                --directory="$instance_folder" \
                -zxpvf "$file"
                return $?
            else
                echo "Operation cancelled"
                return -1
            fi
        else
            echo "ERROR: The backup ${file##*/} does not exist.";
            return -1;
        fi

        return 0;
    else
        echo "ERROR: Project $instance_name does not have backups.";
        return -1;
    fi

)}
