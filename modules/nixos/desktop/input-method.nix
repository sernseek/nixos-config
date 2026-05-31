{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      # 雾凇(rime_ice) + 万象(wanxiang) 方案数据必须打进 fcitx5-rime 自己的
      # RIME_DATA_DIR（编译期写死），rime 才能找到这些 schema；作为独立 addon
      # 列出不会生效（rime 不读 fcitx5 合并目录）。
      # 万象的智能长句靠语言模型 wanxiang-lts-zh-hans.gram，它不随包发布，
      # 由 home 侧 fcitx5.nix 声明式 fetch 到 rime 用户目录。
      # rime-data 基础包必须保留：它提供标准 default.yaml（punctuator/
      # key_binder 等预设），rime_ice 与 wanxiang 的 schema 都 __include 这些段；
      # 缺了它 fcitx5-rime 会兜底 touch 出一个空 default.yaml，导致两套方案
      # 编译失败（unresolved dependency: default:/punctuator、default:key_binder）。
      # zhwiki/moegirl 提供 zhwiki.dict.yaml、moegirl.dict.yaml（纯拼音编码，
      # 与雾凇兼容）。它们只是把词典文件放进共享目录；真正挂接到雾凇是在
      # home 侧 fcitx5.nix 用 rime_ice.extended.dict.yaml import 这两个表。
      # rime-moegirl 是 unfree（NC 许可），靠仓库已开的 allowUnfree。
      (fcitx5-rime.override {
        rimeDataPkgs = [
          rime-data
          rime-ice
          rime-wanxiang
          rime-zhwiki
          rime-moegirl
        ];
      })
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-configtool
    ];
  };
}
