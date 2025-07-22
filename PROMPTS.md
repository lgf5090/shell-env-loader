
```md
读懂当前项目的要求 （.specs文件夹），按照.specs/tasks.md文档任务为常用的shell(bash/zsh/fish/nushell/pwsh)实现一个.env环境加载器，所有测试用例都必须包含.env中涵盖的场景，有的我可能还没有想到，你可以在此基础上自行添加，这样可以使得代码更加健壮，还有要创建安装脚本(默认为当前系统存在的所有shells安装（也可以加 --all参数），也可以指定为单个或多个shells安装)。每个shell都尽量使用内置命令实现（fish/nushell/pwsh）,避免使用外部命令或者第三方程序。当完成一个shell的所有功能测试请执行提交git commit（提交信息要符合规范，可以添加适当的emoji）信息然后再实现下一个shell开发。
```


```md
我为.env增加了几个测试项目，重新按照.env编写所有测试用例（一个变量即为一个测试用例）并跑通，然后提交git，最后才能实现下一个shell(zsh)的功能实现。
注意：你需要检测一下SHELL后缀的优先级顺序时候正确：
特定SHELL > 特定平台 > 平台 > 通用平台 > 无后缀。 如： 
LINUX: var_NU > var_WSL > var_LINUX > var_UNIX > var
MACOS: var_NU > var_MACOS > var_UNIX > var
WIN: var_NU > var_WIN > var
当检测到是LINUX平台， 那么就应该过滤掉_WIN和_MACOS等其他平台的变量才对啊，如果当前的linux环境不是Windows下的WSL环境，那么_WSL也应该过滤掉，但如果是WSL环境那么就只保留_WSL，其余过滤掉， LINUX平台就应该只是加载和LINUX平台有关的变量_LINUX, _UNIX和没有后缀还有各种特定SHELL后缀

例如： .env有变量如下：
CONFIG_DIR=~/.config
CONFIG_DIR_UNIX=~/.config/unix
CONFIG_DIR_LINUX=~/.config/linux
CONFIG_DIR_WSL=~/.config/wsl
CONFIG_DIR_MACOS="~/Library/Application Support"
CONFIG_DIR_WIN=%APPDATA%

要是当前环境是Windows下的WSL环境， 那么CONFIG_DIR就应该取CONFIG_DIR_WSL，也就是CONFIG_DIR=~/.config/wsl， 其余变量应该过滤，也就是环境变量中不存在CONFIG_DIR_UNIX, CONFIG_DIR_LINUX, CONFIG_DIR_MACOS, CONFIG_DIR_WIN等变量。

另外需要注意检测PATH_ADDITION_LINUX变量是否追加到原有环境的PATH变量之上，此外PATH是不能有任何变量的，都需要展开，如： $HOME, $JAVA_HOME等等，环境中的所有变量只要出现在PATH变量中都需要展开
```


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


powershell测试命令
```pwsh
pwsh -NoProfile -NoLogo -File  tests/shells/test_pwsh_comprehensive.ps1
```

```bash
bash --noprofile --norc tests/shells/test_bash_comprehensive.sh
```

```zsh
zsh --no-rcs --no-globalrcs "tests/shells/test_zsh_comprehensive.zsh"
```


```bash
bash --noprofile --norc "tests/shells/test_bzsh_comprehensive.sh"
```

```zsh
zsh --no-rcs --no-globalrcs "tests/shells/test_bzsh_comprehensive.sh"
```

```fish
fish --no-config -c "source tests/shells/test_fish_comprehensive.fish"
```

```pwsh
pwsh -NoProfile -NoLogo -File  "tests/shells/test_pwsh_comprehensive.ps1"
```

```nu
nu --no-config-file "tests/shells/test_nu_comprehensive.nu"
```


# 性能测试

```zsh
cd ~/Downloads && echo "1. ZSH loader (fixed):" && time zsh -c 'unset test_env_loader ENV_LOADER_INITIALIZED; source ~/Desktop/code/augment/shell-env-loader/src/shells/zsh/loader.zsh; echo "Result: $test_env_loader"'
```

```bash
cd ~/Downloads && echo "2. BASH loader (fixed):" && time bash -c 'unset test_env_loader ENV_LOADER_INITIALIZED; source ~/Desktop/code/augment/shell-env-loader/src/shells/bash/loader.sh; echo "Result: $test_env_loader"'
```

