// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gotify_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GotifyMessage _$GotifyMessageFromJson(Map<String, dynamic> json) =>
    GotifyMessage(
      id: (json['id'] as num).toInt(),
      appid: (json['appid'] as num).toInt(),
      message: json['message'] as String,
      title: json['title'] as String?,
      priority: (json['priority'] as num).toInt(),
      extras: json['extras'] as Map<String, dynamic>?,
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$GotifyMessageToJson(GotifyMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appid': instance.appid,
      'message': instance.message,
      'title': instance.title,
      'priority': instance.priority,
      'extras': instance.extras,
      'date': instance.date.toIso8601String(),
    };

GotifyApplication _$GotifyApplicationFromJson(Map<String, dynamic> json) =>
    GotifyApplication(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      token: json['token'] as String?,
      image: json['image'] as String?,
    );

Map<String, dynamic> _$GotifyApplicationToJson(GotifyApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'token': instance.token,
      'image': instance.image,
    };

GotifyPagedResponse<T> _$GotifyPagedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    GotifyPagedResponse<T>(
      messages: (json['messages'] as List<dynamic>).map(fromJsonT).toList(),
      paging: GotifyPaging.fromJson(json['paging'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GotifyPagedResponseToJson<T>(
  GotifyPagedResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'messages': instance.messages.map(toJsonT).toList(),
      'paging': instance.paging,
    };

GotifyPaging _$GotifyPagingFromJson(Map<String, dynamic> json) => GotifyPaging(
      limit: (json['limit'] as num).toInt(),
      next: json['next'] as String?,
      size: (json['size'] as num).toInt(),
      since: (json['since'] as num?)?.toInt(),
    );

Map<String, dynamic> _$GotifyPagingToJson(GotifyPaging instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'next': instance.next,
      'size': instance.size,
      'since': instance.since,
    };

GotifyWebSocketMessage _$GotifyWebSocketMessageFromJson(
        Map<String, dynamic> json) =>
    GotifyWebSocketMessage(
      id: (json['id'] as num).toInt(),
      appid: (json['appid'] as num).toInt(),
      message: json['message'] as String,
      title: json['title'] as String?,
      priority: (json['priority'] as num).toInt(),
      date: json['date'] as String,
    );

Map<String, dynamic> _$GotifyWebSocketMessageToJson(
        GotifyWebSocketMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appid': instance.appid,
      'message': instance.message,
      'title': instance.title,
      'priority': instance.priority,
      'date': instance.date,
    };
