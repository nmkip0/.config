function load_env_file
    for line in (cat $argv[1])
        # Skip comments and empty lines
        if not string match -qr '^\s*#' $line && test -n "$line"
            set -l key_value (string split '=' $line)
            if test (count $key_value) -eq 2
                # Expand any $VARIABLES inside values
                set -gx $key_value[1] (eval echo -- $key_value[2])
            end
        end
    end
end
