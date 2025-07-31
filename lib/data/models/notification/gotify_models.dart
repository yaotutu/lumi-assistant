import 'package:json_annotation/json_annotation.dart';

part 'gotify_models.g.dart';

/// Gotify 消息模型
/// 
/// 对应 Gotify API 返回的消息数据结构
@JsonSerializable()
class GotifyMessage {
  /// 消息ID
  final int id;
  
  /// 应用ID
  final int appid;
  
  /// 消息内容
  final String message;
  
  /// 消息标题
  final String? title;
  
  /// 优先级（0-10）
  final int priority;
  
  /// 额外数据
  final Map<String, dynamic>? extras;
  
  /// 创建时间
  final DateTime date;

  GotifyMessage({
    required this.id,
    required this.appid,
    required this.message,
    this.title,
    required this.priority,
    this.extras,
    required this.date,
  });

  /// 从 JSON 创建实例
  factory GotifyMessage.fromJson(Map<String, dynamic> json) => 
      _$GotifyMessageFromJson(json);

  /// 转换为 JSON
  Map<String, dynamic> toJson() => _$GotifyMessageToJson(this);
}

/// Gotify 应用信息模型
@JsonSerializable()
class GotifyApplication {
  /// 应用ID
  final int id;
  
  /// 应用名称
  final String name;
  
  /// 应用描述
  final String? description;
  
  /// 应用令牌
  final String? token;
  
  /// 图片URL
  final String? image;

  GotifyApplication({
    required this.id,
    required this.name,
    this.description,
    this.token,
    this.image,
  });

  factory GotifyApplication.fromJson(Map<String, dynamic> json) => 
      _$GotifyApplicationFromJson(json);

  Map<String, dynamic> toJson() => _$GotifyApplicationToJson(this);
}

/// Gotify 分页响应模型
@JsonSerializable(genericArgumentFactories: true)
class GotifyPagedResponse<T> {
  /// 消息列表
  final List<T> messages;
  
  /// 分页信息
  final GotifyPaging paging;

  GotifyPagedResponse({
    required this.messages,
    required this.paging,
  });

  factory GotifyPagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$GotifyPagedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => 
      _$GotifyPagedResponseToJson(this, toJsonT);
}

/// Gotify 分页信息
@JsonSerializable()
class GotifyPaging {
  /// 每页数量
  final int limit;
  
  /// 下一页URL
  final String? next;
  
  /// 当前页大小
  final int size;
  
  /// 自从时间戳
  final int? since;

  GotifyPaging({
    required this.limit,
    this.next,
    required this.size,
    this.since,
  });

  factory GotifyPaging.fromJson(Map<String, dynamic> json) => 
      _$GotifyPagingFromJson(json);

  Map<String, dynamic> toJson() => _$GotifyPagingToJson(this);
}

/// Gotify WebSocket 消息模型
@JsonSerializable()
class GotifyWebSocketMessage {
  /// 消息ID
  final int id;
  
  /// 应用ID
  final int appid;
  
  /// 消息内容
  final String message;
  
  /// 消息标题
  final String? title;
  
  /// 优先级
  final int priority;
  
  /// 创建时间
  final String date;

  GotifyWebSocketMessage({
    required this.id,
    required this.appid,
    required this.message,
    this.title,
    required this.priority,
    required this.date,
  });

  factory GotifyWebSocketMessage.fromJson(Map<String, dynamic> json) => 
      _$GotifyWebSocketMessageFromJson(json);

  Map<String, dynamic> toJson() => _$GotifyWebSocketMessageToJson(this);
}