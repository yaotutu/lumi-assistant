// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_warning.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeatherWarning _$WeatherWarningFromJson(Map<String, dynamic> json) {
  return _WeatherWarning.fromJson(json);
}

/// @nodoc
mixin _$WeatherWarning {
  /// 预警ID，唯一标识
  String get id => throw _privateConstructorUsedError;

  /// 预警发布单位，如"北京市气象台"
  String? get sender => throw _privateConstructorUsedError;

  /// 预警标题，如"北京市气象台发布暴雨橙色预警"
  String get title => throw _privateConstructorUsedError;

  /// 预警详细文字描述
  String get text => throw _privateConstructorUsedError;

  /// 预警级别
  /// - Minor: 蓝色
  /// - Moderate: 黄色
  /// - Severe: 橙色
  /// - Extreme: 红色
  String get severity => throw _privateConstructorUsedError;

  /// 预警类型编码，如"11B06"
  String get type => throw _privateConstructorUsedError;

  /// 预警类型名称，如"暴雨"
  String get typeName => throw _privateConstructorUsedError;

  /// 预警开始时间，ISO8601格式
  String get startTime => throw _privateConstructorUsedError;

  /// 预警结束时间，ISO8601格式
  String get endTime => throw _privateConstructorUsedError;

  /// 状态：active-预警中，update-预警更新
  String? get status => throw _privateConstructorUsedError;

  /// 预警等级：蓝色、黄色、橙色、红色
  String? get level => throw _privateConstructorUsedError;

  /// Serializes this WeatherWarning to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherWarning
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherWarningCopyWith<WeatherWarning> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherWarningCopyWith<$Res> {
  factory $WeatherWarningCopyWith(
          WeatherWarning value, $Res Function(WeatherWarning) then) =
      _$WeatherWarningCopyWithImpl<$Res, WeatherWarning>;
  @useResult
  $Res call(
      {String id,
      String? sender,
      String title,
      String text,
      String severity,
      String type,
      String typeName,
      String startTime,
      String endTime,
      String? status,
      String? level});
}

/// @nodoc
class _$WeatherWarningCopyWithImpl<$Res, $Val extends WeatherWarning>
    implements $WeatherWarningCopyWith<$Res> {
  _$WeatherWarningCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherWarning
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = freezed,
    Object? title = null,
    Object? text = null,
    Object? severity = null,
    Object? type = null,
    Object? typeName = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = freezed,
    Object? level = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      typeName: null == typeName
          ? _value.typeName
          : typeName // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeatherWarningImplCopyWith<$Res>
    implements $WeatherWarningCopyWith<$Res> {
  factory _$$WeatherWarningImplCopyWith(_$WeatherWarningImpl value,
          $Res Function(_$WeatherWarningImpl) then) =
      __$$WeatherWarningImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? sender,
      String title,
      String text,
      String severity,
      String type,
      String typeName,
      String startTime,
      String endTime,
      String? status,
      String? level});
}

