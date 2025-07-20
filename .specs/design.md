# 设计文档

## 概述

跨shell环境加载器被设计为一个模块化系统，具有共享通用解析逻辑的shell特定实现。系统遵循分层加载模式，具有平台和shell感知的变量优先级。每个shell实现都使用原生内置命令来最大化性能并最小化依赖。

## 架构

### 核心组件

```
cross-shell-env-loader/
├── src/
│   ├── common/
│   │   ├── parser.sh          # Common parsing utilities (POSIX)
│   │   ├── platform.sh        # Platform detection utilities
│   │   └── hierarchy.sh       # File hierarchy management
│   ├── shells/
│   │   ├── bash/
│   │   │   ├── loader.sh       # Bash-specific implementation
│   │   │   └── integration.sh  # Bash profile integration
│   │   ├── zsh/
│   │   │   ├── loader.zsh      # Zsh-specific implementation
│   │   │   └── integration.zsh # Zsh profile integration
│   │   ├── fish/
│   │   │   ├── loader.fish     # Fish-specific implementation
│   │   │   └── integration.fish# Fish config integration
│   │   ├── nushell/
│   │   │   ├── loader.nu       # Nushell-specific implementation
│   │   │   └── integration.nu  # Nushell config integration
│   │   └── powershell/
│   │       ├── loader.ps1      # PowerShell-specific implementation
│   │       └── integration.ps1 # PowerShell profile integration
│   └── installer/
│       ├── install.sh          # Main installation script
│       ├── detect.sh           # Shell detection utilities
│       └── configure.sh        # Configuration file management
├── tests/
│   ├── common/
│   │   └── test_parser.sh      # Common parsing tests
│   ├── shells/
│   │   ├── test_bash.sh        # Bash-specific tests
│   │   ├── test_zsh.sh         # Zsh-specific tests
│   │   ├── test_fish.fish      # Fish-specific tests
│   │   ├── test_nushell.nu     # Nushell-specific tests
│   │   └── test_powershell.ps1 # PowerShell-specific tests
│   └── integration/
│       ├── test_hierarchy.sh   # Hierarchical loading tests
│       ├── test_precedence.sh  # Platform/shell precedence tests
│       └── test_special_chars.sh # Special character handling tests
└── examples/
    ├── .env.example            # Comprehensive example file
    └── test-scenarios/         # Test scenario files
```

### 数据流

1. **初始化**: Shell特定加载器检测平台和shell类型
2. **文件发现**: 层次管理器按加载顺序识别.env文件
3. **解析**: 通用解析器使用shell特定适配处理每个文件
4. **优先级解析**: 变量优先级解析器应用平台/shell规则
5. **环境设置**: Shell特定设置器将变量应用到环境

## 组件和接口

### 通用解析器接口

```bash
# Common parsing functions (POSIX-compatible)
parse_env_file() {
    local file="$1"
    local shell_type="$2"
    local platform="$3"
    # Returns: key-value pairs with precedence metadata
}

resolve_variable_precedence() {
    local var_name="$1"
    local shell_type="$2" 
    local platform="$3"
    local -A candidates  # Associative array of candidate values
    # Returns: final variable value based on precedence rules
}

expand_variable_references() {
    local value="$1"
    local shell_type="$2"
    # Returns: value with environment variables expanded
}
```

### Shell特定加载器接口

每个shell实现一致的接口：

```bash
# Bash/Zsh example
load_env_variables() {
    local -a env_files=("$@")
    # Implementation using bash/zsh built-ins
}

set_environment_variable() {
    local key="$1"
    local value="$2"
    export "$key=$value"
}
```

```fish
# Fish example
function load_env_variables
    set -l env_files $argv
    # Implementation using fish built-ins
end

function set_environment_variable
    set -gx $argv[1] $argv[2]
end
```

```nushell
# Nushell example
def load_env_variables [env_files: list<string>] {
    # Implementation using nushell built-ins
}

def set_environment_variable [key: string, value: string] {
    $env.$key = $value
}
```

```powershell
# PowerShell example
function Load-EnvVariables {
    param([string[]]$EnvFiles)
    # Implementation using PowerShell cmdlets
}

function Set-EnvironmentVariable {
    param([string]$Key, [string]$Value)
    $env:$Key = $Value
}
```

### Platform Detection

