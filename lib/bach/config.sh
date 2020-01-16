instances_folder="$(
    get_config_value \
        "INSTANCES_FOLDER" \
        "/srv/${program_name}"
)"

images_folder="$(
    get_config_value \
        "IMAGE_SOURCES_FOLDER" \
        "/etc/${program_name}/image_sources"
)"

sources_folder="$(
    get_config_value \
        "PROJECT_TEMPLATES_FOLDER" \
        "/etc/${program_name}/project_templates"
)"

backup_folder="$(
    get_config_value \
        "BACKUP_FOLDER" \
        "/srv/${program_name}_backups"
)/"

days_to_backup="$(
    get_config_value \
        "DAYS_TO_BACKUP" \
        "3"
)"

action_definitions_folder="$(
    get_config_value \
        "ACTION_DEFINITIONS_FOLDER" \
        "$program_lib_dir/${program_name}/actions.d"
)"
