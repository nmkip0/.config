#!/usr/bin/env fish

function neotree-multi
    # Define base directory to scan
    set base_dir (pwd)  

    # Use `find` and `fzf` to select multiple directories
    set selected_dirs (find $base_dir -maxdepth 1 -type d | fzf --multi --prompt="Select directories: " --height=40% --border)

    if test -z "$selected_dirs"
        echo "No directories selected."
        return 1
    end

    # Prepare temp dir
    set tmpdir /tmp/neotree-multi
    rm -rf $tmpdir
    mkdir -p $tmpdir

    # Create symlinks for selected directories
    for dir in $selected_dirs
        set name (basename $dir)
        ln -s $dir $tmpdir/$name
    end

    # Open Neovim with Neo-tree rooted in temp dir
    nvim -c "Neotree $tmpdir"
end
