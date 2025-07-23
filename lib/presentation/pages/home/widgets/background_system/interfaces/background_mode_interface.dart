import 'package:flutter/material.dart';

/// 背景模式接口
/// 
/// 定义所有背景模式必须实现的基础接口
/// 为未来的复杂背景功能提供统一的规范
abstract class BackgroundModeInterface {
  /// 背景模式名称
  String get modeName;
  
  /// 背景模式图标
  IconData get modeIcon;
  
  /// 背景模式描述
  String get modeDescription;
  
  /// 是否支持自动更新
  bool get supportsAutoUpdate;
  
  /// 是否支持用户交互（注意：背景层应该完全不可交互）
  bool get supportsInteraction => false;
  
  /// 构建背景模式的主要内容
  Widget buildContent(BuildContext context);
  
  /// 初始化背景模式（如数据加载、定时器设置等）
  Future<void> initialize();
  
  /// 清理资源
  void dispose();
  
  /// 暂停背景模式（如暂停动画、停止数据更新等）
  void pause();
  
  /// 恢复背景模式
  void resume();
  
  /// 更新配置
  void updateConfig(Map<String, dynamic> config);
}

/// 时间背景模式接口
/// 
/// 专门针对时间相关背景功能的扩展接口
abstract class TimeBackgroundInterface extends BackgroundModeInterface {
  /// 时区设置
  String get timeZone;
  
  /// 时间格式（12小时制或24小时制）
  bool get use24HourFormat;
  
  /// 是否显示秒数
  bool get showSeconds;
  
  /// 是否显示日期
  bool get showDate;
  
  /// 是否显示农历
  bool get showLunarCalendar;
  
  /// 获取当前时间
  DateTime getCurrentTime();
  
  /// 格式化时间显示
  String formatTime(DateTime time);
  
  /// 格式化日期显示
  String formatDate(DateTime time);
  
  /// 检查是否为节假日
  bool isHoliday(DateTime date);
  
  /// 获取节假日名称
  String? getHolidayName(DateTime date);
}

/// 天气背景模式接口
/// 
/// 专门针对天气相关背景功能的扩展接口
abstract class WeatherBackgroundInterface extends BackgroundModeInterface {
  /// 当前城市
  String get currentCity;
  
  /// 天气数据更新间隔（分钟）
  int get updateIntervalMinutes;
  
  /// 是否显示天气动画
  bool get enableWeatherAnimation;
  
  /// 是否显示详细天气信息
  bool get showDetailedInfo;
  
  /// 获取当前天气数据
  Future<WeatherData?> getCurrentWeather();
  
  /// 获取天气预报数据
  Future<List<WeatherForecast>> getWeatherForecast();
  
  /// 根据天气状况获取背景色彩
  List<Color> getWeatherColors(String weatherCondition);
  
  /// 构建天气动画效果
  Widget buildWeatherAnimation(String weatherCondition);
}

/// 电子相册背景模式接口
/// 
/// 专门针对相册相关背景功能的扩展接口
abstract class PhotoAlbumBackgroundInterface extends BackgroundModeInterface {
  /// 相册目录路径
  List<String> get albumPaths;
  
  /// 照片切换间隔（秒）
  int get switchIntervalSeconds;
  
  /// 过渡动画时长（毫秒）
  int get transitionDurationMs;
  
  /// 是否随机显示
  bool get randomOrder;
  
  /// 是否显示照片信息
  bool get showPhotoInfo;
  
  /// 获取相册中的所有照片
  Future<List<PhotoItem>> getPhotos();
  
  /// 获取当前显示的照片
  PhotoItem? getCurrentPhoto();
  
  /// 切换到下一张照片
  void nextPhoto();
  
  /// 切换到上一张照片
  void previousPhoto();
  
  /// 构建照片过渡动画
  Widget buildPhotoTransition(PhotoItem from, PhotoItem to);
}

/// 日历背景模式接口
/// 
/// 专门针对日历相关背景功能的扩展接口
abstract class CalendarBackgroundInterface extends BackgroundModeInterface {
  /// 当前显示的月份
  DateTime get currentMonth;
  
  /// 是否显示农历
  bool get showLunarCalendar;
  
  /// 是否显示节假日
  bool get showHolidays;
  
  /// 是否显示事件提醒
  bool get showEvents;
  
  /// 获取指定月份的日历数据
  Future<CalendarData> getCalendarData(DateTime month);
  
