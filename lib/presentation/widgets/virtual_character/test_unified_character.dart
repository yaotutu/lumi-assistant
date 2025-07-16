/// 统一虚拟人物测试组件
/// 
/// 用于测试和验证统一虚拟人物组件功能
/// 展示Riverpod状态管理和统一组件的协同工作
library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'virtual_character.dart';
import 'models/character_enums.dart';
import '../../providers/virtual_character_provider.dart';
import '../../../core/utils/emotion_mapper.dart';

/// 统一虚拟人物测试组件
/// 
/// 展示统一虚拟人物组件的功能和状态管理
class TestUnifiedCharacter extends HookConsumerWidget {
  const TestUnifiedCharacter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听虚拟人物状态
    final characterState = ref.watch(virtualCharacterProvider);
    final characterNotifier = ref.read(virtualCharacterProvider.notifier);
    
    // 当前选中的渲染器类型
    final selectedRendererType = useState(RendererType.text);
    
    // 当前选中的预设配置
    final selectedPreset = useState('default');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('统一虚拟人物测试'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 主要展示区域
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade900,
                      Colors.purple.shade900,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 虚拟人物组件
                      VirtualCharacterBuilder()
                          .renderer(selectedRendererType.value)
                          .preset(selectedPreset.value)
                          .constraints(const BoxConstraints(
                            minWidth: 120,
                            minHeight: 120,
                          ))
                          .onTap(() {
                            // 点击触发动画
                            characterNotifier.triggerAnimation();
                          })
                          .onLongPress(() {
                            // 长按切换到随机表情
                            final emotions = EmotionMapper.getSupportedEmotions();
                            final randomEmotion = emotions[
                                DateTime.now().millisecondsSinceEpoch % emotions.length
                            ];
                            characterNotifier.updateEmotion(randomEmotion);
                          })
                          .build(),
                      
                      const SizedBox(height: 16),
                      
                      // 状态信息显示
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          VirtualCharacterUtils.getStateDescription(characterState),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 控制面板
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // 渲染器类型选择
                    Row(
                      children: [
                        const Text('渲染器: '),
                        DropdownButton<RendererType>(
                          value: selectedRendererType.value,
                          items: RendererType.values.map((type) {
                            return DropdownMenuItem<RendererType>(
                              value: type,
                              child: Text(type.displayName),
                            );
                          }).toList(),
                          onChanged: (type) {
                            if (type != null) {
                              selectedRendererType.value = type;
                            }
                          },
                        ),
                        const Spacer(),
                        const Text('预设: '),
                        DropdownButton<String>(
                          value: selectedPreset.value,
                          items: const [
                            DropdownMenuItem(value: 'default', child: Text('默认')),
                            DropdownMenuItem(value: 'small', child: Text('小尺寸')),
                            DropdownMenuItem(value: 'large', child: Text('大尺寸')),
                            DropdownMenuItem(value: 'performance', child: Text('性能优化')),
                          ],
                          onChanged: (preset) {
                            if (preset != null) {
                              selectedPreset.value = preset;
                            }
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 表情选择
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '表情选择:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1.0,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: EmotionMapper.getSupportedEmotions().length,
                              itemBuilder: (context, index) {
                                final emotion = EmotionMapper.getSupportedEmotions()[index];
                                final emoji = EmotionMapper.getEmoji(emotion);
                                final isSelected = characterState.emotion == emotion;
                                
                                return GestureDetector(
                                  onTap: () {
                                    characterNotifier.updateEmotion(emotion);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 状态和动画控制
            Row(
              children: [
                // 状态选择
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '状态控制:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: CharacterStatus.values.map((status) {
                          final isSelected = characterState.status == status;
                          return GestureDetector(
                            onTap: () {
                              characterNotifier.updateStatus(status);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status.statusText,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 动画控制
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '动画控制:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: characterNotifier.startAnimation,
                          child: const Text('开始'),
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: characterNotifier.stopAnimation,
                          child: const Text('停止'),
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: characterNotifier.triggerAnimation,
                          child: const Text('触发'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 快捷操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    characterNotifier.setIdle();
                  },
                  icon: const Icon(Icons.home, size: 16),
                  label: const Text('待机'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    characterNotifier.setListening();
                  },
                  icon: const Icon(Icons.mic, size: 16),
                  label: const Text('听取'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    characterNotifier.setThinking();
                  },
                  icon: const Icon(Icons.psychology, size: 16),
                  label: const Text('思考'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    characterNotifier.setSpeaking('happy');
                  },
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('说话'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    characterNotifier.reset();
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('重置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}