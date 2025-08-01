// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_warning.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeatherWarningImpl _$$WeatherWarningImplFromJson(Map<String, dynamic> json) =>
    _$WeatherWarningImpl(
      id: json['id'] as String,
      sender: json['sender'] as String?,
      title: json['title'] as String,
      text: json['text'] as String,
      severity: json['severity'] as String,
      type: json['type'] as String,
      typeName: json['typeName'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String?,
      level: json['level'] as String?,
    );

Map<String, dynamic> _$$WeatherWarningImplToJson(
        _$WeatherWarningImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'title': instance.title,
      'text': instance.text,
      'severity': instance.severity,
      'type': instance.type,
      'typeName': instance.typeName,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'status': instance.status,
      'level': instance.level,
    };

_$WeatherWarningResponseImpl _$$WeatherWarningResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$WeatherWarningResponseImpl(
      code: json['code'] as String,
      warning: (json['warning'] as List<dynamic>?)
              ?.map((e) => WeatherWarning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      updateTime: json['updateTime'] as String?,
      fxLink: json['fxLink'] as String?,
    );

Map<String, dynamic> _$$WeatherWarningResponseImplToJson(
        _$WeatherWarningResponseImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'warning': instance.warning,
      'updateTime': instance.updateTime,
      'fxLink': instance.fxLink,
    };
