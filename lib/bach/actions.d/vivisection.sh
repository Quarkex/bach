set_action "vivisection" "project_name instance_name"                          \
"Run an interactive bash shell in a live and running container."               \
"Usage:"                                                                       \
"  %program_name% %action_name% [%project_name%] [%instance_name%]"            \
""

vivisection(){(
    cd "$($0 locate "$project_name" "$instance_name")"
    docker-compose exec -u 0 "$project_name" bash
    exit $?
)}
