# Source and destination directories
SOURCE_DIR="$HOME/projects/config"
DEST_DIR="$HOME/.config"

# Function to clean up broken symbolic links in the destination directory
cleanup_broken_symlinks() {
    echo "Cleaning up broken symbolic links in $DEST_DIR..."
    find "$DEST_DIR" -type l ! -exec test -e {} \; -print -delete
    echo "Broken symbolic links have been removed."
}

# Clean up broken symbolic links before refreshing symlinks
cleanup_broken_symlinks

# Link each subdirectory and file from SOURCE_DIR into DEST_DIR
for item in "$SOURCE_DIR"/*; do
    basename=$(basename "$item")
    dest="$DEST_DIR/$basename"

    # Remove existing symlink or directory at the destination
    if [ -L "$dest" ] || [ -d "$dest" ]; then
        rm -rf "$dest"
    fi

    # Create symlink
    ln -s "$item" "$dest"
done

echo "Symlinks have been refreshed."
