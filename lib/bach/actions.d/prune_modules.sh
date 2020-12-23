set_action "prune_modules" "project_name? instance_name?"                      \
"Remove all Odoo modules already present in the image from the extra addons dir." \
"Usage:"                                                                       \
"  %program_name% %action_name% [%project_name%] [%instance_name%]"            \
""

prune_modules(){(

    # $instance_name $version_name
    prune_modules_from_instance(){(
        instance="${1}"
        odoo_version="${2##odoo}"

        [ "$instance" == "" ] && return -1;
        [ "$odoo_version" == "" ] && return -1;

        target="$($0 execute odoo$odoo_version $instance ls /mnt/extra-addons | tr '\n' ' ' | tr -d '\r')"
        for module in $target; do
            $0 execute odoo$odoo_version $instance bash -c "ls -d /lib/odoo/addons/$odoo_version.0/$module" &>/dev/null
            if [ $? -eq 0 ]; then
                echo "Exist: $module"
                $0 compose odoo$odoo_version $instance exec -u 0 odoo$odoo_version rm -rf /mnt/extra-addons/$module
                [ $? -eq 0 ] && echo "The module has been removed" || echo "The module could not be removed"
            else
                echo "Does not exist: $module"
            fi
        done
    )}

    for project in ${project_name:=$( $0 list )}; do
        for instance in ${instance_name:=$( $0 list $project )}; do
            prune_modules_from_instance "$project" "$instance"
        done
    done

)}
