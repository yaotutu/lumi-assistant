# 通知系统架构设计

## 概述

Lumi Assistant 的通知系统采用**统一通知管理架构**，支持多通知源、本地状态管理和可选的服务器同步。

## 架构设计

### 1. 核心组件

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Layer (通知气泡)                        │
├─────────────────────────────────────────────────────────────┤
│              UnifiedNotificationService                      │
│                  (统一通知管理服务)                           │
├─────────────────┬───────────────┬───────────────────────────┤
│   GotifySource  │ WeatherSource │   Other Sources...        │
│   (Gotify源)    │  (天气源)      │    (其他通知源)            │
└─────────────────┴───────────────┴───────────────────────────┘
```

### 2. 关键接口

#### INotificationSource (通知源接口)

```dart
abstract class INotificationSource {
  String get sourceId;        // 源标识
  String get sourceName;      // 源名称
  bool get supportsMarkAsRead; // 是否支持已读
  bool get supportsDelete;     // 是否支持删除
  
  // 操作方法
  Future<bool> markAsRead(String notificationId);
  Future<bool> deleteNotification(String notificationId);
  Future<List<UnifiedNotification>> getHistory();
}
```

#### UnifiedNotification (统一通知模型)

```dart
class UnifiedNotification {
  final String id;           // 唯一ID
  final String sourceId;     // 源ID
  final String originalId;   // 原始ID
  final String message;      // 消息内容
  bool isRead;              // 已读状态
  bool isReadSynced;        // 已读同步状态
  // ...
}
```

### 3. 状态管理策略

#### 本地状态持久化

- **已读状态**：存储在 SharedPreferences
- **删除记录**：记录已删除的通知ID，避免重复显示
- **自动清理**：超过保留期限的通知自动清理

#### 服务器同步

- **智能同步**：仅在通知源支持时同步
- **异步处理**：不阻塞UI操作
- **失败重试**：同步失败时保留本地状态

### 4. 操作流程

#### 标记已读

```
用户操作 → 更新本地状态 → UI立即响应 → 异步同步到服务器
```

#### 删除通知

```
用户操作 → 本地删除 → 记录删除状态 → 尝试服务器同步
```

## 通知源实现

### Gotify 通知源

- **支持功能**：删除通知
- **不支持功能**：标记已读（Gotify API 限制）
- **特殊处理**：已读状态仅在本地管理

### 扩展其他通知源

1. 实现 `INotificationSource` 接口
2. 注册到 `UnifiedNotificationService`
3. 处理特定源的API调用

## 使用示例

### 添加新通知源

```dart
// 1. 创建通知源
class WeatherNotificationSource implements INotificationSource {
  @override
  String get sourceId => 'weather';
  
  @override
  String get sourceName => '天气服务';
  
  // 实现其他方法...
}

// 2. 注册通知源
final weatherSource = WeatherNotificationSource();
UnifiedNotificationService.instance.registerSource(weatherSource);

// 3. 添加通知
final notification = UnifiedNotification(
  id: 'weather_001',
  sourceId: 'weather',
  message: '今天有雨，记得带伞',
  // ...
);
UnifiedNotificationService.instance.addNotification(notification);
```

### 批量操作

```dart
// 标记所有为已读
await UnifiedNotificationService.instance.markAllAsRead();

// 清理已读通知
await UnifiedNotificationService.instance.clearRead();

// 清空所有通知
await UnifiedNotificationService.instance.clearAll();
```

## 优势

1. **统一管理**：所有通知源使用相同的接口和操作
2. **灵活扩展**：轻松添加新的通知源
3. **离线支持**：本地状态管理，不依赖网络
4. **智能同步**：根据通知源能力自动处理
5. **性能优化**：本地操作立即响应，异步同步

## 后续优化

1. **通知分组**：按源、时间、类型分组显示
2. **过滤功能**：支持按条件过滤通知
3. **批量操作优化**：提升大量通知的处理性能
4. **同步队列**：离线操作队列，恢复网络后自动同步
5. **通知模板**：支持自定义通知显示样式