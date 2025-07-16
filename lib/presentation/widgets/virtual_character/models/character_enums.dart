/// 虚拟人物相关的枚举定义
/// 
/// 包含人物状态、渲染器类型等枚举，用于统一管理虚拟人物的各种状态类型
library;

/// 虚拟人物状态枚举
/// 
/// 定义虚拟人物在不同交互场景下的状态：
/// - [idle] 待机状态，默认状态，等待用户交互
/// - [listening] 听取状态，正在接收用户输入或语音
/// - [thinking] 思考状态，正在处理用户请求
/// - [speaking] 说话状态，正在输出回应内容
/// - [sleeping] 休眠状态，长时间无交互后的节能状态
enum CharacterStatus {
  /// 待机状态 - 默认状态，等待用户交互
  idle,
  
  /// 听取状态 - 正在接收用户输入或语音
  listening,
  
  /// 思考状态 - 正在处理用户请求
  thinking,
  
  /// 说话状态 - 正在输出回应内容
  speaking,
  
  /// 休眠状态 - 长时间无交互后的节能状态
  sleeping,
}

/// 虚拟人物渲染器类型枚举
/// 
/// 定义支持的渲染器类型，支持渐进式升级：
/// - [text] 文字+Emoji渲染器，轻量级实现
/// - [image] 静态图片渲染器，支持PNG/JPG格式
/// - [gif] 动态GIF渲染器，支持简单动画
/// - [rive] Rive矢量动画渲染器，高质量动画
/// - [live2d] Live2D动画渲染器，高级动画效果
enum RendererType {
  /// 文字+Emoji渲染器 - 轻量级实现，当前默认类型
  text,
  
  /// 静态图片渲染器 - 支持PNG/JPG格式
  image,
  
  /// 动态GIF渲染器 - 支持简单动画
  gif,
  
  /// Rive矢量动画渲染器 - 高质量动画
  rive,
  
  /// Live2D动画渲染器 - 高级动画效果
  live2d,
}

/// 虚拟人物状态扩展方法
extension CharacterStatusExtension on CharacterStatus {
  /// 获取状态对应的默认文字描述
  String get statusText {
    switch (this) {
      case CharacterStatus.idle:
        return '等待中...';
      case CharacterStatus.listening:
        return '正在听...';
      case CharacterStatus.thinking:
        return '思考中...';
      case CharacterStatus.speaking:
        return '正在回答...';
      case CharacterStatus.sleeping:
        return '休眠中...';
    }
  }
  
  /// 获取状态对应的默认表情emoji
  String get defaultEmoji {
    switch (this) {
      case CharacterStatus.idle:
        return '😶';
      case CharacterStatus.listening:
        return '👂';
      case CharacterStatus.thinking:
        return '🤔';
      case CharacterStatus.speaking:
        return '🙂';
      case CharacterStatus.sleeping:
        return '😴';
    }
  }
}

/// 渲染器类型扩展方法
extension RendererTypeExtension on RendererType {
  /// 获取渲染器类型的描述名称
  String get displayName {
    switch (this) {
      case RendererType.text:
        return '文字表情';
      case RendererType.image:
        return '静态图片';
      case RendererType.gif:
        return '动态图片';
      case RendererType.rive:
        return 'Rive动画';
      case RendererType.live2d:
        return 'Live2D动画';
    }
  }
  
  /// 检查渲染器是否支持动画
  bool get supportsAnimation {
    switch (this) {
      case RendererType.text:
      case RendererType.image:
        return false;
      case RendererType.gif:
      case RendererType.rive:
      case RendererType.live2d:
        return true;
    }
  }
}