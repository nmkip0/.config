if status is-interactive
  set fish_cursor_default block
  set fish_cursor_insert line
  set fish_cursor_replace_one underscore
  set fish_cursor_replace underscore
  set fish_cursor_external line
  set fish_cursor_visual block
  set fish_vi_force_cursor 1
  fish_vi_key_bindings

  bind -M default \cv edit_command_buffer
  bind -M insert \cv edit_command_buffer
end
