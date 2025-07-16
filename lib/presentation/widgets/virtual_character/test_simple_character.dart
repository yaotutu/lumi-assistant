/// 简化的虚拟人物测试组件
/// 
/// 专为横屏设备优化，修复渲染器加载问题
library;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'virtual_character.dart';
import 'models/character_enums.dart';
import '../../providers/virtual_character_provider.dart';
import '../../../core/utils/emotion_mapper.dart';

/// 简化的虚拟人物测试组件
class TestSimpleCharacter extends ConsumerWidget {
  const TestSimpleCharacter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听虚拟人物状态
    final characterState = ref.watch(virtualCharacterProvider);
    final characterNotifier = ref.read(virtualCharacterProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('虚拟人物测试'),
        backgroundColor: Colors.blue,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          
          print('Screen: ${screenWidth}x$screenHeight, Landscape: $isLandscape');
          
          if (isLandscape) {
            // 横屏布局
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // 左侧：虚拟人物展示
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.blue.shade900,
                            Colors.purple.shade900,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 虚拟人物组件
                            VirtualCharacterBuilder()
                                .renderer(RendererType.text)
                                .preset('default')
                                .constraints(const BoxConstraints(
                                  minWidth: 80,
                                  minHeight: 80,
                                ))
                                .onTap(() {
                                  characterNotifier.triggerAnimation();
                                })
                                .build(),
                            
                            const SizedBox(height: 8),
                            
                            // 状态信息
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${characterState.emotion} • ${characterState.status.statusText}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // 右侧：控制面板
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // 表情选择
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '表情选择:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 8,
                                      childAspectRatio: 1.0,
                                      crossAxisSpacing: 2,
                                      mainAxisSpacing: 2,
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
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Center(
                                            child: Text(
                                              emoji,
                                              style: const TextStyle(fontSize: 14),
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
                          
                          const SizedBox(height: 8),
                          
                          // 状态和控制按钮
                          Row(
                            children: [
                              // 状态选择
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '状态:',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 2,
                                      runSpacing: 2,
                                      children: CharacterStatus.values.map((status) {
                                        final isSelected = characterState.status == status;
                                        return GestureDetector(
                                          onTap: () {
                                            characterNotifier.updateStatus(status);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected ? Colors.blue : Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              status.statusText,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.black,
                                                fontSize: 8,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // 快捷按钮
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: characterNotifier.startAnimation,
                                    child: const Text('动画', style: TextStyle(fontSize: 10)),
                                  ),
                                  const SizedBox(height: 2),
                                  ElevatedButton(
                                    onPressed: characterNotifier.reset,
                                    child: const Text('重置', style: TextStyle(fontSize: 10)),
                                  ),
                                  const SizedBox(height: 2),
                                  ElevatedButton(
                                    onPressed: () {
                                      final emotions = EmotionMapper.getSupportedEmotions();
                                      final randomEmotion = emotions[
                                          DateTime.now().millisecondsSinceEpoch % emotions.length
                                      ];
                                      characterNotifier.updateEmotion(randomEmotion);
                                    },
                                    child: const Text('随机', style: TextStyle(fontSize: 10)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // 竖屏布局
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 虚拟人物展示
                  Expanded(
                    flex: 2,
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
                            VirtualCharacterBuilder()
                                .renderer(RendererType.text)
                                .preset('default')
                                .constraints(const BoxConstraints(
                                  minWidth: 100,
                                  minHeight: 100,
                                ))
                                .onTap(() {
                                  characterNotifier.triggerAnimation();
                                })
                                .build(),
                            
                            const SizedBox(height: 16),
                            
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
                                '${characterState.emotion} • ${characterState.status.statusText}',
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
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // 表情选择
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
                          
                          const SizedBox(height: 8),
                          
                          // 快捷按钮
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => characterNotifier.setIdle(),
                                child: const Text('待机'),
                              ),
                              ElevatedButton(
                                onPressed: () => characterNotifier.setListening(),
                                child: const Text('听取'),
                              ),
                              ElevatedButton(
                                onPressed: () => characterNotifier.setThinking(),
                                child: const Text('思考'),
                              ),
                              ElevatedButton(
                                onPressed: () => characterNotifier.setSpeaking('happy'),
                                child: const Text('说话'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}