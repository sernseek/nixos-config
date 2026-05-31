{ pkgs, ... }:
let
  # 万象拼音的语法/语言模型（智能长句、自动纠错、模糊音的核心）。
  # 上游在 GitHub Releases 原地覆盖发布，hash 不稳定，nixpkgs 不打包；
  # 这里声明式 fetch 并放进 rime 用户目录（上游维护者建议的位置）。
  # 若上游重发导致 hash 失配，更新下方 hash 即可（约 246MB）。
  wanxiang-lm = pkgs.fetchurl {
    url = "https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram";
    hash = "sha256-Pr3wgPM9TzYY8medb540opC9dZBvQrnXU/Yw5RAeVAc=";
  };
in
{
  # rime 用户目录（~/.local/share/fcitx5/rime/）：
  # 1) 启用 雾凇拼音(rime_ice) + 万象拼音(wanxiang) 两套方案，用 Ctrl+` 切换。
  # 2) 放入万象的语言模型 wanxiang-lts-zh-hans.gram。
  # 改动后需重新部署 rime（托盘右键 → Rime → 重新部署，或重启 fcitx5）。
  xdg.dataFile."fcitx5/rime/default.custom.yaml".text = ''
    # 由 NixOS 管理：/etc/nixos/modules/home/desktop/fcitx5.nix
    patch:
      schema_list:
        - schema: rime_ice
        - schema: wanxiang
  '';
  xdg.dataFile."fcitx5/rime/wanxiang-lts-zh-hans.gram".source = wanxiang-lm;

  # 给雾凇拼音(rime_ice)挂接 维基百科 + 萌娘百科 大词库（专有名词/ACG 命中率）。
  # 思路：新建扩展词典 import 主词库 + zhwiki + moegirl（import_tables 会递归
  # 带入雾凇的 cn_dicts 主词库，实测 ~158 万词条），再把 rime_ice 的 translator
  # 指向它。zhwiki/moegirl 词典本体在 NixOS 侧 input-method.nix 的 rimeDataPkgs。
  # 只影响雾凇；万象不动。改完需重新部署 rime（首次因大词库会慢十几秒）。
  xdg.dataFile."fcitx5/rime/rime_ice.extended.dict.yaml".text = ''
    # Rime dictionary
    ---
    name: rime_ice.extended
    version: "2026.05.30"
    sort: by_weight
    import_tables:
      - rime_ice
      - zhwiki
      - moegirl
    ...
  '';
  xdg.dataFile."fcitx5/rime/rime_ice.custom.yaml".text = ''
    # 由 NixOS 管理：把雾凇词库换成含维基/萌娘的扩展词典。
    # 注意：rime_ice 词典名在 schema 里被引用两处，两处都要改指向扩展词典，
    # 否则未改的那处（部件拆字反查）会去找不存在的 rime_ice.reverse.bin 报错。
    patch:
      translator/dictionary: rime_ice.extended
      radical_reverse_lookup/dictionary: rime_ice.extended
  '';

  # 同样给万象(wanxiang)挂接维基/萌娘大词库。万象不能用「重定向 translator」的
  # 思路：wanxiang 词典名在 schema 里被多处引用（主翻译、user_dict_set、
  # add_user_dict，以及错词提示/辅码 lua），改名会让未改处去找不存在的
  # wanxiang.table.bin 报错。所以直接在用户目录覆盖 wanxiang.dict.yaml、保持
  # 名字不变，只在它的 import_tables 末尾追加 zhwiki/moegirl（实测 0 encode
  # 失败，无声调词条万象也能查到）。import 列表与上游一致（renming/wuzhong
  # 上游本就注释关闭）；上游若调整该列表，这里需同步。version 加 -ext 强制重部署。
  xdg.dataFile."fcitx5/rime/wanxiang.dict.yaml".text = ''
    # Rime dictionary
    ---
    name: wanxiang
    version: "LTS-ext"
    sort: by_weight
    use_preset_vocabulary: false
    import_tables:
      - dicts/zi
      - dicts/jichu
      - dicts/lianxiang
      - dicts/cuoyin
      - dicts/duoyin
      - dicts/shici
      - dicts/diming
      - zhwiki
      - moegirl
    ...
  '';

  # fcitx5 全局配置：按程序记忆输入状态，使终端等程序保持英文。
  # 注意：此文件由 home-manager 管理，fcitx5 配置工具的改动不会持久化。
  xdg.configFile."fcitx5/config".text = ''
    [Hotkey]
    EnumerateWithTriggerKeys=True
    EnumerateForwardKeys=
    EnumerateBackwardKeys=
    EnumerateSkipFirst=False
    ModifierOnlyKeyTimeout=252

    [Hotkey/TriggerKeys]
    0=Control+space
    1=Zenkaku_Hankaku
    2=Hangul

    [Hotkey/ActivateKeys]
    0=Hangul_Hanja

    [Hotkey/DeactivateKeys]
    0=Hangul_Romaja

    [Hotkey/AltTriggerKeys]
    0=Shift_L

    [Hotkey/EnumerateGroupForwardKeys]
    0=Super+space

    [Hotkey/EnumerateGroupBackwardKeys]
    0=Shift+Super+space

    [Hotkey/PrevPage]
    0=Up

    [Hotkey/NextPage]
    0=Down

    [Hotkey/PrevCandidate]
    0=Shift+Tab

    [Hotkey/NextCandidate]
    0=Tab

    [Hotkey/TogglePreedit]
    0=Control+Alt+P

    [Behavior]
    ActiveByDefault=False
    resetStateWhenFocusIn=No
    # 按程序独立保存输入状态：终端切到英文后不会被其它窗口带回中文
    ShareInputState=No
    PreeditEnabledByDefault=True
    ShowInputMethodInformation=True
    showInputMethodInformationWhenFocusIn=False
    CompactInputMethodInformation=True
    ShowFirstInputMethodInformation=True
    DefaultPageSize=5
    OverrideXkbOption=False
    CustomXkbOption=
    EnabledAddons=
    DisabledAddons=
    PreloadInputMethod=True
    AllowInputMethodForPassword=False
    ShowPreeditForPassword=False
    AutoSavePeriod=30
  '';
}
