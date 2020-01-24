set_action "autopsy" "project_name instance_name"                              \
"Run an interactive bash shell instead of entrypoint, in an alternate container." \
"Usage:"                                                                       \
"  %program_name% %action_name% [%project_name%] [%instance_name%]"            \
""

autopsy(){(
    cd "$($0 locate "$project_name" "$instance_name")"
    docker-compose run --rm -u 0 --entrypoint /bin/bash "$project_name"
    exit $?
)}
