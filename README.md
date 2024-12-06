# **[AHD2-URP-Improved](https://github.com/ahd2/AHD2-URP-Improved)**
基于URP(Unity2021.3)的个人修改管线。

## 基本信息

* 基础URP版本v12.1
* 基础Unity版本2021.3

## 修改部分

* 

## TODO

* 高斯模糊后处理还是用了两次ResolveAA。似乎只要是绘制到ColorAttachment，不管是Blit还是Draw，都会有ResolveAA。
* 使用Load优化屏幕坐标采样贴图。
* 目前不考虑支持VR。
