/// 虚拟人物测试组件
/// 
/// 用于测试和验证虚拟人物渲染器功能
/// 仅用于开发阶段测试，不会包含在最终产品中
library;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'renderer/renderer_factory.dart';
import 'renderer/virtual_character_renderer.dart';
import 'models/virtual_character_state.dart';
import 'models/character_enums.dart';
import '../../../core/utils/emotion_mapper.dart';

/// 虚拟人物测试组件
/// 
/// 提供一个测试界面来验证虚拟人物渲染器的功能
class TestVirtualCharacter extends HookWidget {
  const TestVirtualCharacter({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用hooks管理状态
    final currentEmotion = useState('happy');
    final currentStatus = useState(CharacterStatus.idle);
    final renderer = useState<VirtualCharacterRenderer?>(null);
    
    // 获取TickerProvider
    final tickerProvider = useSingleTickerProvider();
    
    // 初始化渲染器
    useEffect(() {
      try {
        final testRenderer = VirtualCharacterRendererFactory.createRenderer(
          RendererType.text,
          vsync: tickerProvider,
        );
        renderer.value = testRenderer;
      } catch (e) {
        print('Failed to create renderer: $e');
      }
      
      return () {
        renderer.value?.dispose();
      };
    }, [tickerProvider]);
    
    // 创建当前状态
    final currentState = VirtualCharacterState(
      emotion: currentEmotion.value,
      status: currentStatus.value,
      scale: 1.0,
      isAnimating: currentStatus.value != CharacterStatus.idle,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('虚拟人物测试'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 渲染区域
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: renderer.value != null
                      ? renderer.value!.render(currentState)
                      : const Text(
                          '渲染器加载中...',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 表情选择区域
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '表情选择:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: EmotionMapper.getSupportedEmotions().length,
                      itemBuilder: (context, index) {
                        final emotion = EmotionMapper.getSupportedEmotions()[index];
                        final emoji = EmotionMapper.getEmoji(emotion);
                        final isSelected = currentEmotion.value == emotion;
                        
                        return GestureDetector(
                          onTap: () {
                            currentEmotion.value = emotion;
                            renderer.value?.updateEmotion(emotion);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
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
            
            const SizedBox(height: 20),
            
            // 状态选择区域
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '状态选择:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CharacterStatus.values.map((status) {
                    final isSelected = currentStatus.value == status;
                    return GestureDetector(
                      onTap: () {
                        currentStatus.value = status;
                        renderer.value?.updateStatus(status);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          status.statusText,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    renderer.value?.startAnimation();
                  },
                  child: const Text('开始动画'),
                ),
                ElevatedButton(
                  onPressed: () {
                    renderer.value?.stopAnimation();
                  },
                  child: const Text('停止动画'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 随机切换表情
                    final emotions = EmotionMapper.getSupportedEmotions();
                    final randomEmotion = emotions[
                        DateTime.now().millisecondsSinceEpoch % emotions.length
                    ];
                    currentEmotion.value = randomEmotion;
                    renderer.value?.updateEmotion(randomEmotion);
                  },
                  child: const Text('随机表情'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}