/// @nodoc
class __$$WeatherWarningImplCopyWithImpl<$Res>
    extends _$WeatherWarningCopyWithImpl<$Res, _$WeatherWarningImpl>
    implements _$$WeatherWarningImplCopyWith<$Res> {
  __$$WeatherWarningImplCopyWithImpl(
      _$WeatherWarningImpl _value, $Res Function(_$WeatherWarningImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeatherWarning
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sender = freezed,
    Object? title = null,
    Object? text = null,
    Object? severity = null,
    Object? type = null,
    Object? typeName = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? status = freezed,
    Object? level = freezed,
  }) {
    return _then(_$WeatherWarningImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as String?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      typeName: null == typeName
          ? _value.typeName
          : typeName // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherWarningImpl implements _WeatherWarning {
  const _$WeatherWarningImpl(
      {required this.id,
      this.sender,
      required this.title,
      required this.text,
      required this.severity,
      required this.type,
      required this.typeName,
      required this.startTime,
      required this.endTime,
      this.status,
      this.level});

  factory _$WeatherWarningImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherWarningImplFromJson(json);

  /// 预警ID，唯一标识
  @override
  final String id;

  /// 预警发布单位，如"北京市气象台"
  @override
  final String? sender;

  /// 预警标题，如"北京市气象台发布暴雨橙色预警"
  @override
  final String title;

  /// 预警详细文字描述
  @override
  final String text;

  /// 预警级别
  /// - Minor: 蓝色
  /// - Moderate: 黄色
  /// - Severe: 橙色
  /// - Extreme: 红色
  @override
  final String severity;

  /// 预警类型编码，如"11B06"
  @override
  final String type;

  /// 预警类型名称，如"暴雨"
  @override
  final String typeName;

  /// 预警开始时间，ISO8601格式
  @override
  final String startTime;

  /// 预警结束时间，ISO8601格式
  @override
  final String endTime;

  /// 状态：active-预警中，update-预警更新
  @override
  final String? status;

  /// 预警等级：蓝色、黄色、橙色、红色
  @override
  final String? level;

  @override
  String toString() {
    return 'WeatherWarning(id: $id, sender: $sender, title: $title, text: $text, severity: $severity, type: $type, typeName: $typeName, startTime: $startTime, endTime: $endTime, status: $status, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherWarningImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.typeName, typeName) ||
                other.typeName == typeName) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.level, level) || other.level == level));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, sender, title, text,
      severity, type, typeName, startTime, endTime, status, level);

  /// Create a copy of WeatherWarning
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherWarningImplCopyWith<_$WeatherWarningImpl> get copyWith =>
      __$$WeatherWarningImplCopyWithImpl<_$WeatherWarningImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherWarningImplToJson(
      this,
    );
  }
}

abstract class _WeatherWarning implements WeatherWarning {
  const factory _WeatherWarning(
      {required final String id,
      final String? sender,
      required final String title,
      required final String text,
      required final String severity,
      required final String type,
      required final String typeName,
      required final String startTime,
      required final String endTime,
      final String? status,
      final String? level}) = _$WeatherWarningImpl;

  factory _WeatherWarning.fromJson(Map<String, dynamic> json) =
      _$WeatherWarningImpl.fromJson;

  /// 预警ID，唯一标识
  @override
  String get id;

  /// 预警发布单位，如"北京市气象台"
  @override
  String? get sender;

  /// 预警标题，如"北京市气象台发布暴雨橙色预警"
  @override
  String get title;

  /// 预警详细文字描述
  @override
  String get text;

  /// 预警级别
  /// - Minor: 蓝色
  /// - Moderate: 黄色
  /// - Severe: 橙色
  /// - Extreme: 红色
  @override
  String get severity;

  /// 预警类型编码，如"11B06"
  @override
  String get type;

  /// 预警类型名称，如"暴雨"
  @override
  String get typeName;

  /// 预警开始时间，ISO8601格式
  @override
  String get startTime;

  /// 预警结束时间，ISO8601格式
  @override
  String get endTime;

  /// 状态：active-预警中，update-预警更新
  @override
  String? get status;

  /// 预警等级：蓝色、黄色、橙色、红色
  @override
  String? get level;

  /// Create a copy of WeatherWarning
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherWarningImplCopyWith<_$WeatherWarningImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeatherWarningResponse _$WeatherWarningResponseFromJson(
    Map<String, dynamic> json) {
  return _WeatherWarningResponse.fromJson(json);
}

/// @nodoc
mixin _$WeatherWarningResponse {
  /// API状态码
  String get code => throw _privateConstructorUsedError;

  /// 预警列表，可能为空
  List<WeatherWarning> get warning => throw _privateConstructorUsedError;

  /// 更新时间
  String? get updateTime => throw _privateConstructorUsedError;

  /// 响应时间
  String? get fxLink => throw _privateConstructorUsedError;

  /// Serializes this WeatherWarningResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeatherWarningResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeatherWarningResponseCopyWith<WeatherWarningResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeatherWarningResponseCopyWith<$Res> {
  factory $WeatherWarningResponseCopyWith(WeatherWarningResponse value,
          $Res Function(WeatherWarningResponse) then) =
      _$WeatherWarningResponseCopyWithImpl<$Res, WeatherWarningResponse>;
  @useResult
  $Res call(
      {String code,
      List<WeatherWarning> warning,
      String? updateTime,
      String? fxLink});
}

/// @nodoc
class _$WeatherWarningResponseCopyWithImpl<$Res,
        $Val extends WeatherWarningResponse>
    implements $WeatherWarningResponseCopyWith<$Res> {
  _$WeatherWarningResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeatherWarningResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? warning = null,
    Object? updateTime = freezed,
    Object? fxLink = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      warning: null == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as List<WeatherWarning>,
      updateTime: freezed == updateTime
          ? _value.updateTime
          : updateTime // ignore: cast_nullable_to_non_nullable
              as String?,
      fxLink: freezed == fxLink
          ? _value.fxLink
          : fxLink // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeatherWarningResponseImplCopyWith<$Res>
    implements $WeatherWarningResponseCopyWith<$Res> {
  factory _$$WeatherWarningResponseImplCopyWith(
          _$WeatherWarningResponseImpl value,
          $Res Function(_$WeatherWarningResponseImpl) then) =
      __$$WeatherWarningResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      List<WeatherWarning> warning,
      String? updateTime,
      String? fxLink});
}

