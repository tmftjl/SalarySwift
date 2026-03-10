# 字体说明

当前仓库已包含 PDF 导出所需中文字体：
- NotoSansSC-Regular.otf
- NotoSansSC-Bold.otf

说明：
- `pubspec.yaml` 已声明 `assets/fonts/` 目录，这两个字体会随 App 一起打包。
- PDF 导出固定读取这两个字体文件，不再做系统字体或内置字体回退。
