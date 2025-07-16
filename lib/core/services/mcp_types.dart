/// MCP协议类型定义标准
/// 
/// 基于JSON Schema规范，确保跨语言兼容性
/// 参考：https://json-schema.org/understanding-json-schema/reference/type.html
class McpTypes {
  /// 百分比类型 (0-100的整数)
  /// 
  /// 用于：音量、亮度、进度等百分比值
  /// 映射：Java int, Dart int, Python int, JavaScript number
  static const Map<String, dynamic> percentage = {
    'type': 'integer',
    'minimum': 0,
    'maximum': 100,
    'description': '百分比值，范围0-100的整数'
  };
  
  /// 浮点百分比类型 (0.0-100.0的浮点数)
  /// 
  /// 用于：需要精确控制的场景
  /// 映射：Java double, Dart double, Python float, JavaScript number
  static const Map<String, dynamic> floatPercentage = {
    'type': 'number',
    'minimum': 0.0,
    'maximum': 100.0,
    'description': '浮点百分比值，范围0.0-100.0'
  };
  
  /// 设备状态枚举
  /// 
  /// 用于：开关状态、模式选择等
  /// 映射：Java String, Dart String, Python str, JavaScript string
  static const Map<String, dynamic> deviceState = {
    'type': 'string',
    'enum': ['on', 'off', 'auto'],
    'description': '设备状态：on(开启), off(关闭), auto(自动)'
  };
  
  /// 设备名称类型
  /// 
  /// 用于：设备标识、名称等
  /// 映射：Java String, Dart String, Python str, JavaScript string
  static const Map<String, dynamic> deviceName = {
    'type': 'string',
    'minLength': 1,
    'maxLength': 50,
    'description': '设备名称，长度1-50字符'
  };
  
  /// 时间戳类型
  /// 
  /// 用于：时间记录、定时任务等
  /// 映射：Java long, Dart int, Python int, JavaScript number
  static const Map<String, dynamic> timestamp = {
    'type': 'integer',
    'minimum': 0,
    'description': 'Unix时间戳，毫秒级'
  };
  
  /// 创建百分比属性定义
  /// 
  /// [name] 属性名称
  /// [description] 属性描述
  /// [useFloat] 是否使用浮点数，默认false（整数）
  static Map<String, dynamic> createPercentageProperty(
    String name, 
    String description, 
    {bool useFloat = false}
  ) {
    final baseType = useFloat ? floatPercentage : percentage;
    return {
      name: {
        ...baseType,
        'description': description,
      }
    };
  }
  
  /// 创建枚举属性定义
  /// 
  /// [name] 属性名称
  /// [description] 属性描述
  /// [values] 枚举值列表
  static Map<String, dynamic> createEnumProperty(
    String name,
    String description,
    List<String> values
  ) {
    return {
      name: {
        'type': 'string',
        'enum': values,
        'description': description,
      }
    };
  }
}

/// MCP工具参数构建器
/// 
/// 提供类型安全的参数定义构建
class McpParameterBuilder {
  final Map<String, dynamic> _properties = {};
  final List<String> _required = [];
  
  /// 添加百分比参数
  McpParameterBuilder addPercentage(String name, String description, {bool required = false}) {
    _properties.addAll(McpTypes.createPercentageProperty(name, description));
    if (required) _required.add(name);
    return this;
  }
  
  /// 添加浮点百分比参数
  McpParameterBuilder addFloatPercentage(String name, String description, {bool required = false}) {
    _properties.addAll(McpTypes.createPercentageProperty(name, description, useFloat: true));
    if (required) _required.add(name);
    return this;
  }
  
  /// 添加枚举参数
  McpParameterBuilder addEnum(String name, String description, List<String> values, {bool required = false}) {
    _properties.addAll(McpTypes.createEnumProperty(name, description, values));
    if (required) _required.add(name);
    return this;
  }
  
  /// 添加字符串参数
  McpParameterBuilder addString(String name, String description, {bool required = false}) {
    _properties[name] = {
      'type': 'string',
      'description': description,
    };
    if (required) _required.add(name);
    return this;
  }
  
  /// 构建参数定义
  Map<String, dynamic> build() {
    return {
      'type': 'object',
      'properties': _properties,
      'required': _required,
    };
  }
}

/// 类型验证工具
class McpTypeValidator {
  /// 验证百分比值
  static bool isValidPercentage(dynamic value) {
    if (value is int) {
      return value >= 0 && value <= 100;
    }
    if (value is double) {
      return value >= 0.0 && value <= 100.0;
    }
    return false;
  }
  
  /// 验证枚举值
  static bool isValidEnum(dynamic value, List<String> allowedValues) {
    return value is String && allowedValues.contains(value);
  }
  
  /// 将动态值转换为整数百分比
  static int toIntPercentage(dynamic value) {
    if (value is int) {
      return value.clamp(0, 100);
    }
    if (value is double) {
      return value.round().clamp(0, 100);
    }
    throw ArgumentError('Invalid percentage value: $value');
  }
  
  /// 将动态值转换为浮点百分比
  static double toFloatPercentage(dynamic value) {
    if (value is int) {
      return value.toDouble().clamp(0.0, 100.0);
    }
    if (value is double) {
      return value.clamp(0.0, 100.0);
    }
    throw ArgumentError('Invalid percentage value: $value');
  }
}