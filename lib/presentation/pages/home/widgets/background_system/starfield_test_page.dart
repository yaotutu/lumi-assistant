import 'package:flutter/material.dart';
import 'animated_starfield_background.dart';

/// 星空背景测试页面
/// 
/// 用于独立测试星空效果，排查显示问题
class StarfieldTestPage extends StatelessWidget {
  const StarfieldTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('星空背景测试'),
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        foregroundColor: Colors.white,
      ),
      body: const Stack(
        children: [
          // 全屏星空背景
          AnimatedStarfieldBackground(),
          
          // 测试文字，验证星空是否显示
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🌟 星空背景测试',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '如果您能看到闪烁的星星\n说明星空背景正常工作',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}