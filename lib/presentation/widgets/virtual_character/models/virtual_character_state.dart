/// 虚拟人物状态模型
/// 
/// 定义虚拟人物的完整状态信息，包括表情、状态、渲染配置等
/// 用于在不同渲染器间传递统一的状态数据
library;

import 'character_enums.dart';

/// 虚拟人物状态模型
/// 
/// 包含虚拟人物的完整状态信息：
/// - 表情类型（来自后端emotion字段）
/// - 当前状态（idle/listening/thinking/speaking/sleeping）
/// - 显示文本和缩放比例
/// - 渲染器特定配置
class VirtualCharacterState {
  /// 表情类型，对应后端返回的emotion字段
  /// 
  /// 支持21种表情类型：
  /// neutral, happy, laughing, funny, sad, angry, crying, loving, 
  /// embarrassed, surprised, shocked, thinking, winking, cool, 
  /// relaxed, delicious, kissy, confident, sleepy, silly, confused
  final String emotion;
  
  /// 当前状态，定义虚拟人物的交互状态
  final CharacterStatus status;
  
  /// 状态显示文本，如果为null则使用默认文本
  final String? statusText;
  
  /// 缩放比例，用于动画效果和不同状态下的尺寸调整
  final double scale;
  
  /// 是否正在执行动画
  final bool isAnimating;
  
  /// 渲染器特定配置
  /// 
  /// 不同渲染器可能需要不同的配置参数：
  /// - text渲染器：fontSize, textColor等
  /// - image渲染器：imagePath, imageSize等
  /// - gif渲染器：gifPath, frameRate等
  /// - rive渲染器：rivePath, stateMachine等
  /// - live2d渲染器：modelPath, animations等
  final Map<String, dynamic> rendererConfig;
  
  /// 构造函数
  const VirtualCharacterState({
    this.emotion = 'neutral',
    this.status = CharacterStatus.idle,
    this.statusText,
    this.scale = 1.0,
    this.isAnimating = false,
    this.rendererConfig = const {},
  });
  
  /// 复制并修改状态
  VirtualCharacterState copyWith({
    String? emotion,
    CharacterStatus? status,
    String? statusText,
    double? scale,
    bool? isAnimating,
    Map<String, dynamic>? rendererConfig,
  }) {
    return VirtualCharacterState(
      emotion: emotion ?? this.emotion,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      scale: scale ?? this.scale,
      isAnimating: isAnimating ?? this.isAnimating,
      rendererConfig: rendererConfig ?? this.rendererConfig,
    );
  }
  
  /// 获取有效的状态文本
  /// 
  /// 如果statusText为null，则返回status对应的默认文本
  String get effectiveStatusText {
    return statusText ?? status.statusText;
  }
  
  /// 获取有效的表情emoji
  /// 
  /// 如果emotion为空或无效，则返回status对应的默认表情
  String get effectiveEmoji {
    if (emotion.isEmpty || emotion == 'neutral') {
      return status.defaultEmoji;
    }
    return emotion;
  }
  
  /// 创建待机状态
  static VirtualCharacterState idle({
    String emotion = 'neutral',
    Map<String, dynamic>? rendererConfig,
  }) {
    return VirtualCharacterState(
      emotion: emotion,
      status: CharacterStatus.idle,
      scale: 1.0,
      isAnimating: false,
      rendererConfig: rendererConfig ?? {},
    );
  }
  
  /// 创建听取状态
  static VirtualCharacterState listening({
    String emotion = 'neutral',
    Map<String, dynamic>? rendererConfig,
  }) {
    return VirtualCharacterState(
      emotion: emotion,
      status: CharacterStatus.listening,
      scale: 1.1,
      isAnimating: true,
      rendererConfig: rendererConfig ?? {},
    );
  }
  
  /// 创建思考状态
  static VirtualCharacterState thinking({
    String emotion = 'thinking',
    Map<String, dynamic>? rendererConfig,
  }) {
    return VirtualCharacterState(
      emotion: emotion,
      status: CharacterStatus.thinking,
      scale: 1.0,
      isAnimating: true,
      rendererConfig: rendererConfig ?? {},
    );
  }
  
  /// 创建说话状态
  static VirtualCharacterState speaking({
    required String emotion,
    Map<String, dynamic>? rendererConfig,
  }) {
    return VirtualCharacterState(
      emotion: emotion,
      status: CharacterStatus.speaking,
      scale: 1.0,
      isAnimating: true,
      rendererConfig: rendererConfig ?? {},
    );
  }
  
  /// 创建休眠状态
  static VirtualCharacterState sleeping({
    Map<String, dynamic>? rendererConfig,
  }) {
    return VirtualCharacterState(
      emotion: 'sleepy',
      status: CharacterStatus.sleeping,
      scale: 0.8,
      isAnimating: false,
      rendererConfig: rendererConfig ?? {},
    );
  }
  
  /// 转换为字符串，用于调试
  @override
  String toString() {
    return 'VirtualCharacterState('
        'emotion: $emotion, '
        'status: $status, '
        'statusText: $statusText, '
        'scale: $scale, '
        'isAnimating: $isAnimating, '
        'rendererConfig: $rendererConfig'
        ')';
  }
  
  /// 比较两个状态是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VirtualCharacterState &&
        other.emotion == emotion &&
        other.status == status &&
        other.statusText == statusText &&
        other.scale == scale &&
        other.isAnimating == isAnimating &&
        _mapEquals(other.rendererConfig, rendererConfig);
  }
  
  /// 计算状态的哈希值
  @override
  int get hashCode {
    return emotion.hashCode ^
        status.hashCode ^
        statusText.hashCode ^
        scale.hashCode ^
        isAnimating.hashCode ^
        rendererConfig.hashCode;
  }
  
  /// 比较两个Map是否相等
  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (String key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}