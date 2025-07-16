/// 表情映射工具类
/// 
/// 提供后端emotion字段到emoji表情符号的映射功能
/// 支持21种表情类型，与Python后端完全一致
library;

/// 表情映射器
/// 
/// 负责将后端返回的emotion字段转换为对应的emoji表情符号
/// 完整支持Python后端定义的21种表情类型
class EmotionMapper {
  /// 表情映射表
  /// 
  /// 与Python后端emoji_map完全一致的映射关系：
  /// neutral, happy, laughing, funny, sad, angry, crying, loving, 
  /// embarrassed, surprised, shocked, thinking, winking, cool, 
  /// relaxed, delicious, kissy, confident, sleepy, silly, confused
  static const Map<String, String> _emotionMap = {
    'neutral': '😶',
    'happy': '🙂',
    'laughing': '😆',
    'funny': '😂',
    'sad': '😔',
    'angry': '😠',
    'crying': '😭',
    'loving': '😍',
    'embarrassed': '😳',
    'surprised': '😲',
    'shocked': '😱',
    'thinking': '🤔',
    'winking': '😉',
    'cool': '😎',
    'relaxed': '😌',
    'delicious': '🤤',
    'kissy': '😘',
    'confident': '😏',
    'sleepy': '😴',
    'silly': '😜',
    'confused': '🙄',
  };

  /// 默认表情 - 当emotion为空或不支持时使用
  static const String _defaultEmotion = 'happy';
  static const String _defaultEmoji = '🙂';

  /// 获取表情对应的emoji符号
  /// 
  /// 参数：
  /// - [emotion] 表情类型字符串（来自后端）
  /// 
  /// 返回：
  /// - 对应的emoji符号，如果不支持则返回默认表情
  static String getEmoji(String emotion) {
    if (emotion.isEmpty) {
      return _defaultEmoji;
    }
    
    return _emotionMap[emotion] ?? _defaultEmoji;
  }

  /// 检查是否支持指定的表情类型
  /// 
  /// 参数：
  /// - [emotion] 表情类型字符串
  /// 
  /// 返回：
  /// - true 如果支持该表情类型
  /// - false 如果不支持该表情类型
  static bool supportsEmotion(String emotion) {
    return _emotionMap.containsKey(emotion);
  }

  /// 获取所有支持的表情类型
  /// 
  /// 返回：
  /// - 支持的表情类型字符串列表
  static List<String> getSupportedEmotions() {
    return _emotionMap.keys.toList();
  }

  /// 获取所有表情符号
  /// 
  /// 返回：
  /// - 所有emoji符号列表
  static List<String> getAllEmojis() {
    return _emotionMap.values.toList();
  }

  /// 获取默认表情类型
  /// 
  /// 返回：
  /// - 默认表情类型字符串
  static String getDefaultEmotion() {
    return _defaultEmotion;
  }

  /// 获取默认emoji符号
  /// 
  /// 返回：
  /// - 默认emoji符号
  static String getDefaultEmoji() {
    return _defaultEmoji;
  }

  /// 根据emoji符号反向查找表情类型
  /// 
  /// 参数：
  /// - [emoji] emoji符号
  /// 
  /// 返回：
  /// - 对应的表情类型，如果未找到则返回null
  static String? getEmotionByEmoji(String emoji) {
    for (final entry in _emotionMap.entries) {
      if (entry.value == emoji) {
        return entry.key;
      }
    }
    return null;
  }

  /// 获取表情类型的显示名称（中文）
  /// 
  /// 参数：
  /// - [emotion] 表情类型字符串
  /// 
  /// 返回：
  /// - 表情类型的中文显示名称
  static String getEmotionDisplayName(String emotion) {
    switch (emotion) {
      case 'neutral':
        return '中性';
      case 'happy':
        return '高兴';
      case 'laughing':
        return '大笑';
      case 'funny':
        return '搞笑';
      case 'sad':
        return '悲伤';
      case 'angry':
        return '愤怒';
      case 'crying':
        return '哭泣';
      case 'loving':
        return '喜爱';
      case 'embarrassed':
        return '尴尬';
      case 'surprised':
        return '惊讶';
      case 'shocked':
        return '震惊';
      case 'thinking':
        return '思考';
      case 'winking':
        return '眨眼';
      case 'cool':
        return '酷';
      case 'relaxed':
        return '放松';
      case 'delicious':
        return '美味';
      case 'kissy':
        return '亲吻';
      case 'confident':
        return '自信';
      case 'sleepy':
        return '困倦';
      case 'silly':
        return '傻';
      case 'confused':
        return '困惑';
      default:
        return '未知';
    }
  }

  /// 获取表情映射统计信息
  /// 
  /// 返回：
  /// - 包含统计信息的Map
  static Map<String, dynamic> getStatistics() {
    return {
      'total_emotions': _emotionMap.length,
      'supported_emotions': _emotionMap.keys.toList(),
      'default_emotion': _defaultEmotion,
      'default_emoji': _defaultEmoji,
    };
  }

  /// 验证表情映射完整性
  /// 
  /// 检查是否所有必要的表情类型都已定义
  /// 
  /// 返回：
  /// - true 如果映射完整
  /// - false 如果缺少必要的表情类型
  static bool validateMapping() {
    // 检查是否包含基本的表情类型
    final requiredEmotions = [
      'neutral', 'happy', 'sad', 'angry', 'thinking', 'surprised'
    ];
    
    for (final emotion in requiredEmotions) {
      if (!_emotionMap.containsKey(emotion)) {
        return false;
      }
    }
    
    return true;
  }
}