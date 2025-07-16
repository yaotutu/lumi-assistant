/// 虚拟人物渲染器抽象接口
/// 
/// 定义虚拟人物渲染器的统一接口，支持不同类型的渲染器实现
/// 包括文字、图片、GIF、Rive、Live2D等渲染方式
library;

import 'package:flutter/widgets.dart';
import '../models/virtual_character_state.dart';
import '../models/character_enums.dart';

/// 虚拟人物渲染器抽象基类
/// 
/// 所有虚拟人物渲染器都必须实现此接口，提供统一的渲染方法
/// 支持状态更新、表情切换、动画效果等功能
abstract class VirtualCharacterRenderer {
  /// 渲染器类型标识
  RendererType get type;
  
  /// 渲染虚拟人物
  /// 
  /// 根据传入的状态信息渲染对应的虚拟人物界面
  /// 
  /// 参数：
  /// - [state] 虚拟人物当前状态
  /// 
  /// 返回：
  /// - 渲染后的Widget组件
  Widget render(VirtualCharacterState state);
  
  /// 更新表情
  /// 
  /// 当收到后端返回的emotion字段时调用此方法更新表情
  /// 
  /// 参数：
  /// - [emotion] 表情类型字符串
  void updateEmotion(String emotion);
  
  /// 更新状态
  /// 
  /// 当虚拟人物状态发生变化时调用此方法
  /// 
  /// 参数：
  /// - [status] 新的状态类型
  void updateStatus(CharacterStatus status);
  
  /// 启动动画
  /// 
  /// 开始执行动画效果，如脉动、缩放等
  void startAnimation();
  
  /// 停止动画
  /// 
  /// 停止当前执行的动画效果
  void stopAnimation();
  
  /// 释放资源
  /// 
  /// 清理渲染器使用的资源，如动画控制器、图片缓存等
  void dispose();
  
  /// 检查是否支持指定的表情类型
  /// 
  /// 参数：
  /// - [emotion] 表情类型字符串
  /// 
  /// 返回：
  /// - true 如果支持该表情类型
  /// - false 如果不支持该表情类型
  bool supportsEmotion(String emotion);
  
  /// 检查是否支持指定的状态类型
  /// 
  /// 参数：
  /// - [status] 状态类型
  /// 
  /// 返回：
  /// - true 如果支持该状态类型
  /// - false 如果不支持该状态类型
  bool supportsStatus(CharacterStatus status);
  
  /// 获取渲染器配置
  /// 
  /// 返回当前渲染器的配置信息
  /// 
  /// 返回：
  /// - 配置信息Map
  Map<String, dynamic> getConfiguration();
  
  /// 设置渲染器配置
  /// 
  /// 更新渲染器的配置信息
  /// 
  /// 参数：
  /// - [config] 新的配置信息
  void setConfiguration(Map<String, dynamic> config);
  
  /// 预加载资源
  /// 
  /// 预加载渲染器需要的资源，如图片、动画文件等
  /// 用于提高渲染性能和用户体验
  /// 
  /// 返回：
  /// - Future`<void>` 异步加载完成的标识
  Future<void> preloadResources();
  
  /// 获取支持的表情类型列表
  /// 
  /// 返回：
  /// - 支持的表情类型字符串列表
  List<String> getSupportedEmotions();
  
  /// 获取支持的状态类型列表
  /// 
  /// 返回：
  /// - 支持的状态类型列表
  List<CharacterStatus> getSupportedStatuses();
}