import 'dart:typed_data';
import 'package:opus_dart/opus_dart.dart';
import 'package:flutter_pcm_player/flutter_pcm_player.dart';

/// 原始PCM音频服务 - 对照组
/// 
/// 最简单直接的flutter_pcm_player使用方式，不做任何优化
/// 用于验证flutter_pcm_player本身是否能正常工作
class AudioServiceRawPcm {
  static const String tag = 'AudioServiceRawPcm';
  
  /// Opus解码器
  static final _decoder = SimpleOpusDecoder(
    sampleRate: 16000,
    channels: 1,
  );

  /// 直接播放opus音频数据 - 最原始的方式
  static Future<void> playOpusAudio(Uint8List opusData) async {
    try {
      print('[$tag] 开始播放opus数据: ${opusData.length} 字节');
      
      // 解码opus到PCM
      final pcmData = _decoder.decode(input: opusData);
      print('[$tag] Opus解码完成: ${pcmData.length} PCM字节');
      
      // 创建新的播放器实例（每次都重新创建）
      final player = FlutterPcmPlayer();
      
      try {
        // 初始化播放器
        await player.initialize();
        print('[$tag] 播放器初始化完成');
        
        // 开始播放
        await player.play();
        print('[$tag] 播放器已启动');
        
        // 转换PCM数据格式（Int16List -> Uint8List）
        final pcmBytes = Uint8List.fromList(
          pcmData.expand((sample) => [
            sample & 0xFF,           // 低字节
            (sample >> 8) & 0xFF,    // 高字节
          ]).toList()
        );
        
        // 喂数据
        await player.feed(pcmBytes);
        print('[$tag] PCM数据已喂入播放器');
        
        // 等待播放完成
        await Future.delayed(Duration(milliseconds: (pcmData.length / 32).round() + 500));
        
        // 停止播放
        await player.stop();
        print('[$tag] 播放完成并停止');
        
      } finally {
        // 释放播放器资源
        try {
          await player.release();
          print('[$tag] 播放器资源已释放');
        } catch (releaseError) {
          print('[$tag] 释放播放器失败: $releaseError');
        }
      }
      
    } catch (error) {
      print('[$tag] 播放失败: $error');
      rethrow;
    }
  }
  
  /// 连续播放多个opus文件 - 简单方式
  static Future<void> playMultipleOpusFiles(List<Uint8List> opusDataList) async {
    print('[$tag] 开始连续播放 ${opusDataList.length} 个opus文件');
    
    for (int i = 0; i < opusDataList.length; i++) {
      try {
        print('[$tag] 播放第 ${i + 1}/${opusDataList.length} 个文件');
        await playOpusAudio(opusDataList[i]);
        
        // 文件间短暂间隔
        if (i < opusDataList.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
        
      } catch (error) {
        print('[$tag] 第 ${i + 1} 个文件播放失败: $error');
      }
    }
    
    print('[$tag] 连续播放完成');
  }
}