/// @nodoc
class __$$WeatherWarningResponseImplCopyWithImpl<$Res>
    extends _$WeatherWarningResponseCopyWithImpl<$Res,
        _$WeatherWarningResponseImpl>
    implements _$$WeatherWarningResponseImplCopyWith<$Res> {
  __$$WeatherWarningResponseImplCopyWithImpl(
      _$WeatherWarningResponseImpl _value,
      $Res Function(_$WeatherWarningResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeatherWarningResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? warning = null,
    Object? updateTime = freezed,
    Object? fxLink = freezed,
  }) {
    return _then(_$WeatherWarningResponseImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      warning: null == warning
          ? _value._warning
          : warning // ignore: cast_nullable_to_non_nullable
              as List<WeatherWarning>,
      updateTime: freezed == updateTime
          ? _value.updateTime
          : updateTime // ignore: cast_nullable_to_non_nullable
              as String?,
      fxLink: freezed == fxLink
          ? _value.fxLink
          : fxLink // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeatherWarningResponseImpl implements _WeatherWarningResponse {
  const _$WeatherWarningResponseImpl(
      {required this.code,
      final List<WeatherWarning> warning = const [],
      this.updateTime,
      this.fxLink})
      : _warning = warning;

  factory _$WeatherWarningResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeatherWarningResponseImplFromJson(json);

  /// API状态码
  @override
  final String code;

  /// 预警列表，可能为空
  final List<WeatherWarning> _warning;

  /// 预警列表，可能为空
  @override
  @JsonKey()
  List<WeatherWarning> get warning {
    if (_warning is EqualUnmodifiableListView) return _warning;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_warning);
  }

  /// 更新时间
  @override
  final String? updateTime;

  /// 响应时间
  @override
  final String? fxLink;

  @override
  String toString() {
    return 'WeatherWarningResponse(code: $code, warning: $warning, updateTime: $updateTime, fxLink: $fxLink)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeatherWarningResponseImpl &&
            (identical(other.code, code) || other.code == code) &&
            const DeepCollectionEquality().equals(other._warning, _warning) &&
            (identical(other.updateTime, updateTime) ||
                other.updateTime == updateTime) &&
            (identical(other.fxLink, fxLink) || other.fxLink == fxLink));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code,
      const DeepCollectionEquality().hash(_warning), updateTime, fxLink);

  /// Create a copy of WeatherWarningResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeatherWarningResponseImplCopyWith<_$WeatherWarningResponseImpl>
      get copyWith => __$$WeatherWarningResponseImplCopyWithImpl<
          _$WeatherWarningResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeatherWarningResponseImplToJson(
      this,
    );
  }
}

abstract class _WeatherWarningResponse implements WeatherWarningResponse {
  const factory _WeatherWarningResponse(
      {required final String code,
      final List<WeatherWarning> warning,
      final String? updateTime,
      final String? fxLink}) = _$WeatherWarningResponseImpl;

  factory _WeatherWarningResponse.fromJson(Map<String, dynamic> json) =
      _$WeatherWarningResponseImpl.fromJson;

  /// API状态码
  @override
  String get code;

  /// 预警列表，可能为空
  @override
  List<WeatherWarning> get warning;

  /// 更新时间
  @override
  String? get updateTime;

  /// 响应时间
  @override
  String? get fxLink;

  /// Create a copy of WeatherWarningResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeatherWarningResponseImplCopyWith<_$WeatherWarningResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
