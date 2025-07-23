import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/app_settings.dart';
import '../../../../core/config/wallpaper_config.dart';
import '../../../widgets/common/setting_item.dart';
import '../../../widgets/common/setting_card.dart';
import '../../home/widgets/background_system/starfield_test_page.dart';

/// 极简壁纸设置页面
/// 
/// 职责：
/// - 提供两种壁纸模式的选择：默认渐变和自定义图片
/// - 支持用户上传自定义壁纸图片
/// - 使用智能算法自动处理图片显示
/// 
/// 设计理念：
/// - 界面极简，只有核心功能
/// - 操作直观，一键设置
/// - 智能处理，无需用户干预
class SettingsWallpaperPage extends HookConsumerWidget {
  /// 构造函数
  const SettingsWallpaperPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final currentMode = settings.wallpaperMode;
    final currentBuiltinType = settings.builtinWallpaperType;
    final customPath = settings.customWallpaperPath;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('壁纸设置'),
        backgroundColor: Colors.purple.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 主要模式选择卡片
            _buildWallpaperModeCard(context, ref, currentMode),
            
            const SizedBox(height: 8),
            
            // 内置壁纸选择卡片（仅在选择内置壁纸时显示）
            if (currentMode == WallpaperMode.builtinWallpaper)
              _buildBuiltinWallpaperCard(context, ref, currentBuiltinType),
              
            const SizedBox(height: 8),
            
            // 自定义壁纸管理卡片（仅在选择自定义模式时显示）
            if (currentMode == WallpaperMode.customImage)
              _buildCustomWallpaperCard(context, ref, customPath),
            
          ],
        ),
      ),
    );
  }
  
  
  /// 构建主要壁纸模式选择卡片
  Widget _buildWallpaperModeCard(BuildContext context, WidgetRef ref, WallpaperMode currentMode) {
    return SettingCard(
      title: '壁纸类型',
      child: Column(
        children: [
          // 内置壁纸选项
          SettingItem(
            title: WallpaperMode.builtinWallpaper.displayName,
            subtitle: WallpaperMode.builtinWallpaper.description,
            leading: WallpaperMode.builtinWallpaper.icon,
            trailing: Radio<WallpaperMode>(
              value: WallpaperMode.builtinWallpaper,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appSettingsProvider).updateWallpaperMode(value);
                }
              },
            ),
            onTap: () {
              ref.read(appSettingsProvider).updateWallpaperMode(WallpaperMode.builtinWallpaper);
            },
          ),
          
          const Divider(height: 1),
          
          // 自定义图片背景选项
          SettingItem(
            title: WallpaperMode.customImage.displayName,
            subtitle: WallpaperMode.customImage.description,
            leading: WallpaperMode.customImage.icon,
            trailing: Radio<WallpaperMode>(
              value: WallpaperMode.customImage,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(appSettingsProvider).updateWallpaperMode(value);
                }
              },
            ),
            onTap: () {
              ref.read(appSettingsProvider).updateWallpaperMode(WallpaperMode.customImage);
            },
          ),
        ],
      ),
    );
  }
  
  /// 构建内置壁纸选择卡片
  Widget _buildBuiltinWallpaperCard(BuildContext context, WidgetRef ref, BuiltinWallpaperType currentType) {
    return SettingCard(
      title: '内置壁纸选择',
      child: Column(
        children: BuiltinWallpaperType.values.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          final isSelected = type == currentType;
          
          return Column(
            children: [
              if (index > 0) const Divider(height: 1),
              SettingItem(
                title: type.displayName,
                subtitle: type.description,
                leading: type.icon,
                trailing: Radio<BuiltinWallpaperType>(
                  value: type,
                  groupValue: currentType,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(appSettingsProvider).updateBuiltinWallpaperType(value);
                    }
                  },
                ),
                onTap: () {
                  ref.read(appSettingsProvider).updateBuiltinWallpaperType(type);
                },
              ),
              // 为选中的壁纸显示预览按钮
              if (isSelected && type == BuiltinWallpaperType.animatedStarfield) ...[
                const Divider(height: 1),
                SettingItem(
                  title: '预览星空效果',
                  subtitle: '打开全屏预览查看动态效果',
                  leading: Icons.preview,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StarfieldTestPage(),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建自定义壁纸管理卡片
  Widget _buildCustomWallpaperCard(BuildContext context, WidgetRef ref, String? customPath) {
    return SettingCard(
      title: '自定义壁纸管理',
      child: Column(
        children: [
          // 选择图片按钮
          SettingItem(
            title: '选择图片',
            subtitle: customPath != null ? '当前：${customPath.split('/').last}' : '未选择图片',
            leading: Icons.add_photo_alternate,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickCustomWallpaper(context, ref),
          ),
          
          // 如果已选择图片，显示额外选项
          if (customPath != null && customPath.isNotEmpty) ...[
            const Divider(height: 1),
            
            // 遮罩开关
            SwitchListTile(
              title: const Text('启用遮罩层'),
              subtitle: const Text('在壁纸上添加轻微遮罩，提升文字可读性'),
              value: ref.watch(appSettingsProvider).enableWallpaperOverlay,
              onChanged: (value) {
                ref.read(appSettingsProvider).updateEnableWallpaperOverlay(value);
              },
            ),
          ],
        ],
      ),
    );
  }
  
  
  /// 选择自定义壁纸
  Future<void> _pickCustomWallpaper(BuildContext context, WidgetRef ref) async {
    try {
      // 从相册选择图片
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2560,  // 高分辨率支持
        maxHeight: 1440, // 保持16:9比例
        imageQuality: 95, // 高质量压缩
      );
      
      if (image == null) return;
      
      // 直接使用选择的图片，使用智能显示算法自动适配
      await ref.read(appSettingsProvider).updateCustomWallpaperPath(image.path);
      
      // 如果当前不是自定义模式，自动切换
      final currentMode = ref.read(appSettingsProvider).wallpaperMode;
      if (currentMode != WallpaperMode.customImage) {
        await ref.read(appSettingsProvider).updateWallpaperMode(WallpaperMode.customImage);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('壁纸设置成功')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $error')),
        );
      }
    }
  }
}