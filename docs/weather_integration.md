# 天气集成文档

## 概述

项目已实现了一个完全解耦的天气系统，支持多种天气数据源切换。

## 架构设计

### 核心组件

1. **独立的天气服务层**
   - `Weather` 实体：通用天气数据模型
   - `WeatherRepository` 接口：抽象天气服务接口
   - 具体实现：`QWeatherRepository`（和风天气）、`MockWeatherRepository`（模拟数据）

2. **独立的UI组件**
   - `ClockDisplayWidget`：独立的时钟显示组件
   - `WeatherDisplayWidget`：独立的天气显示组件
   - `WeatherClockWidget`：组合时钟和天气的容器组件

### 设计优势

- **完全解耦**：时钟和天气可以独立使用
- **易于扩展**：添加新的天气源只需实现 `WeatherRepository` 接口
- **统一配置**：通过 `WeatherConfig` 管理所有天气相关配置
- **响应式更新**：使用 Riverpod 自动管理状态和更新

## 使用方式

### 1. 配置天气服务

#### 方式一：通过Web配置界面（推荐）

1. 在应用设置中打开「Web配置」页面
2. 扫描二维码或在浏览器访问显示的地址
3. 在「天气服务设置」部分：
   - 启用/禁用天气服务
   - 选择天气服务类型（模拟数据/和风天气）
   - 设置位置（**必须使用城市ID或经纬度坐标**）
     - 城市ID示例：`101010100`（北京）
     - 坐标示例：`116.41,39.92`（北京经纬度）
     - [查询城市ID](https://github.com/qwd/LocationList)
   - 设置更新间隔
   - 输入和风天气API Key

#### 方式二：通过应用内设置

天气设置已集成到应用的统一配置系统中，会自动保存和恢复。

```dart
// 程序化更新天气配置
final appSettings = ref.read(appSettingsProvider);
await appSettings.updateWeatherEnabled(true);
await appSettings.updateWeatherServiceType('qweather');
await appSettings.updateQweatherApiKey('your-api-key');
await appSettings.updateWeatherLocation('北京');
```

### 2. 单独使用天气组件

```dart
// 紧凑模式（图标+温度）
const WeatherDisplayWidget(
  mode: WeatherDisplayMode.compact,
)

// 扩展模式（包含描述和体感温度）
const WeatherDisplayWidget(
  mode: WeatherDisplayMode.extended,
)
```

### 3. 单独使用时钟组件

```dart
// 垂直布局
const ClockDisplayWidget(
  mode: ClockDisplayMode.vertical,
  showSeconds: false,
)

// 水平布局
const ClockDisplayWidget(
  mode: ClockDisplayMode.horizontal,
)
```

## 支持的天气服务

### 和风天气（已实现）
- API文档：https://dev.qweather.com/docs/api/
- 需要注册获取API密钥
- 支持国内外城市
- 免费版限制：1000次/天

**重要提示**：
- 位置参数必须使用城市ID（如：101010100）或经纬度坐标（如：116.41,39.92）
- 不支持直接使用城市名称（如："北京"、"Beijing"）
- 城市ID查询：https://github.com/qwd/LocationList

### OpenWeather（待实现）
- 国际化天气服务
- 支持更多语言和地区

### Mock服务（已实现）
- 用于开发和测试
- 不需要API密钥
- 返回随机但合理的天气数据

## 下一步计划

1. **添加天气缓存** - 减少API调用，提升性能
2. **实现OpenWeather** - 支持国际用户
3. **天气图标美化** - 使用自定义天气图标
4. **添加天气动画** - 根据天气显示动态背景
5. **位置自动检测** - 基于GPS自动获取天气

## API密钥申请

### 和风天气
1. 访问 https://console.qweather.com/
2. 注册账号并登录
3. 创建应用获取API Key
4. 在设置中配置API Key