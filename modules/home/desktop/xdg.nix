{ lib, ... }:
let
  browser = "brave-browser.desktop";
  fileManager = [ "org.gnome.Nautilus.desktop" ];
  imageViewer = [ "org.gnome.Loupe.desktop" ];
  onlyOffice = "onlyoffice-desktopeditors.desktop";
  documentViewer = [ "org.gnome.Papers.desktop" ];
  textEditor = [ "org.gnome.TextEditor.desktop" ];

  writer = [ "writer.desktop" ];
  calc = [ "calc.desktop" ];
  impress = [ "impress.desktop" ];
  draw = [ "draw.desktop" ];

  browserMimes = {
    "text/html" = [ browser ];
    "application/xhtml+xml" = [ browser ];
    "application/x-extension-htm" = [ browser ];
    "application/x-extension-html" = [ browser ];
    "application/x-extension-shtml" = [ browser ];
    "application/x-extension-xhtml" = [ browser ];
    "application/x-extension-xht" = [ browser ];
    "x-scheme-handler/about" = [ browser ];
    "x-scheme-handler/chrome" = [ browser ];
    "x-scheme-handler/chromium" = [ browser ];
    "x-scheme-handler/ftp" = [ browser ];
    "x-scheme-handler/http" = [ browser ];
    "x-scheme-handler/https" = [ browser ];
    "x-scheme-handler/webcal" = [ browser ];
    "x-scheme-handler/unknown" = [ browser ];
  };

  fileManagerMimes = {
    "inode/directory" = fileManager;
  };

  imageViewerMimes = {
    "image/apng" = imageViewer;
    "image/avif" = imageViewer;
    "image/bmp" = imageViewer;
    "image/gif" = imageViewer;
    "image/heic" = imageViewer;
    "image/jpeg" = imageViewer;
    "image/jp2" = imageViewer;
    "image/jxl" = imageViewer;
    "image/png" = imageViewer;
    "image/qoi" = imageViewer;
    "image/svg+xml" = imageViewer;
    "image/svg+xml-compressed" = imageViewer;
    "image/tiff" = imageViewer;
    "image/vnd.microsoft.icon" = imageViewer;
    "image/webp" = imageViewer;
    "image/x-dds" = imageViewer;
    "image/x-exr" = imageViewer;
    "image/x-portable-anymap" = imageViewer;
    "image/x-portable-bitmap" = imageViewer;
    "image/x-portable-graymap" = imageViewer;
    "image/x-portable-pixmap" = imageViewer;
    "image/x-qoi" = imageViewer;
    "image/x-tga" = imageViewer;
    "image/x-win-bitmap" = imageViewer;
    "image/x-xbitmap" = imageViewer;
    "image/x-xpixmap" = imageViewer;
  };

  documentViewerMimes = {
    "application/illustrator" = documentViewer;
    "application/pdf" = documentViewer;
    "application/vnd.comicbook+zip" = documentViewer;
    "application/vnd.comicbook-rar" = documentViewer;
    "application/x-bzpdf" = documentViewer;
    "application/x-cb7" = documentViewer;
    "application/x-cbr" = documentViewer;
    "application/x-cbt" = documentViewer;
    "application/x-cbz" = documentViewer;
    "application/x-ext-cb7" = documentViewer;
    "application/x-ext-cbr" = documentViewer;
    "application/x-ext-cbt" = documentViewer;
    "application/x-ext-cbz" = documentViewer;
    "application/x-ext-djv" = documentViewer;
    "application/x-ext-djvu" = documentViewer;
    "application/x-ext-pdf" = documentViewer;
    "application/x-gzpdf" = documentViewer;
    "application/x-xzpdf" = documentViewer;
    "image/vnd.djvu" = documentViewer;
    "image/vnd.djvu+multipage" = documentViewer;
  };

  textEditorMimes = {
    "application/x-zerosize" = textEditor;
    "text/markdown" = textEditor;
    "text/plain" = textEditor;
  };

  libreOfficeMimes = {
    # Writer documents.
    "application/msword" = writer;
    "application/msword-template" = writer;
    "application/rtf" = writer;
    "application/vnd.apple.pages" = writer;
    "application/vnd.ms-word" = writer;
    "application/vnd.ms-word.document.macroEnabled.12" = writer;
    "application/vnd.ms-word.template.macroEnabled.12" = writer;
    "application/vnd.oasis.opendocument.text" = writer;
    "application/vnd.oasis.opendocument.text-flat-xml" = writer;
    "application/vnd.oasis.opendocument.text-template" = writer;
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = writer;
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template" = writer;
    "application/vnd.sun.xml.writer" = writer;
    "application/vnd.sun.xml.writer.template" = writer;
    "application/wps-office.wps" = writer;
    "application/wps-office.wpt" = writer;
    "application/x-fictionbook+xml" = writer;
    "application/x-hwp" = writer;
    "text/rtf" = writer;

    # Calc spreadsheets.
    "application/csv" = calc;
    "application/tab-separated-values" = calc;
    "application/vnd.apple.numbers" = calc;
    "application/vnd.ms-excel" = calc;
    "application/vnd.ms-excel.sheet.binary.macroEnabled.12" = calc;
    "application/vnd.ms-excel.sheet.macroEnabled.12" = calc;
    "application/vnd.ms-excel.template.macroEnabled.12" = calc;
    "application/vnd.oasis.opendocument.spreadsheet" = calc;
    "application/vnd.oasis.opendocument.spreadsheet-flat-xml" = calc;
    "application/vnd.oasis.opendocument.spreadsheet-template" = calc;
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = calc;
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template" = calc;
    "application/vnd.sun.xml.calc" = calc;
    "application/wps-office.et" = calc;
    "application/wps-office.ett" = calc;
    "text/csv" = calc;
    "text/tab-separated-values" = calc;

    # Impress presentations.
    "application/vnd.apple.keynote" = impress;
    "application/vnd.ms-powerpoint" = impress;
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12" = impress;
    "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" = impress;
    "application/vnd.ms-powerpoint.template.macroEnabled.12" = impress;
    "application/vnd.oasis.opendocument.presentation" = impress;
    "application/vnd.oasis.opendocument.presentation-flat-xml" = impress;
    "application/vnd.oasis.opendocument.presentation-template" = impress;
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = impress;
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = impress;
    "application/vnd.openxmlformats-officedocument.presentationml.template" = impress;
    "application/vnd.sun.xml.impress" = impress;
    "application/wps-office.dps" = impress;
    "application/wps-office.dpt" = impress;

    # Draw/PDF documents.
    "application/pdf" = draw;
    "application/vnd.oasis.opendocument.graphics" = draw;
  };

  onlyOfficeMimes = lib.unique (
    builtins.attrNames libreOfficeMimes
    ++ [
      "application/epub+zip"
      "application/oxps"
      "application/vnd.ms-visio.drawing.main+xml"
      "application/vnd.ms-visio.drawing.macroEnabled.main+xml"
      "application/vnd.ms-visio.stencil.main+xml"
      "application/vnd.ms-visio.stencil.macroEnabled.main+xml"
      "application/vnd.ms-visio.template.main+xml"
      "application/vnd.ms-visio.template.macroEnabled.main+xml"
      "application/vnd.ms-xpsdocument"
      "image/vnd.djvu"
      "text/markdown"
      "text/plain"
      "x-scheme-handler/oo-office"
    ]
  );

  gnomeMimes = fileManagerMimes // imageViewerMimes // documentViewerMimes // textEditorMimes;
in
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = browserMimes // libreOfficeMimes // gnomeMimes;
    associations.added = browserMimes // libreOfficeMimes // gnomeMimes;
    associations.removed = lib.genAttrs onlyOfficeMimes (_: [ onlyOffice ]) // {
      "inode/directory" = [
        "thunar.desktop"
        "org.kde.dolphin.desktop"
      ];
    };
  };

  xdg.configFile."fcitx5/rime/default.custom.yaml".text = ''
    patch:
      schema_list:
        - schema: flypy
  '';
}
