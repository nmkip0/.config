function __get_commit
  set rev
  if test -n "$argv[1]"
    set rev -r "$argv[1]"
  end

  jj log \
      -T 'commit_id ++ "\n"' \
      --no-graph \
      $rev \
    | head -n 1 | string sub -l 7
end

function __is_empty
  test (jj log -r "$argv[1]" -T 'empty' --no-graph) = "true"
end

function jd
  set commit $(__get_commit $argv)
  if test $status -ne 0 -o -z "$commit"
    return 1
  end

  if __is_empty $commit
    echo "Empty revision. No changes to show."
    return 0
  end

  nvim -c "DiffviewOpen $commit^!"
end
