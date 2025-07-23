/// 设置分组通用组件
/// 
/// 用于将相关的设置项分组显示
/// 提供统一的分组标题和分割线样式
library;

import 'package:flutter/material.dart';

/// 设置分组组件
class SettingSection extends StatelessWidget {
  /// 分组标题
  final String title;
  
  /// 分组内容
  final List<Widget> children;
  
  /// 边距
  final EdgeInsets? margin;
  
  /// 构造函数
  const SettingSection({
    super.key,
    required this.title,
    required this.children,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          
          // 分组内容
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}