set_action "clear_old_backups" ""                                              \
"Remove files older than %days_to_backup% days from the backups folder"        \
"Usage:"                                                                       \
"  %program_name% %action_name%"                                               \
""

clear_old_backups(){(
    if [[ "$backup_folder" != "" ]]; then
        echo "Cleaning files older than $days_to_backup days..."
        find "${backup_folder}"/* -type f -mtime +$(( $days_to_backup - 1 )) -print | xargs rm -rf

        size="$(get_folder_size "$backup_folder")"

        echo "Total folder size after cleaning: $size"
    fi
)}
