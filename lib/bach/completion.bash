#!/bin/bash
_bach_completions()
{
    if [ ! "${#COMP_WORDS[@]}" -gt 1 ]; then
        return
    else
        last_word="${COMP_WORDS[$(( ${#COMP_WORDS[@]} - 1 ))]}"
        arguments="$( bach actions )"
        if [ ! "${#COMP_WORDS[@]}" -eq 2 ]; then
            case "${#COMP_WORDS[@]}" in
                3) arguments="$( bach list )";;
                4) arguments="$( bach list  "${COMP_WORDS[2]}" )";;
                *) arguments="";;
            esac
            action="${COMP_WORDS[1]}"
            case "$action" in
                #execute)
                #    ;;
                #clear_old_database_backups)
                #    ;;
                #destroy)
                #    ;;
                #actions)
                #    ;;
                #backup_databases)
                #    ;;
                #backup)
                #    ;;
                #compose)
                #    ;;
                #cp_in)
                #    ;;
                #cp_out)
                #    ;;
                #clear_old_backups)
                #    ;;
                generate)
                    case "${#COMP_WORDS[@]}" in
                        3) arguments="$( bach list -t)";;
                        *) arguments="";;
                    esac
                    ;;
                #list)
                #    ;;
                #edit)
                #    ;;
                #locate)
                #    ;;
                #remove_data)
                #    ;;
                restore_databases)
                    case "${#COMP_WORDS[@]}" in
                        3) arguments="$( bach list -d)";;
                        4) arguments="$( bach list -d "${COMP_WORDS[2]}" )";;
                        5) arguments="$( bach list -d "${COMP_WORDS[2]}" "${COMP_WORDS[3]}" )";;
                        6) arguments="$( bach list -d "${COMP_WORDS[2]}" "${COMP_WORDS[3]}" "${COMP_WORDS[4]}" \
                            | grep .dump \
                            | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})_(.*)\.dump/"\3-\2-\1"/g' )";;
                        7) arguments="$( bach list -d "${COMP_WORDS[2]}" "${COMP_WORDS[3]}" "${COMP_WORDS[4]}" \
                            | grep "$( echo "${COMP_WORDS[4]}" | tr "-" "\n" | tac - | tr "\n" "-" | sed 's/-$//' )" \
                            | grep .dump \
                            | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})_(.*)\.'"${COMP_WORDS[4]}"'\.dump/"\4"/g' )";;
                        *) arguments="";;
                    esac
                    ;;
                restore)
                    case "${#COMP_WORDS[@]}" in
                        3) arguments="$( bach list -b)";;
                        4) arguments="$( bach list -b "${COMP_WORDS[2]}" )";;
                        5) arguments="$( bach list -b "${COMP_WORDS[2]}" "${COMP_WORDS[3]}" \
                            | grep .tar.gz \
                            | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})_(.*)\.tar\.gz/"\3-\2-\1"/g' )";;
                        6) arguments="$( bach list -b "${COMP_WORDS[2]}" "${COMP_WORDS[3]}" \
                            | grep "$( echo "${COMP_WORDS[4]}" | tr "-" "\n" | tac - | tr "\n" "-" | sed 's/-$//' )" \
                            | grep .tar.gz \
                            | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})_(.*)\.tar\.gz/"\4"/g' )";;
                        *) arguments="";;
                    esac
                    ;;
            esac

        fi
        [ "$arguments" == "" ] && return || COMPREPLY=($(compgen -W "$arguments" "$last_word"))
    fi
}
complete -o nospace -F _bach_completions bach
