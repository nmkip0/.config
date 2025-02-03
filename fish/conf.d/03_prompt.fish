starship init fish | source

function fish_mode_prompt
    if test "$fish_bind_mode" = "insert"
        # Change cursor to a vertical bar in insert mode
        echo -ne "\e[5 q"  # Escape sequence for I-beam (|) cursor
    else
        # Change cursor back to block in normal mode
        echo -ne "\e[2 q"  # Escape sequence for block cursor
    end
end

fish_mode_prompt
