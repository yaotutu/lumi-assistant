/// 设置卡片通用组件
/// 
/// 提供统一的卡片样式用于设置页面
/// 支持图标、标题、内容和点击事件
library;

import 'package:flutter/material.dart';

/// 设置卡片组件
class SettingCard extends StatelessWidget {
  /// 卡片标题
  final String title;
  
  /// 标题图标
  final IconData? icon;
  
  /// 图标颜色
  final Color? iconColor;
  
  /// 卡片内容
  final Widget child;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 内边距
  final EdgeInsets? padding;
  
  /// 构造函数
  const SettingCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.iconColor,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  // 图标
                  if (icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (iconColor ?? Colors.blue).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  // 标题
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // 右箭头（如果有点击事件）
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade600,
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 内容
              child,
            ],
          ),
        ),
      ),
    );
  }
}