#!/bin/bash

INSTALL_DIR="~/.local/share/steply/0.1.0-20260109"
BINARY_DIR="${INSTALL_DIR}/bin"

# Create installation directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$BINARY_DIR"

# Download the latest release
curl -L -o "$INSTALL_DIR/steply.zip" https://github.com/QABEES/steply/releases/download/0.1.0-20260109/steply-0.1.0-20260109.zip

# Unzip the downloaded file
unzip "$INSTALL_DIR/steply.zip" -d "$INSTALL_DIR"

# Create a wrapper script
cat <<EOL > ~/.local/bin/steply
#!/bin/bash
 exec "${BINARY_DIR}/steply.sh" "\$@"
EOL

# Make it executable
chmod +x ~/.local/bin/steply

# Ensure permissions
chmod -R 755 "$INSTALL_DIR"

# Print instructions
echo 'Add ~/.local/bin to your PATH by adding the following line to your ~/.bashrc or ~/.bash_profile:'
echo '  export PATH="$HOME/.local/bin:$PATH"'
