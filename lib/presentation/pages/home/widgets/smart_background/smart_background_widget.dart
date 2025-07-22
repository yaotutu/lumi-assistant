import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'smart_background_controller.dart';
import 'modes/clock_background.dart';
import 'modes/photo_album_background.dart';
import 'modes/info_panel_background.dart';
import 'modes/calendar_background.dart';
import 'modes/weather_background.dart';
import 'modes/minimal_background.dart';

/// 智能背景主组件
/// 
/// 职责：
/// - 根据当前模式显示对应的背景内容
/// - 管理背景切换动画
/// - 提供统一的背景接口
/// 
/// 依赖：SmartBackgroundController（背景模式管理）
/// 使用场景：作为HomePage的背景层使用
class SmartBackgroundWidget extends ConsumerWidget {
  /// 构造函数
  const SmartBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听当前背景模式
    final currentMode = ref.watch(currentBackgroundModeProvider);
    
    return AnimatedSwitcher(
      // 切换动画时长
      duration: const Duration(milliseconds: 500),
      
      // 切换动画类型：淡入淡出
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      
      // 根据当前模式显示对应的背景组件
      child: _buildBackgroundByMode(currentMode),
    );
  }
  
  /// 根据模式构建对应的背景组件
  /// 
  /// 参数：
  /// - [mode] 当前背景模式
  /// 
  /// 返回：对应模式的背景Widget
  Widget _buildBackgroundByMode(SmartBackgroundMode mode) {
    // 每个背景组件都需要唯一的key，确保AnimatedSwitcher正确工作
    switch (mode) {
      case SmartBackgroundMode.clock:
        return ClockBackground(
          key: ValueKey(mode),
        );
        
      case SmartBackgroundMode.photoAlbum:
        return PhotoAlbumBackground(
          key: ValueKey(mode),
        );
        
      case SmartBackgroundMode.infoPanel:
        return InfoPanelBackground(
          key: ValueKey(mode),
        );
        
      case SmartBackgroundMode.calendar:
        return CalendarBackground(
          key: ValueKey(mode),
        );
        
      case SmartBackgroundMode.weather:
        return WeatherBackground(
          key: ValueKey(mode),
        );
        
      case SmartBackgroundMode.minimal:
        return MinimalBackground(
          key: ValueKey(mode),
        );
    }
  }
}

/// 背景模式切换控制器组件
/// 
/// 职责：
/// - 提供背景模式切换的UI控制
/// - 显示当前模式信息
/// - 支持手动切换和自动切换设置
/// 
/// 使用场景：可选的背景控制面板，通常在设置页面或调试模式下显示
class BackgroundModeController extends ConsumerWidget {
  /// 构造函数
  const BackgroundModeController({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取背景控制器和当前状态
    final backgroundState = ref.watch(smartBackgroundProvider);
    final backgroundController = ref.read(smartBackgroundProvider.notifier);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.wallpaper,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '智能背景',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 当前模式信息
          Row(
            children: [
              Icon(
                backgroundState.currentMode.icon,
                color: Colors.white.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                backgroundState.currentMode.displayName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              
              // 手动切换按钮
              IconButton(
                onPressed: () {
                  backgroundController.switchToNextMode();
                },
                icon: Icon(
                  Icons.skip_next,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 20,
                ),
                tooltip: '切换到下一模式',
              ),
            ],
          ),
          
          // 模式描述
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              backgroundState.currentMode.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 自动切换设置
          Row(
            children: [
              Text(
                '自动切换',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Switch(
                value: backgroundState.autoSwitchEnabled,
                onChanged: (value) {
                  backgroundController.setAutoSwitchEnabled(value);
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          
          // 切换间隔设置（仅在自动切换开启时显示）
          if (backgroundState.autoSwitchEnabled) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '切换间隔',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                DropdownButton<int>(
                  value: backgroundState.autoSwitchInterval.inMinutes,
                  items: [1, 3, 5, 10, 15, 30]
                      .map((minutes) => DropdownMenuItem(
                            value: minutes,
                            child: Text(
                              '$minutes分钟',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ))
                      .toList(),
                  onChanged: (minutes) {
                    if (minutes != null) {
                      backgroundController.setAutoSwitchInterval(
                        Duration(minutes: minutes),
                      );
                    }
                  },
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                  dropdownColor: Colors.grey[800],
                  underline: Container(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}