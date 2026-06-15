# Cheatsheet

## 更新固定版 Ollama

```bash
# 1. 在 flake.nix 里把 nixpkgs-ollama 的 rev 改成想要的 nixpkgs commit

# 2. 更新只属于 Ollama 的锁定输入
nix flake lock --update-input nixpkgs-ollama

# 3. 应用配置
sudo nixos-rebuild switch --flake /etc/nixos#nixos-main

# 如果 switch 被 critical component 检查拦住，就改用：
sudo nixos-rebuild boot --flake /etc/nixos#nixos-main
reboot
```

## Burp Suite

当前 `burpsuite` 入口由 Home Manager wrapper 管理：

- 自动设置 Java `--add-opens` 参数。
- 如果 `/etc/nixos/assets/BurpAddon.jar` 存在，启动时自动加载为
  `-javaagent`；文件不存在也不会影响构建或启动。
- 默认设置 `_JAVA_AWT_WM_NONREPARENTING=1`，用于缓解 Java/Swing 在
  niri + XWayland 桥接环境里的弹出菜单定位问题。
- 默认不启用 Java UI scale。`-Dsun.java2d.uiScale` 在 niri/XWayland 下可能
  导致 Swing 下拉框坐标错位，弹到 Burp 窗口右下角。
- 需要临时试 Java UI scale 时显式设置：

```bash
BURP_UI_SCALE=1.5 burpsuite
```

排查 addon 是否影响 Swing UI 时可临时禁用私有 `javaagent`：

```bash
BURP_DISABLE_ADDON=1 burpsuite
```

私有 addon jar 放这里，且已被 `.gitignore` 忽略：

```bash
/etc/nixos/assets/BurpAddon.jar
```

Burp Python/Jython 扩展，例如 GAP、AuthMatrix 这类 Python BApp，需要在
Burp 里配置 Jython standalone jar：

```text
Extensions -> Extensions settings -> Python environment
Location of Jython standalone JAR:
/home/sernseek/.local/share/burp/jython.jar
```

这个路径由 Home Manager 从 `pkgs.jython` 生成，换代后不需要手动找
`/nix/store/...-jython-*/jython.jar`。
