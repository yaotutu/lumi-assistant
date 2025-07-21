/// 直接测试渲染器功能
/// 
/// 不使用统一组件，直接测试渲染器是否正常工作
library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'renderer/text_character_renderer.dart';
import 'models/virtual_character_state.dart';
import 'models/character_enums.dart';
import '../../../core/utils/emotion_mapper.dart';

/// 直接测试渲染器组件
class TestDirectRenderer extends HookConsumerWidget {
  const TestDirectRenderer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取TickerProvider
    final tickerProvider = useSingleTickerProvider();
    
    // 创建渲染器（只依赖tickerProvider，不会因为状态改变而重新创建）
    final renderer = useMemoized(() {
      try {
        final newRenderer = TextCharacterRenderer(
          vsync: tickerProvider,
          config: const {
            'fontSize': 48.0,
            'statusFontSize': 12.0,
            'textColor': Colors.white,
            'statusTextColor': Colors.white70,
            'animationDuration': 300,
            'pulseEnabled': true,
            'scaleEnabled': true,
            'hapticFeedback': true,
          },
        );
        print('TextCharacterRenderer created successfully');
        return newRenderer;
      } catch (e) {
        print('Failed to create TextCharacterRenderer: $e');
        print('TickerProvider: $tickerProvider');
        return null;
      }
    }, [tickerProvider]);
    
    // 当前状态
    final currentEmotion = useState('happy');
    final currentStatus = useState(CharacterStatus.idle);
    
    // 创建状态对象
    final state = VirtualCharacterState(
      emotion: currentEmotion.value,
      status: currentStatus.value,
      scale: 1.0,
      isAnimating: currentStatus.value != CharacterStatus.idle,
    );
    
    // 释放渲染器资源
    useEffect(() {
      return () {
        renderer?.dispose();
      };
    }, [renderer]);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('直接渲染器测试'),
        backgroundColor: Colors.red,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 显示屏幕信息
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '屏幕: ${constraints.maxWidth.toInt()}x${constraints.maxHeight.toInt()}\n'
                    '方向: ${isLandscape ? "横屏" : "竖屏"}\n'
                    '渲染器: ${renderer != null ? "正常" : "失败"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 虚拟人物展示
                Expanded(
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
                          // 渲染器输出
                          if (renderer != null)
                            renderer.render(state)
                          else
                            const Column(
                              children: [
                                Icon(
                                  Icons.error,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '渲染器创建失败',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // 状态信息
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
                              '${currentEmotion.value} • ${currentStatus.value.statusText}',
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
                Container(
                  height: isLandscape ? 150 : 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // 表情选择
                      const Text(
                        '表情选择:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isLandscape ? 12 : 7,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: EmotionMapper.getSupportedEmotions().length,
                          itemBuilder: (context, index) {
                            final emotion = EmotionMapper.getSupportedEmotions()[index];
                            final emoji = EmotionMapper.getEmoji(emotion);
                            final isSelected = currentEmotion.value == emotion;
                            
                            return GestureDetector(
                              onTap: () {
                                currentEmotion.value = emotion;
                                // 不需要调用updateEmotion，因为render方法会接收新的状态
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    emoji,
                                    style: TextStyle(
                                      fontSize: isLandscape ? 12 : 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 状态和控制按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              currentStatus.value = CharacterStatus.idle;
                              // 不需要调用updateStatus，因为render方法会接收新的状态
                            },
                            child: const Text('待机'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              currentStatus.value = CharacterStatus.listening;
                              // 不需要调用updateStatus，因为render方法会接收新的状态
                            },
                            child: const Text('听取'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              currentStatus.value = CharacterStatus.thinking;
                              // 不需要调用updateStatus，因为render方法会接收新的状态
                            },
                            child: const Text('思考'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              currentStatus.value = CharacterStatus.speaking;
                              // 不需要调用updateStatus，因为render方法会接收新的状态
                            },
                            child: const Text('说话'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              renderer?.startAnimation();
                            },
                            child: const Text('动画'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}