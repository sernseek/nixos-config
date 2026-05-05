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
