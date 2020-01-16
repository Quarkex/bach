generator_variables=""
for template in "$sources_folder/"*/.env; do
    template_variables="$(grep '=' "$template" | sed \
        -e 's/#.*$//g' \
        -e 's/=.*$/=/g' \
        -e 's/^[\s]*/--/g' \
        -e 's/\(.*\)/\L\1/' \
        )"
    generator_variables="$(
        echo -e "$generator_variables\n$template_variables" | sort | uniq
    )"
done
generator_variables="$(
    echo "$generator_variables" | paste -s -d' ' -
)"

set_action "generate" "project_name instance_name $generator_variables"        \
"Create a new instance of a project from a template"                           \
"Usage:"                                                                       \
"  %program_name% %action_name% %project_name% %instance_name%"                \
""                                                                             \
"You may specify variables:"                                                   \
"  %program_name% %action_name% %project_name% %instance_name% \\\\"           \
"%=get_help_variable_list%"                                                    \
""

generate(){(
    target_folder="$instances_folder/$project_name.d"

    if [ ! -d "$sources_folder/$project_name" ]; then
        echo "ERROR: Project skeleton for $project_name does not exist.";
        return -1;
    fi

    if [ ! -d "$target_folder" ]; then
        mkdir -p "$target_folder"
        if [ ! $? == 0 ]; then
            echo "ERROR: Could not create main folder.";
            return -1;
        fi
    fi

    instance_folder="$target_folder/$instance_name"
    if [ -d "$instance_folder" ]; then
        echo "ERROR: Project $instance_name already exist.";
        return -1;
    fi

    tmpfile=$(mktemp /tmp/generate-script.XXXXXX)
    if [ ! $? == 0 ]; then
        echo "ERROR: Could not create temporary file.";
        return -1;
    fi
    trap "{ rm -f "$tmpfile"; }" EXIT
    cat "$sources_folder/$project_name/.env" >"$tmpfile"

    while read line; do
        variable="${line%%=*}"
        variable="${variable,,}"
        value="${line#*=}"

        if [[ ! "${!variable}" == "" ]]; then
            value="${!variable}"
        else
            case "${variable}" in
                "compose_project_name")
                    placeholder="$project_name-$instance_name"
                    ;;
                *)
                    placeholder="$value"
                    ;;
            esac

            if [[ "${variable}" == *pass* ]]; then
                read -e -s -p "Enter hidden value for variable ${variable,,}:" \
                    value </dev/tty
                echo
            else
                read -e -p "Enter value for variable ${variable,,}:" \
                    -i "${placeholder}" \
                    value </dev/tty
            fi
        fi

        sed -i \
            's/^'"${variable^^}"'=.*$/'"${variable^^}"'='"${value}"'/' \
            "$tmpfile"

        if [ ! $? == 0 ]; then
            echo "ERROR: Could not update variable.";
            return -1;
        fi

    done<"$sources_folder/$project_name/.env"

    cp -prf "$sources_folder/$project_name" "$instance_folder"
    if [ ! $? == 0 ]; then
        echo "ERROR: Could not copy project skeleton.";
        return -1;
    fi

    cat "$tmpfile">"$instance_folder/.env"
    if [ ! $? == 0 ]; then
        echo "ERROR: Could not copy project skeleton.";
        return -1;
    fi

    echo -e "Done. Current configuration for “$instance_name” is:\n"
    cat "$instance_folder/.env" | sed 's/\(.*PASS.*\)=.*/\1=***HIDDEN***/g'

    message="
You may find your new instance in the following folder:

    "$instance_folder"

You may start your project with the following command:

    \$ $program_name compose \"$project_name\" \"$instance_name\" up -d

Then, if you want to see what is happening, you can check the logs:

    \$ $program_name compose \"$project_name\" \"$instance_name\" logs -f

"

    echo "$message" | fmt -s -

    return 0
)}