```bash
detect_platform() {
    case "$(uname -s)" in
        Linux*)     echo "LINUX" ;;
        Darwin*)    echo "MACOS" ;;
        CYGWIN*|MINGW*|MSYS*) echo "WIN" ;;
        *)          echo "UNIX" ;;
    esac
}

detect_shell() {
    case "$0" in
        *bash*)     echo "BASH" ;;
        *zsh*)      echo "ZSH" ;;
        *fish*)     echo "FISH" ;;
        *nu*)       echo "NU" ;;
        *pwsh*|*powershell*) echo "PS" ;;
        *)          echo "UNKNOWN" ;;
    esac
}
```

### File Hierarchy Manager

```bash
get_env_file_hierarchy() {
    local -a files=()
    
    # Global user settings (lowest priority)
    [[ -f "$HOME/.env" ]] && files+=("$HOME/.env")
    
    # User configuration directory (medium priority)  
    [[ -f "$HOME/.cfgs/.env" ]] && files+=("$HOME/.cfgs/.env")
    
    # Project-specific settings (highest priority)
    [[ -f "$PWD/.env" ]] && files+=("$PWD/.env")
    
    printf '%s\n' "${files[@]}"
}
```

## 数据模型

### 变量优先级模型

```bash
# Variable precedence structure
declare -A variable_precedence=(
    ["shell_specific"]=100    # _BASH, _ZSH, _FISH, _NU, _PS
    ["platform_specific"]=50  # _UNIX, _LINUX, _MACOS, _WIN  
    ["generic"]=10            # No suffix
)

# File precedence structure
declare -A file_precedence=(
    ["$PWD/.env"]=100         # Project-specific (highest)
    ["$HOME/.cfgs/.env"]=50   # User configs (medium)
    ["$HOME/.env"]=10         # Global user (lowest)
)
```

### 变量解析模型

```bash
# 解析变量结构
declare -A parsed_variable=(
    ["key"]="VARIABLE_NAME"
    ["value"]="variable_value"
    ["source_file"]="/path/to/.env"
    ["precedence_score"]=150  # 文件 + 变量优先级组合
    ["requires_expansion"]=true
    ["shell_specific"]=false
    ["platform_specific"]=true
)
```

### 特殊字符处理模型

```bash
# Character escape mappings per shell
declare -A bash_escapes=(
    ['"']='\"'
    ["'"]="\\'"
    ['$']='\\$'
    ['`']='\\`'
    ['\\']='\\\\' 
)

declare -A fish_escapes=(
    ['"']='\"'
    ["'"]="\\'"
    ['$']='\\$'
    ['\\']='\\\\' 
)

# PowerShell uses different escaping rules
declare -A powershell_escapes=(
    ['"']='`"'
    ["'"]="''"
    ['$']='`$'
    ['`']='``'
)
```

## 错误处理

### 错误类别

1. **文件访问错误**: 文件缺失、权限问题
2. **解析错误**: 无效语法、格式错误的键值对
3. **平台检测错误**: 未知平台或shell
4. **变量展开错误**: 循环引用、未定义变量
5. **字符编码错误**: 无效Unicode、编码不匹配

### 错误处理策略

```bash
# Error handling with graceful degradation
handle_parsing_error() {
    local file="$1"
    local line_number="$2"
    local error_message="$3"
    
    # Log error but continue processing
    echo "Warning: Error in $file:$line_number - $error_message" >&2
    
    # Continue with next line/file
    return 0
}

handle_file_access_error() {
    local file="$1"
    local error_type="$2"
    
    # Skip missing files silently (expected behavior)
    [[ "$error_type" == "not_found" ]] && return 0
    
    # Warn about permission issues but continue
    echo "Warning: Cannot access $file - $error_type" >&2
    return 0
}
```

## 测试策略

### 测试类别

1. **单元测试**: 每个shell的单独函数测试
2. **集成测试**: 跨shell兼容性和文件层次结构
3. **回归测试**: .env.example中的所有场景
4. **性能测试**: 大文件处理和启动时间影响
5. **平台测试**: 跨平台兼容性验证

### 测试数据结构

```bash
# Test scenario structure
declare -A test_scenario=(
    ["name"]="basic_key_value_parsing"
    ["input"]="KEY=value"
    ["expected_key"]="KEY"
    ["expected_value"]="value"
    ["shells"]="bash zsh fish nu ps"
    ["platforms"]="linux macos win"
)

