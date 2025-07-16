/// 文字Emoji虚拟人物渲染器
/// 
/// 实现基于文字和emoji的虚拟人物渲染，轻量级且高性能
/// 支持21种表情类型和5种状态动画
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'virtual_character_renderer.dart';
import '../models/virtual_character_state.dart';
import '../models/character_enums.dart';
import '../../../../core/utils/emotion_mapper.dart';

/// 文字Emoji虚拟人物渲染器
/// 
/// 使用文字和emoji符号渲染虚拟人物
/// 支持表情切换动画、状态指示、缩放效果等
class TextCharacterRenderer extends VirtualCharacterRenderer {
  /// 动画控制器
  late AnimationController _animationController;
  
  /// 脉动动画
  late Animation<double> _pulseAnimation;
  
  /// 缩放动画
  late Animation<double> _scaleAnimation;
  
  /// 当前状态
  VirtualCharacterState _currentState = VirtualCharacterState.idle();
  
  /// 渲染器配置
  final Map<String, dynamic> _config = {
    'fontSize': 48.0,
    'statusFontSize': 12.0,
    'textColor': Colors.white,
    'statusTextColor': Colors.white70,
    'animationDuration': 300,
    'pulseEnabled': true,
    'scaleEnabled': true,
    'hapticFeedback': true,
  };
  
  /// 构造函数
  TextCharacterRenderer({
    required TickerProvider vsync,
    Map<String, dynamic>? config,
  }) {
    if (config != null) {
      _config.addAll(config);
    }
    
    // 初始化动画控制器
    _animationController = AnimationController(
      duration: Duration(milliseconds: _config['animationDuration'] as int),
      vsync: vsync,
    );
    
    // 初始化脉动动画
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 初始化缩放动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  RendererType get type => RendererType.text;
  
  @override
  Widget render(VirtualCharacterState state) {
    _currentState = state;
    
    // 根据状态控制动画
    _controlAnimation(state);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _calculateScale(state),
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 80,
              minHeight: 80,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 表情emoji区域
                _buildEmojiSection(state),
                
                // 间距
                const SizedBox(height: 8),
                
                // 状态文字区域
                _buildStatusSection(state),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// 构建表情emoji区域
  Widget _buildEmojiSection(VirtualCharacterState state) {
    final emoji = EmotionMapper.getEmoji(state.emotion);
    final fontSize = _config['fontSize'] as double;
    
    return AnimatedSwitcher(
      duration: Duration(milliseconds: _config['animationDuration'] as int),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(emoji),
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  /// 构建状态文字区域
  Widget _buildStatusSection(VirtualCharacterState state) {
    final statusText = state.effectiveStatusText;
    final statusFontSize = _config['statusFontSize'] as double;
    final statusTextColor = _config['statusTextColor'] as Color;
    
    return AnimatedSwitcher(
      duration: Duration(milliseconds: _config['animationDuration'] as int),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(statusText),
        child: Text(
          statusText,
          style: TextStyle(
            fontSize: statusFontSize,
            color: statusTextColor,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
  
  /// 计算缩放比例
  double _calculateScale(VirtualCharacterState state) {
    double baseScale = state.scale;
    
    // 如果启用了缩放动画
    if (_config['scaleEnabled'] == true && state.isAnimating) {
      baseScale *= _scaleAnimation.value;
    }
    
    // 如果启用了脉动动画
    if (_config['pulseEnabled'] == true && state.status == CharacterStatus.listening) {
      baseScale *= _pulseAnimation.value;
    }
    
    return baseScale;
  }
  
  /// 控制动画
  void _controlAnimation(VirtualCharacterState state) {
    if (state.isAnimating) {
      // 根据状态选择动画类型
      switch (state.status) {
        case CharacterStatus.listening:
          // 听取状态：连续脉动动画
          _animationController.repeat(reverse: true);
          break;
        case CharacterStatus.thinking:
          // 思考状态：缓慢脉动
          _animationController.repeat(reverse: true);
          break;
        case CharacterStatus.speaking:
          // 说话状态：单次缩放动画
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
          break;
        default:
          _animationController.forward();
          break;
      }
    } else {
      // 停止动画，回到初始状态
      _animationController.stop();
      _animationController.reset();
    }
  }
  
  @override
  void updateEmotion(String emotion) {
    if (_currentState.emotion != emotion) {
      _currentState = _currentState.copyWith(emotion: emotion);
      
      // 触发触觉反馈
      if (_config['hapticFeedback'] == true) {
        HapticFeedback.lightImpact();
      }
    }
  }
  
  @override
  void updateStatus(CharacterStatus status) {
    if (_currentState.status != status) {
      _currentState = _currentState.copyWith(
        status: status,
        isAnimating: status != CharacterStatus.idle,
      );
      
      // 根据状态调整缩放比例
      double newScale = 1.0;
      switch (status) {
        case CharacterStatus.listening:
          newScale = 1.1;
          break;
        case CharacterStatus.thinking:
        case CharacterStatus.speaking:
          newScale = 1.0;
          break;
        case CharacterStatus.sleeping:
          newScale = 0.8;
          break;
        default:
          newScale = 1.0;
          break;
      }
      
      _currentState = _currentState.copyWith(scale: newScale);
      
      // 触发触觉反馈
      if (_config['hapticFeedback'] == true) {
        HapticFeedback.selectionClick();
      }
    }
  }
  
  @override
  void startAnimation() {
    _currentState = _currentState.copyWith(isAnimating: true);
    _controlAnimation(_currentState);
  }
  
  @override
  void stopAnimation() {
    _currentState = _currentState.copyWith(isAnimating: false);
    _animationController.stop();
    _animationController.reset();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
  }
  
  @override
  bool supportsEmotion(String emotion) {
    return EmotionMapper.supportsEmotion(emotion);
  }
  
  @override
  bool supportsStatus(CharacterStatus status) {
    // 文字渲染器支持所有状态类型
    return true;
  }
  
  @override
  Map<String, dynamic> getConfiguration() {
    return Map<String, dynamic>.from(_config);
  }
  
  @override
  void setConfiguration(Map<String, dynamic> config) {
    _config.addAll(config);
    
    // 更新动画时长
    if (config.containsKey('animationDuration')) {
      _animationController.duration = Duration(
        milliseconds: config['animationDuration'] as int,
      );
    }
  }
  
  @override
  Future<void> preloadResources() async {
    // 文字渲染器不需要预加载外部资源
    // 验证表情映射完整性
    if (!EmotionMapper.validateMapping()) {
      throw Exception('Emotion mapping validation failed');
    }
  }
  
  @override
  List<String> getSupportedEmotions() {
    return EmotionMapper.getSupportedEmotions();
  }
  
  @override
  List<CharacterStatus> getSupportedStatuses() {
    return CharacterStatus.values;
  }
  
  /// 获取当前状态
  VirtualCharacterState getCurrentState() {
    return _currentState;
  }
  
  /// 设置状态并触发重新渲染
  void setState(VirtualCharacterState state) {
    _currentState = state;
    _controlAnimation(state);
  }
  
  /// 获取表情统计信息
  Map<String, dynamic> getEmotionStatistics() {
    return EmotionMapper.getStatistics();
  }
}