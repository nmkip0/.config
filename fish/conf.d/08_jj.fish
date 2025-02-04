jj util completion fish | source

# set -l list_bookmarks "(jj bookmark list -T 'name ++ \"\n\"')"
# set -l subcommands bookmark b branch
#
# complete -c jj -n "__fish_seen_subcommand_from $subcommands; and __fish_seen_subcommand_from delete" -f -a $list_bookmarks
# complete -c jj -n "__fish_seen_subcommand_from $subcommands; and __fish_seen_subcommand_from forget" -f -a $list_bookmarks
# complete -c jj -n "__fish_seen_subcommand_from $subcommands; and __fish_seen_subcommand_from rename" -f -a $list_bookmarks
# complete -c jj -n "__fish_seen_subcommand_from $subcommands; and __fish_seen_subcommand_from set" -f -a $list_bookmarks
# complete -c jj -n "__fish_seen_subcommand_from $subcommands; and __fish_seen_subcommand_from track" -f -a "(jj bookmark list --all-remotes -T 'name ++ \"\n\"' | grep '\w@\w')"
# complete -c jj -n "__fish_seen_subcommand_from $subcommands; and __fish_seen_subcommand_from untrack" -f -a '(
# for line in (jj bookmark list -a | cut -d ":" -f 1)
#     if echo $line | grep --quiet "^\S"
#         set --function __local_bookmark $line
#         continue
#     end
#     if [ $line = "  @git" ]
#         continue
#     end
#     echo "$__local_bookmark$(string trim $line)"
# end
# set --erase __local_bookmark
# )'
#
# set -x JJ_CONFIG $HOME/.config/jj/config.toml
