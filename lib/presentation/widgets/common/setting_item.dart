/// 设置项通用组件
/// 
/// 提供统一的设置项样式，支持：
/// - 标题和副标题
/// - 前置图标
/// - 右侧内容
/// - 点击事件
library;

import 'package:flutter/material.dart';

/// 设置项组件
class SettingItem extends StatelessWidget {
  /// 主标题
  final String title;
  
  /// 副标题
  final String? subtitle;
  
  /// 前置图标
  final IconData? leading;
  
  /// 右侧内容
  final Widget? trailing;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 是否启用
  final bool enabled;
  
  /// 构造函数
  const SettingItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading != null 
        ? Icon(
            leading,
            color: enabled 
              ? Theme.of(context).primaryColor 
              : Colors.grey,
          )
        : null,
      title: Text(
        title,
        style: TextStyle(
          color: enabled 
            ? null 
            : Colors.grey,
        ),
      ),
      subtitle: subtitle != null 
        ? Text(
            subtitle!,
            style: TextStyle(
              color: enabled 
                ? Colors.grey.shade600 
                : Colors.grey.shade400,
            ),
          )
        : null,
      trailing: trailing ?? (onTap != null 
        ? Icon(
            Icons.chevron_right,
            color: enabled 
              ? Colors.grey.shade600 
              : Colors.grey.shade400,
          )
        : null),
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }
}