# Special character test scenarios
declare -A special_char_tests=(
    ["spaces"]='KEY="value with spaces"'
    ["quotes"]='KEY="He said \"Hello\""'
    ["unicode"]='KEY="Testing: αβγ 中文 🎉"'
    ["paths"]='KEY="/path/with spaces/file"'
    ["expansion"]='KEY="$HOME/subdir"'
)
```

### 测试执行框架

```bash
run_shell_tests() {
    local shell="$1"
    local test_file="$2"
    
    # Execute tests in isolated shell environments to prevent interference
    case "$shell" in
        bash)     bash --noprofile --norc "$test_file" ;;
        zsh)      zsh --no-rcs --no-globalrcs "$test_file" ;;
        fish)     fish --no-config -c "source $test_file" ;;
        nu)       nu --no-config-file "$test_file" ;;
        ps)       pwsh -NoProfile -NoLogo -File "$test_file" ;;
    esac
}

verify_test_result() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✅ $test_name: PASS"
        return 0
    else
        echo "❌ $test_name: FAIL (expected: '$expected', got: '$actual')"
        return 1
    fi
}
```

### 性能测试

```bash
# 性能基准测试
benchmark_loading_time() {
    local shell="$1"
    local env_file="$2"
    local iterations=100
    
    local start_time=$(date +%s%N)
    for ((i=1; i<=iterations; i++)); do
        load_env_variables "$env_file" >/dev/null 2>&1
    done
    local end_time=$(date +%s%N)
    
    local avg_time=$(( (end_time - start_time) / iterations / 1000000 ))
    echo "$shell: ${avg_time}ms average loading time"
}
```

## 安装和配置

### 安装过程

1. **检测阶段**: 识别可用的shell及其配置位置
2. **安装阶段**: 将shell特定加载器复制到适当位置
3. **集成阶段**: 修改shell配置文件以源加载器
4. **验证阶段**: 在每个shell环境中测试安装

### 配置文件位置

```bash
# Shell configuration file locations
declare -A shell_configs=(
    ["bash"]="$HOME/.bashrc"
    ["zsh"]="$HOME/.zshrc"  
    ["fish"]="$HOME/.config/fish/config.fish"
    ["nu"]="$HOME/.config/nushell/config.nu"
    ["ps"]="$PROFILE"  # PowerShell profile location varies
)

# Loader installation locations
declare -A loader_locations=(
    ["bash"]="$HOME/.local/share/env-loader/bash"
    ["zsh"]="$HOME/.local/share/env-loader/zsh"
    ["fish"]="$HOME/.config/fish/functions"
    ["nu"]="$HOME/.config/nushell/scripts"
    ["ps"]="$HOME/Documents/PowerShell/Modules/EnvLoader"
)
```

### 集成代码模板

```bash
# Bash/Zsh 集成
BASH_INTEGRATION='
# 跨shell环境加载器
if [[ -f "$HOME/.local/share/env-loader/bash/loader.sh" ]]; then
    source "$HOME/.local/share/env-loader/bash/loader.sh"
    load_env_variables
fi
'

# Fish 集成  
FISH_INTEGRATION='
# 跨shell环境加载器
if test -f "$HOME/.config/fish/functions/load_env_variables.fish"
    load_env_variables
end
'

# Nushell 集成
NU_INTEGRATION='
# 跨shell环境加载器
if ($env.HOME | path join ".config" "nushell" "scripts" "loader.nu" | path exists) {
    source ($env.HOME | path join ".config" "nushell" "scripts" "loader.nu")
    load_env_variables
}
'

# PowerShell 集成
PS_INTEGRATION='
# 跨shell环境加载器
$LoaderPath = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules\EnvLoader\loader.ps1"
if (Test-Path $LoaderPath) {
    . $LoaderPath
    Load-EnvVariables
}
'
```

## 安全考虑

### 输入验证

- 清理文件路径以防止目录遍历
- 根据shell命名约定验证变量名
- 限制文件大小以防止资源耗尽
- 验证Unicode输入以防止编码攻击

### 安全变量展开

- 防止通过变量展开进行代码注入
- 限制展开深度以防止无限递归
- 在设置环境变量之前清理展开的值
- 使用shell特定的安全展开方法

### 文件访问安全

- 在读取之前验证文件所有权和权限
- 使用安全的临时文件创建进行中间处理
- 通过路径验证防止符号链接攻击
- 实现文件访问操作的速率限制