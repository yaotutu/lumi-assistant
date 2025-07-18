import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Opus数据捕获服务
/// 用于捕获并保存服务端返回的opus音频数据，便于后续测试和分析
class OpusDataCaptureService {
  static const String tag = 'OpusDataCaptureService';
  
  // 捕获的数据存储
  static final List<OpusDataSample> _capturedData = [];
  static bool _isCapturing = false;
  static String? _currentSessionId;
  
  /// 开始捕获opus数据
  static void startCapture({String? sessionId}) {
    _isCapturing = true;
    _currentSessionId = sessionId;
    _capturedData.clear();
    print('[$tag] 开始捕获opus数据，会话ID: $sessionId');
  }
  
  /// 停止捕获opus数据
  static void stopCapture() {
    _isCapturing = false;
    print('[$tag] 停止捕获opus数据，共捕获 ${_capturedData.length} 个数据包');
  }
  
  /// 捕获opus数据包
  static void captureOpusData(Uint8List opusData, {String? messageType}) {
    if (!_isCapturing) return;
    
    final sample = OpusDataSample(
      data: Uint8List.fromList(opusData),
      timestamp: DateTime.now(),
      sessionId: _currentSessionId,
      messageType: messageType,
      sequenceNumber: _capturedData.length + 1,
    );
    
    _capturedData.add(sample);
    print('[$tag] 捕获opus数据包 #${sample.sequenceNumber}: ${opusData.length} 字节');
  }
  
  /// 保存捕获的数据到文件
  static Future<List<String>> saveCapturedData() async {
    if (_capturedData.isEmpty) {
      print('[$tag] 没有捕获到数据');
      return [];
    }
    
    final directory = await getApplicationDocumentsDirectory();
    final captureDir = Directory('${directory.path}/opus_captures');
    
    if (!await captureDir.exists()) {
      await captureDir.create(recursive: true);
    }
    
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final savedFiles = <String>[];
    
    // 保存每个数据包
    for (int i = 0; i < _capturedData.length; i++) {
      final sample = _capturedData[i];
      final filename = 'opus_sample_${timestamp}_${i + 1}.opus';
      final file = File('${captureDir.path}/$filename');
      
      await file.writeAsBytes(sample.data);
      savedFiles.add(file.path);
      
      print('[$tag] 保存数据包 ${i + 1}: ${file.path}');
    }
    
    // 保存元数据
    final metadataFile = File('${captureDir.path}/metadata_$timestamp.json');
    final metadata = {
      'session_id': _currentSessionId,
      'capture_time': timestamp,
      'total_samples': _capturedData.length,
      'samples': _capturedData.map((sample) => {
        'sequence_number': sample.sequenceNumber,
        'timestamp': sample.timestamp.toIso8601String(),
        'data_size': sample.data.length,
        'message_type': sample.messageType,
      }).toList(),
    };
    
    await metadataFile.writeAsString(metadata.toString());
    print('[$tag] 保存元数据: ${metadataFile.path}');
    
    return savedFiles;
  }
  
  /// 获取捕获的数据统计
  static Map<String, dynamic> getCaptureStatistics() {
    if (_capturedData.isEmpty) {
      return {'total_samples': 0, 'total_bytes': 0};
    }
    
    final totalBytes = _capturedData.fold<int>(0, (sum, sample) => sum + sample.data.length);
    final avgSize = totalBytes / _capturedData.length;
    
    return {
      'total_samples': _capturedData.length,
      'total_bytes': totalBytes,
      'average_size': avgSize.round(),
      'session_id': _currentSessionId,
      'is_capturing': _isCapturing,
    };
  }
  
  /// 获取捕获的数据列表
  static List<OpusDataSample> getCapturedData() {
    return List.from(_capturedData);
  }
  
  /// 清空捕获的数据
  static void clearCapturedData() {
    _capturedData.clear();
    print('[$tag] 清空捕获的数据');
  }
}

/// Opus数据样本
class OpusDataSample {
  final Uint8List data;
  final DateTime timestamp;
  final String? sessionId;
  final String? messageType;
  final int sequenceNumber;
  
  const OpusDataSample({
    required this.data,
    required this.timestamp,
    this.sessionId,
    this.messageType,
    required this.sequenceNumber,
  });
  
  /// 获取数据大小（字节）
  int get sizeInBytes => data.length;
  
  /// 获取时间戳字符串
  String get timestampString => timestamp.toIso8601String();
  
  @override
  String toString() {
    return 'OpusDataSample(seq: $sequenceNumber, size: $sizeInBytes bytes, time: $timestampString)';
  }
}