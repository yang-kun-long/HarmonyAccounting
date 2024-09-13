# 记账本（ArkTS）

### 简介

本项目示例展示了如何使用关系型数据库（ArkTS）实现账目管理功能，包含了分析统计功能。：

#### 记账页面
![image](screenshots/device/记账页面.gif)

#### 统计页面
![image](screenshots/device/统计页面.gif)

### 环境搭建
1. 安装DevEco Studio，详情请参考[下载](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-software-download-V5)和[安装软件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-software-install-V5)。
2. 设置DevEco Studio开发环境，DevEco Studio开发环境需要依赖于网络环境，需要连接上网络才能确保工具的正常使用，详情请参考配置[开发环境](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-environment-config-V5)。
3. 开发者可以参考以下链接，完成设备调试的相关配置：
   - [使用真机进行调试](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-debug-device-V5)
   - [使用模拟器进行调试](https://developer.huawei.com/consumer/cn/doc/HiCar-Guides/get-device-0000001135423484)
4. 第三方库的安装：进入项目目录，打开命令行，输入以下命令：

    `ohpm install @mcui/mccharts`


### 使用说明

1. 底部导航栏，点击“记账”图标，进入记账页面，也即应用首页。点击“统计”图标，进入统计页面。
2. 在应用首页，点击右下角“添加”图标，在弹出的窗口中选择账目类型并填写金额，点击时间弹出时间选择弹框，点击确定选择时间，再点击“确定”按钮添加一条账目。
3. 在应用首页，点击右上角“编辑”图标，选中想要删除的账目，点击下方“删除”图标，删除选择的账目。
4. 在应用首页，点击想要编辑的账目，在弹出的窗口中更改账目类型或金额，点击“确定”按钮修改一条账目。
5. 在应用首页，点击搜索栏，填写想要查找的账目金额，点击“搜索”图标后下方刷新为金额为查找金额的账目，搜索栏为空时显示全部账目。
6. 在统计页面，点击上个月，点击下个月，切换月份。
7. 统计页面分两个部分，一个是月度账目分类统计，饼状图展示。另一个是月度账目收支金额统计，直方图展示。
8. 点击饼状图的某一类，可以查看该类账目的详细数据。
9. 点击直方图的某一个月份，可以查看该月份账目的详细数据。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS NEXT Developer Beta1及以上。
3. DevEco Studio版本：DevEco Studio NEXT Developer Beta1及以上。
4. HarmonyOS SDK版本：HarmonyOS NEXT Developer Beta1 SDK及以上。
