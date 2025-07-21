# Test Precedence
source "../../src/shells/nu/loader.nu"
print $"SYSTEM_BIN precedence: (get_variable_precedence 'SYSTEM_BIN')"
print $"SYSTEM_BIN_MACOS precedence: (get_variable_precedence 'SYSTEM_BIN_MACOS')"
print $"CONFIG_DIR precedence: (get_variable_precedence 'CONFIG_DIR')"
print $"CONFIG_DIR_LINUX precedence: (get_variable_precedence 'CONFIG_DIR_LINUX')"