  /// 获取指定日期的事件列表
  Future<List<CalendarEvent>> getEventsForDate(DateTime date);
  
  /// 检查是否为工作日
  bool isWorkingDay(DateTime date);
  
  /// 获取节假日信息
  HolidayInfo? getHolidayInfo(DateTime date);
  
  /// 构建日历网格
  Widget buildCalendarGrid(DateTime month);
}

/// 系统信息背景模式接口
/// 
/// 专门针对系统信息相关背景功能的扩展接口
abstract class SystemInfoBackgroundInterface extends BackgroundModeInterface {
  /// 信息更新间隔（秒）
  int get updateIntervalSeconds;
  
  /// 是否显示CPU使用率
  bool get showCpuUsage;
  
  /// 是否显示内存使用情况
  bool get showMemoryUsage;
  
  /// 是否显示网络状态
  bool get showNetworkStatus;
  
  /// 是否显示电池信息
  bool get showBatteryInfo;
  
  /// 获取系统信息
  Future<SystemInfo> getSystemInfo();
  
  /// 获取网络状态
  Future<NetworkStatus> getNetworkStatus();
  
  /// 获取电池信息
  Future<BatteryInfo> getBatteryInfo();
  
  /// 构建系统信息显示
  Widget buildSystemInfoDisplay(SystemInfo info);
}

// ============ 数据模型定义 ============

/// 天气数据模型
class WeatherData {
  final String city;
  final String condition;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String description;
  final DateTime updateTime;
  
  const WeatherData({
    required this.city,
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.updateTime,
  });
}

/// 天气预报模型
class WeatherForecast {
  final DateTime date;
  final String condition;
  final double highTemp;
  final double lowTemp;
  final String description;
  
  const WeatherForecast({
    required this.date,
    required this.condition,
    required this.highTemp,
    required this.lowTemp,
    required this.description,
  });
}

/// 照片项模型
class PhotoItem {
  final String path;
  final String name;
  final DateTime? dateTaken;
  final String? location;
  final Map<String, dynamic>? metadata;
  
  const PhotoItem({
    required this.path,
    required this.name,
    this.dateTaken,
    this.location,
    this.metadata,
  });
}

/// 日历数据模型
class CalendarData {
  final DateTime month;
  final List<CalendarDay> days;
  final List<HolidayInfo> holidays;
  
  const CalendarData({
    required this.month,
    required this.days,
    required this.holidays,
  });
}

/// 日历日期模型
class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isWeekend;
  final bool isHoliday;
  final List<CalendarEvent> events;
  
  const CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isWeekend,
    required this.isHoliday,
    required this.events,
  });
}

/// 日历事件模型
class CalendarEvent {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String? description;
  final Color? color;
  
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.color,
  });
}

/// 节假日信息模型
class HolidayInfo {
  final DateTime date;
  final String name;
  final String type; // 国定假日、传统节日等
  final bool isOffDay; // 是否为休息日
  
  const HolidayInfo({
    required this.date,
    required this.name,
    required this.type,
    required this.isOffDay,
  });
}

/// 系统信息模型
class SystemInfo {
  final double cpuUsage;
  final double memoryUsage;
  final double totalMemory;
  final double usedMemory;
  final double storageUsage;
  final double totalStorage;
  final DateTime updateTime;
  
  const SystemInfo({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.totalMemory,
    required this.usedMemory,
    required this.storageUsage,
    required this.totalStorage,
    required this.updateTime,
  });
}

/// 网络状态模型
class NetworkStatus {
  final bool isConnected;
  final String connectionType; // WiFi, Mobile, Ethernet等
  final String? networkName;
  final double? signalStrength;
  final double uploadSpeed;
  final double downloadSpeed;
  
  const NetworkStatus({
    required this.isConnected,
    required this.connectionType,
    this.networkName,
    this.signalStrength,
    required this.uploadSpeed,
    required this.downloadSpeed,
  });
}

/// 电池信息模型
class BatteryInfo {
  final double batteryLevel;
  final bool isCharging;
  final String batteryStatus; // Charging, Discharging, Full等
  final int? estimatedTimeRemaining; // 剩余时间（分钟）
  
  const BatteryInfo({
    required this.batteryLevel,
    required this.isCharging,
    required this.batteryStatus,
    this.estimatedTimeRemaining,
  });
}