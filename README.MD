![image](https://github.com/TongFangyuan/IMGPickerManager/blob/master/IMGPickerManager.png)

![version](https://img.shields.io/badge/version-v0.1.0-green.svg)
![liscense](https://img.shields.io/badge/license-MIT-lightgrey.svg)
![Language](https://img.shields.io/badge/Language-%20Objective%20C%20-blue.svg)

一个集成简单、无依赖、高效、轻量级、持续更新的图片选择第三方框架

----------------------------------------

特性
-----

- [x] 多选图片，包括普通图片、gif图片选择
- [x] 实时预览
- [ ] 3D Touch 预览(开发中...)

### 更多特性

有更多需求的朋友欢迎 [新建 Issues](https://github.com/TongFangyuan/IMGPickerManager/issues/new)，目前更多特性本人也在积极开发中...


环境要求
----

- iOS 8.0 及以上
- xcode 8.0 及以上

如何使用
----

```

#import "IMGPickerManagerHeader.h"
...
[IMGPickerManager startChoose:^(NSArray<PHAsset *> *results, NSError *error) {
    if (!error) {
        NSLog(@"user chosse %@",results);
    }else {
        NSLog(@"chosse error: %@",error.localizedDescription);
    }
}];

```

安装
----

- [x] 手动
- [ ] cocopods集成

### 手动集成
将`IMGPickerManager`文件夹直接拖到项目中就可以了

### cocopods集成
功能上架中...


Licenses
----
All source code is licensed under the [MIT License](https://github.com/TongFangyuan/IMGPickerManager/blob/master/LICENSE).

