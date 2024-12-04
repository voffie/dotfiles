#!/bin/bash

declare -A config_files=(
	["$HOME/dotfiles/zshrc"]="$HOME/.zshrc"
	["$HOME/dotfiles/nvim"]="$HOME/.config/nvim"
	["$HOME/dotfiles/starship.toml"]="$HOME/.config/starship.toml"
)

for src in "${!config_files[@]}"; do
	expanded_target="${config_files[$src]}"
	mkdir -p "$(dirname "$expanded_target")"
	echo "Creating symlink: $src -> $expanded_target"
	ln -sfn "$src" "$expanded_target"
done

echo "Setup complete: All symlinks created!"
