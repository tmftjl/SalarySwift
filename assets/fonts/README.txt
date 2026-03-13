# 字体说明

当前仓库已包含 PDF 导出所需中文字体：
- SimHei.ttf

说明：
- `pubspec.yaml` 已声明 `assets/fonts/` 目录，这个字体会随 App 一起打包。
- PDF 导出固定读取这个 TrueType 字体，避免中文内容落回默认 Latin1 字体。
