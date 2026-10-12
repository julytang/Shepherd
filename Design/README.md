# 设计资源

在此保存 Claude Design 生成的原始设计文件、可运行原型、截图及导出资源。
建议每次设计建立一个有语义的子目录，例如 `onboarding/`，附上简短说明和来源。

这个目录不参与 App 编译。确认采用的图标、颜色和图片应放入对应 App 的
`Shepherd/Assets.xcassets`；两端实际共用的资源再加入 `ShepherdKit` 的 SwiftPM
资源目录，并在 `Package.swift` 中声明 resources，通过 `Bundle.module` 访问。

不要把原型的 node_modules、构建缓存、API 密钥或账号信息提交到仓库。
大型视频和设计二进制文件增多时，再引入 Git LFS。
