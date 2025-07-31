import 'package:flutter/material.dart';
import '../../../data/models/notification/notification_types.dart';
import '../../../data/models/notification/notification_icon_config.dart';
import '../../../core/services/notification/unified_notification_service.dart';
import 'notification_detail_dialog.dart';

/// 通知气泡组件
/// 
/// 职责：在屏幕左侧显示一个可交互的通知气泡，用于展示各类系统通知
/// 设计理念：针对横屏设备优化，采用紧凑布局减少垂直空间占用
/// 使用场景：桌面待机程序、信息展示终端、智能家居控制面板等
/// 
/// 主要功能：
/// 1. 显示最新通知的图标和未读数量
/// 2. 呼吸动画效果吸引用户注意
/// 3. 点击展开详细的通知列表面板
/// 4. 支持通知的增删改查操作
/// 
/// 技术特点：
/// - 使用 AnimationController 实现呼吸和弹跳动画
/// - 通过 Overlay 实现浮层通知面板
/// - 采用 ChangeNotifier 模式管理通知状态
class NotificationBubble extends StatefulWidget {
  /// 气泡在屏幕中的对齐位置
  /// 默认值：Alignment.centerLeft（左侧居中）
  /// 可选值：任意 Alignment 值，如 topLeft、bottomLeft 等
  final Alignment alignment;
  
  /// 气泡的直径大小（单位：逻辑像素）
  /// 默认值：60（适合横屏设备的紧凑尺寸）
  /// 建议范围：40-80，太小影响点击，太大占用空间
  final double size;
  
  /// 气泡距离屏幕边缘的外边距
  /// 默认值：EdgeInsets.only(left: 16)（距左边16像素）
  /// 作用：防止气泡贴边显示，保持视觉舒适度
  final EdgeInsets margin;
  
  const NotificationBubble({
    super.key,
    this.alignment = Alignment.centerLeft,
    this.size = 60, // 横屏优化：减小尺寸以适应有限的垂直空间
    this.margin = const EdgeInsets.only(left: 16),
  });

  @override
  State<NotificationBubble> createState() => _NotificationBubbleState();
}

class _NotificationBubbleState extends State<NotificationBubble> 
    with TickerProviderStateMixin {
  /// 呼吸动画控制器
  /// 用途：让气泡产生持续的缩放效果，模拟呼吸
  /// 周期：2秒一个完整循环
  late AnimationController _breathingController;
  
  /// 弹跳动画控制器
  /// 用途：新通知到达时产生弹跳效果
  /// 时长：500毫秒完成一次弹跳
  late AnimationController _bounceController;
  
  /// 呼吸动画的缩放值
  /// 范围：1.0（原始大小）到 1.05（放大5%）
  late Animation<double> _breathingAnimation;
  
  /// 弹跳动画的缩放值
  /// 范围：0（不可见）到 1（正常大小）
  /// 曲线：elasticOut（弹性缓出效果）
  late Animation<double> _bounceAnimation;
  
  /// 通知面板的开关状态
  /// true：面板已展开，显示详细通知列表
  /// false：面板已关闭，只显示气泡
  bool _isPanelOpen = false;
  
  /// 浮层入口对象
  /// 用于在 Overlay 中显示通知面板
  /// null 表示当前没有显示面板
  OverlayEntry? _overlayEntry;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化呼吸动画控制器
    // duration: 2秒完成一个呼吸周期（1秒放大，1秒缩小）
    // vsync: this 使用 TickerProviderStateMixin 提供的垂直同步
    // repeat(reverse: true): 无限循环，到达终点后反向播放
    _breathingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // 创建呼吸动画的缩放补间
    // begin: 1.0 表示原始大小（100%）
    // end: 1.05 表示最大放大到 105%（横屏优化：减小幅度避免过于显眼）
    // Curves.easeInOut: 缓入缓出曲线，让动画更自然
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // 横屏优化：相比默认的 1.1，减小呼吸幅度
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // 初始化弹跳动画控制器
    // 用途：当有新通知时，气泡会产生一个引人注目的弹跳效果
    // duration: 500毫秒完成整个弹跳动画
    // 注意：这个动画是一次性的，需要手动触发
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 创建弹跳动画的缩放补间
    // begin: 0 表示从完全不可见开始
    // end: 1 表示恢复到正常大小
    // Curves.elasticOut: 弹性缓出效果，模拟物理弹跳
    // 效果：气泡会先超过目标大小，然后回弹到正常大小
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));
    
    // 监听通知管理器的变化
    // 当有新通知添加、删除或状态改变时，会触发 _onNotificationChanged
    // 这是观察者模式的应用，实现了UI与数据的解耦
    NotificationBubbleManager.instance.addListener(_onNotificationChanged);
  }
  
  /// 通知变化回调函数
  /// 
  /// 触发时机：NotificationBubbleManager 的通知列表发生变化
  /// 主要职责：
  /// 1. 刷新UI显示最新的通知状态
  /// 2. 检测是否有新通知，触发弹跳动画
  void _onNotificationChanged() {
    // 检查组件是否仍然挂载，避免在组件销毁后更新状态
    if (mounted) {
      // 触发UI重建，更新通知图标和数量
      setState(() {});
      
      // 检查是否有新通知标记
      if (NotificationBubbleManager.instance.hasNewNotification) {
        // 从头开始播放弹跳动画，吸引用户注意
        _bounceController.forward(from: 0);
        // 清除新通知标记，避免重复触发动画
        NotificationBubbleManager.instance.clearNewNotificationFlag();
      }
    }
  }
  
  @override
  void dispose() {
    // 移除通知监听器，防止内存泄漏
    NotificationBubbleManager.instance.removeListener(_onNotificationChanged);
    
    // 释放动画控制器占用的资源
    // 重要：必须手动释放，否则会导致内存泄漏
    _breathingController.dispose();
    _bounceController.dispose();
    
    // 确保在组件销毁时关闭可能存在的通知面板
    _removeOverlay();
    
    super.dispose();
  }

  /// 切换通知面板的显示状态
  /// 
  /// 功能：点击气泡时调用，在展开和收起面板之间切换
  /// 逻辑：
  /// - 如果面板已打开 → 关闭面板
  /// - 如果面板已关闭 → 打开面板
  void _togglePanel() {
    if (_isPanelOpen) {
      _removeOverlay();
    } else {
      _showPanel();
    }
  }

  /// 显示通知面板
  /// 
  /// 实现原理：使用 Flutter 的 Overlay 系统在当前界面上方显示浮层
  void _showPanel() {
    // 先移除可能存在的旧面板，确保只有一个面板显示
    _removeOverlay();
    
    // 获取气泡的渲染对象，用于计算面板显示位置
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    // 将气泡的局部坐标转换为全局坐标
    // 这样可以知道气泡在屏幕上的确切位置
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    
    // 创建浮层入口
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 半透明遮罩层
          // 作用：1. 突出显示通知面板 2. 点击遮罩可关闭面板
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay, // 点击背景关闭面板
              child: Container(
                // 使用浅灰色遮罩，创建明亮清爽的背景
                color: const Color(0xFF000000).withValues(alpha: 0.3), // 轻微半透明遮罩
              ),
            ),
          ),
          // 通知面板定位
          // left: 气泡右侧 + 16像素间距
          // top/bottom: 10像素，确保面板不会顶到屏幕边缘
          // 横屏优化：减小了上下边距（原为20px）以适应有限高度
          Positioned(
            left: offset.dx + widget.size + 16, // 气泡x坐标 + 气泡宽度 + 间距
            top: 10,    // 距离顶部10像素
            bottom: 10, // 距离底部10像素
            child: NotificationPanel(
              onClose: _removeOverlay,
            ),
          ),
        ],
      ),
    );
    
    // 将浮层插入到 Overlay 中显示
    // Overlay 是 Flutter 中用于显示浮动元素的特殊图层
    Overlay.of(context).insert(_overlayEntry!);
    
    // 更新面板状态标记
    setState(() {
      _isPanelOpen = true;
    });
  }

  /// 移除通知面板浮层
  /// 
  /// 调用时机：
  /// 1. 用户点击关闭按钮
  /// 2. 用户点击半透明背景
  /// 3. 再次点击气泡
  /// 4. 组件销毁时
  void _removeOverlay() {
    // 从 Overlay 中移除浮层
    _overlayEntry?.remove();
    // 清空引用，帮助垃圾回收
    _overlayEntry = null;
    // 更新面板状态标记
    setState(() {
      _isPanelOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取所有通知列表
    final notifications = NotificationBubbleManager.instance.notifications;
    
    // 如果没有通知，返回空组件（不显示气泡）
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // 计算未读通知数量，用于显示红色标记
    final unreadCount = notifications.where((n) => !n.isRead).length;
    // 获取最新的通知，用于决定气泡的颜色和图标
    final latestNotification = notifications.first;
    
    return Align(
      alignment: widget.alignment, // 使用指定的对齐方式定位气泡
      child: Padding(
        padding: widget.margin, // 应用外边距，避免贴边
        child: ScaleTransition(
          // 动画选择逻辑：
          // - 如果弹跳动画未开始（value == 0），使用呼吸动画
          // - 如果弹跳动画已开始，使用弹跳动画
          scale: _bounceAnimation.value == 0 ? _breathingAnimation : _bounceAnimation,
          child: GestureDetector(
            onTap: _togglePanel, // 点击气泡切换面板显示状态
            child: Container(
              width: widget.size,  // 气泡宽度
              height: widget.size, // 气泡高度（正圆形）
              decoration: BoxDecoration(
                shape: BoxShape.circle, // 圆形气泡
                // 与右侧语音助手按钮保持一致的半透明背景
                color: Colors.white.withValues(alpha: 0.15),
                // 添加微妙的边框，增加层次感
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                // 柔和的阴影效果
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center, // 居中对齐所有子元素
                children: [
                  // 主图标显示逻辑：
                  // - 面板打开时：显示关闭图标
                  // - 面板关闭时：显示最新通知的图标
                  _isPanelOpen 
                    ? Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: widget.size * 0.5,
                      )
                    : latestNotification.iconConfig.build(
                        widget.size * 0.5,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                  
                  // 未读数量角标
                  // 显示条件：1. 有未读通知 2. 面板未打开
                  if (unreadCount > 0 && !_isPanelOpen)
                    Positioned(
                      top: 0,    // 紧贴顶部
                      right: 0,  // 紧贴右侧
                      child: Container(
                        padding: const EdgeInsets.all(2), // 内边距
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.9),  // 红色背景
                          shape: BoxShape.circle,                    // 圆形
                          border: Border.all(color: Colors.white, width: 2), // 白色边框
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,   // 最小宽度
                          minHeight: 20,  // 最小高度
                        ),
                        child: Text(
                          // 数字显示逻辑：超过9显示"9+"
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center, // 文本居中
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 通知面板
/// 
/// 职责：显示详细的通知列表，提供通知管理功能
/// 特点：专为横屏设备优化，采用紧凑布局
/// 功能：
/// 1. 显示所有通知的列表
/// 2. 区分已读/未读状态
/// 3. 支持滑动删除单个通知
/// 4. 提供批量操作（全部已读、清理已读、清空所有）
class NotificationPanel extends StatefulWidget {
  /// 关闭面板的回调函数
  final VoidCallback onClose;
  
  const NotificationPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> 
    with SingleTickerProviderStateMixin {
  /// 滑入动画控制器
  /// 用于控制面板从左侧滑入的动画效果
  late AnimationController _slideController;
  
  /// 滑入动画的位移值
  /// 从 Offset(-1, 0)（完全在屏幕左侧）到 Offset.zero（正常位置）
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化滑入动画控制器
    // duration: 300毫秒完成滑入动画
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 创建滑入动画
    // begin: Offset(-1, 0) 表示初始位置在屏幕左侧外
    // end: Offset.zero 表示最终位置在正常位置
    // Curves.easeOut: 缓出曲线，开始快结束慢
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    // 立即开始播放滑入动画
    _slideController.forward();
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation, // 应用滑入动画
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 380, // 固定宽度，适合大部分横屏设备
          decoration: BoxDecoration(
            // 使用明亮的白色背景，创建现代清爽的外观
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.98), // 明亮白色背景
            borderRadius: BorderRadius.circular(16), // 圆角边框
            border: Border.all(
              color: const Color(0xFFE0E0E0).withValues(alpha: 0.8), // 浅灰色边框
              width: 1,
            ),
            boxShadow: [
              // 柔和的外阴影，适合明亮主题
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              // 轻微的边缘阴影
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListenableBuilder(
            listenable: NotificationBubbleManager.instance,
            builder: (context, child) {
              return Column(
                children: [
                  // 标题栏：显示标题、未读数量、关闭按钮
                  // 横屏优化：减小内边距和字体
                  _buildCompactHeader(),
                  
                  // 通知列表区域
                  // Expanded 确保列表占用剩余空间
                  Expanded(
                    child: _buildNotificationList(),
                  ),
                  
                  // 操作栏：批量操作按钮
                  // 横屏优化：紧凑布局，减小按钮尺寸
                  _buildCompactFooter(),
                ],
              );
            },
          ),
      ),
      ),
    );
  }
  
  Widget _buildCompactHeader() {
    final unreadCount = NotificationBubbleManager.instance.notifications
        .where((n) => !n.isRead).length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // 标题栏使用非常浅的蓝色色调
        color: const Color(0xFFF8F9FA).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications, color: const Color(0xFF37474F), size: 18),
          const SizedBox(width: 8),
          Text(
            '通知',
            style: const TextStyle(
              color: Color(0xFF37474F),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$unreadCount 未读',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF37474F), size: 18),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationList() {
    final notifications = NotificationBubbleManager.instance.notifications;
    
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 48,
              color: const Color(0xFF757575),
            ),
            const SizedBox(height: 12),
            Text(
              '暂无通知',
              style: const TextStyle(
                color: Color(0xFF757575),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationItemCompact(
          notification: notification,
          onTap: () {
            // 显示通知详情对话框
            NotificationDetailDialog.show(context, notification);
            // 标记为已读
            NotificationBubbleManager.instance.markAsRead(notification.id);
            // 如果有自定义点击回调，也执行它
            notification.onTap?.call();
          },
          onDismiss: () {
            NotificationBubbleManager.instance.removeNotification(notification.id);
          },
        );
      },
    );
  }
  
  Widget _buildCompactFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // 使用浅蓝灰色底部栏，配合明亮主题
        color: const Color(0xFFF5F5F5).withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactActionButton(
            icon: Icons.done_all,
            label: '已读',
            onPressed: () {
              NotificationBubbleManager.instance.markAllAsRead();
            },
          ),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFFBDBDBD).withValues(alpha: 0.6),
          ),
          _buildCompactActionButton(
            icon: Icons.delete_sweep,
            label: '清理',
            onPressed: () {
              NotificationBubbleManager.instance.clearRead();
            },
          ),
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFFBDBDBD).withValues(alpha: 0.6),
          ),
          _buildCompactActionButton(
            icon: Icons.clear_all,
            label: '清空',
            onPressed: () {
              NotificationBubbleManager.instance.clearAll();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF37474F),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        minimumSize: const Size(0, 28),
      ),
    );
  }
}

/// 紧凑的通知项
class _NotificationItemCompact extends StatelessWidget {
  final BubbleNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  
  const _NotificationItemCompact({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red[700],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // 使用明亮主题的通知项背景
                color: notification.isRead 
                    ? const Color(0xFFF5F5F5).withValues(alpha: 0.9)  // 浅灰色已读背景
                    : const Color(0xFFE3F2FD).withValues(alpha: 0.95), // 浅蓝色未读背景
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: notification.isRead
                      ? const Color(0xFFE0E0E0).withValues(alpha: 0.8)  // 浅灰色边框
                      : const Color(0xFF90CAF9).withValues(alpha: 0.8), // 浅蓝色边框
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // 紧凑的图标
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: notification.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: notification.iconConfig.build(
                      16,
                      color: notification.color,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // 内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (notification.title != null) ...[
                              Text(
                                notification.title!,
                                style: TextStyle(
                                  color: const Color(0xFF37474F),
                                  fontSize: 13,
                                  fontWeight: notification.isRead 
                                      ? FontWeight.normal 
                                      : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _formatTime(notification.timestamp),
                              style: const TextStyle(
                                color: Color(0xFF757575),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.message,
                          style: const TextStyle(
                            color: Color(0xFF424242),
                            fontSize: 12,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // 未读标记
                  if (!notification.isRead)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: notification.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 格式化时间显示
  /// 
  /// 参数：[time] 通知的时间戳
  /// 返回：友好的时间显示字符串
  /// 
  /// 显示逻辑：
  /// - 不到1分钟：显示"刚刚"
  /// - 1小时内：显示"X分钟前"
  /// - 24小时内：显示"X小时前"
  /// - 超过24小时：显示"月/日"
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

/// 通知数据模型
/// 
/// 表示一条通知的完整信息
/// 包含通知的内容、样式、状态和交互信息
class BubbleNotification {
  /// 唯一标识符，用于区分不同通知
  final String id;
  
  /// 通知的主要内容
  final String message;
  
  /// 可选的通知标题
  final String? title;
  
  /// 通知图标配置，支持 IconData 和自定义 Widget
  final NotificationIconConfig iconConfig;
  
  /// 通知的主题颜色，用于气泡和强调色
  final Color color;
  
  /// 通知创建时间
  final DateTime timestamp;
  
  /// 通知类型，用于分类和过滤
  final NotificationType type;
  
  /// 通知级别，决定重要程度
  final NotificationLevel level;
  
  /// 通知来源信息（可选）
  final NotificationSource? source;
  
  /// 点击通知时的回调函数
  final VoidCallback? onTap;
  
  /// 已读状态，可变属性
  bool isRead;

  BubbleNotification({
    required this.id,
    required this.message,
    this.title,
    required this.iconConfig,
    required this.color,
    required this.timestamp,
    required this.type,
    this.level = NotificationLevel.normal,
    this.source,
    this.onTap,
    this.isRead = false,
  });
}

/// 通知管理器（单例模式）
/// 
/// 职责：管理所有通知的生命周期和状态
/// 特点：
/// 1. 使用单例模式，确保全局只有一个管理器实例
/// 2. 继承 ChangeNotifier，支持观察者模式
/// 3. 提供丰富的通知操作 API
/// 
/// 主要功能：
/// - 添加各类通知
/// - 管理通知状态（已读/未读）
/// - 批量操作（全部已读、清理、清空）
/// - 新通知标记管理
class NotificationBubbleManager extends ChangeNotifier {
  // 私有静态实例，实现单例模式
  static final NotificationBubbleManager _instance = NotificationBubbleManager._internal();
  
  /// 获取单例实例
  static NotificationBubbleManager get instance => _instance;
  
  // 私有构造函数，防止外部创建新实例
  NotificationBubbleManager._internal() {
    // 监听统一通知服务的变化
    UnifiedNotificationService.instance.addListener(_syncFromUnifiedService);
  }

  /// 通知列表，按时间倒序排列（最新的在前）
  final List<BubbleNotification> _notifications = [];
  
  /// 新通知标记，用于触发弹跳动画
  bool _hasNewNotification = false;
  
  /// 设置新通知标记（供外部触发动画）
  void setNewNotificationFlag() {
    _hasNewNotification = true;
    notifyListeners();
  }
  
  /// 获取只读的通知列表
  List<BubbleNotification> get notifications => List.unmodifiable(_notifications);
  
  /// 获取新通知标记
  bool get hasNewNotification => _hasNewNotification;
  
  /// 从统一通知服务同步数据
  void _syncFromUnifiedService() {
    // 获取统一服务中的通知
    final unifiedNotifications = UnifiedNotificationService.instance.notifications;
    
    // 转换并更新本地通知列表
    _notifications.clear();
    for (final un in unifiedNotifications) {
      // 根据源ID确定类型和配置
      final type = _mapSourceToType(un.sourceId);
      final config = NotificationTypeConfig.getConfig(type);
      
      // 创建本地通知对象
      final notification = BubbleNotification(
        id: un.id,
        message: un.message,
        title: un.title,
        iconConfig: config.iconConfig,
        color: NotificationTypeConfig.getLevelAdjustedColor(
          config.color, 
          _mapPriorityToLevel(un.priority)
        ),
        timestamp: un.timestamp,
        type: type,
        level: _mapPriorityToLevel(un.priority),
        isRead: un.isRead,
      );
      
      _notifications.add(notification);
    }
    
    // 按时间排序
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // 通知UI更新
    notifyListeners();
  }
  
  /// 映射源ID到通知类型
  NotificationType _mapSourceToType(String sourceId) {
    switch (sourceId) {
      case 'gotify':
        return NotificationType.gotify;
      case 'weather':
        return NotificationType.weather;
      case 'system':
        return NotificationType.system;
      case 'iot':
        return NotificationType.iot;
      default:
        return NotificationType.custom;
    }
  }
  
  /// 映射优先级到通知级别
  NotificationLevel _mapPriorityToLevel(int priority) {
    if (priority <= 2) {
      return NotificationLevel.low;
    } else if (priority <= 5) {
      return NotificationLevel.normal;
    } else if (priority <= 7) {
      return NotificationLevel.high;
    } else {
      return NotificationLevel.urgent;
    }
  }

  /// 添加通用通知
  /// 
  /// 参数：
  /// - [message] 通知内容（必填）
  /// - [title] 通知标题（可选）
  /// - [type] 通知类型，默认为 custom
  /// - [level] 通知级别，默认为 normal
  /// - [icon] 通知图标（可选，不指定则使用类型默认图标）
  /// - [color] 通知颜色（可选，不指定则使用类型默认颜色）
  /// - [source] 通知来源信息
  /// - [onTap] 点击通知时的回调
  void addNotification({
    required String message,
    String? title,
    NotificationType type = NotificationType.custom,
    NotificationLevel level = NotificationLevel.normal,
    IconData? icon,
    Color? color,
    NotificationSource? source,
    VoidCallback? onTap,
  }) {
    // 获取类型默认配置
    final config = NotificationTypeConfig.getConfig(type);
    
    // 使用指定值或默认值
    final finalIconConfig = icon != null 
        ? NotificationIconConfig.icon(icon) 
        : config.iconConfig;
    final finalColor = color ?? config.color;
    final finalTitle = title ?? config.defaultTitle;
    
    // 根据级别调整颜色
    final adjustedColor = NotificationTypeConfig.getLevelAdjustedColor(finalColor, level);
    
    // 创建新通知对象
    // 使用当前时间戳作为唯一ID
    final notification = BubbleNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      title: finalTitle,
      iconConfig: finalIconConfig,
      color: adjustedColor,
      timestamp: DateTime.now(),
      type: type,
      level: level,
      source: source,
      onTap: onTap,
    );
    
    // 插入到列表开头（最新的在前）
    _notifications.insert(0, notification);
    // 设置新通知标记，触发弹跳动画
    _hasNewNotification = true;
    
    // 限制通知数量，避免内存占用过多
    if (_notifications.length > 30) {
      _notifications.removeLast(); // 移除最旧的通知
    }
    
    // 通知所有监听者更新UI
    notifyListeners();
  }
  
  /// 添加 Gotify 通知
  /// 
  /// Gotify 是一个开源的推送通知服务
  /// 特征：使用云朵图标，青蓝色主题
  void addGotifyNotification(
    String message, {
    String? title,
    NotificationLevel level = NotificationLevel.normal,
    NotificationSource? source,
    VoidCallback? onTap,
  }) {
    addNotification(
      message: message,
      title: title,
      type: NotificationType.gotify,
      level: level,
      source: source,
      onTap: onTap,
    );
  }
  
  /// 添加天气通知
  /// 
  /// 用于显示天气预警、温度变化等信息
  /// 特征：使用太阳图标，橙色主题
  void addWeatherNotification(
    String message, {
    String? title,
    NotificationLevel level = NotificationLevel.normal,
    NotificationSource? source,
    VoidCallback? onTap,
  }) {
    addNotification(
      message: message,
      title: title,
      type: NotificationType.weather,
      level: level,
      source: source,
      onTap: onTap,
    );
  }
  
  /// 添加系统通知
  /// 
  /// 用于显示系统状态、更新提醒等信息
  /// 特征：使用设置图标，蓝色主题
  void addSystemNotification(
    String message, {
    String? title,
    NotificationLevel level = NotificationLevel.normal,
    NotificationSource? source,
    VoidCallback? onTap,
  }) {
    addNotification(
      message: message,
      title: title,
      type: NotificationType.system,
      level: level,
      source: source,
      onTap: onTap,
    );
  }
  
  /// 添加 IoT 设备通知
  /// 
  /// 用于显示智能家居设备状态、触发事件等
  /// 特征：使用设备图标，绿色主题
  void addIoTNotification(
    String message, {
    String? title,
    NotificationLevel level = NotificationLevel.normal,
    NotificationSource? source,
    VoidCallback? onTap,
  }) {
    addNotification(
      message: message,
      title: title,
      type: NotificationType.iot,
      level: level,
      source: source,
      onTap: onTap,
    );
  }
  
  /// 添加安全警告通知
  /// 
  /// 用于显示安全相关的警告和提醒
  void addSecurityNotification(
    String message, {
    String? title,
    NotificationLevel level = NotificationLevel.high,
    NotificationSource? source,
    VoidCallback? onTap,
  }) {
    addNotification(
      message: message,
      title: title,
      type: NotificationType.security,
      level: level,
      source: source,
      onTap: onTap,
    );
  }

  /// 标记单个通知为已读
  /// 
  /// 参数：[id] 通知的唯一标识符
  void markAsRead(String id) async {
    // 调用统一通知服务标记已读
    await UnifiedNotificationService.instance.markAsRead(id, syncToServer: true);
    // 统一服务会触发监听器，自动同步数据
  }

  /// 标记所有通知为已读
  void markAllAsRead() async {
    // 调用统一通知服务的方法
    await UnifiedNotificationService.instance.markAllAsRead(syncToServer: true);
    // 统一服务会触发监听器，自动同步数据
  }

  /// 移除指定通知
  /// 
  /// 参数：[id] 要移除的通知的唯一标识符
  void removeNotification(String id) async {
    // 调用统一通知服务删除
    await UnifiedNotificationService.instance.deleteNotification(id, syncToServer: true);
    // 统一服务会触发监听器，自动同步数据
  }

  /// 清除所有已读通知
  /// 
  /// 保留未读通知，只移除已读的
  /// 清理：删除所有已读的通知
  void clearRead() async {
    // 调用统一通知服务的清理方法
    await UnifiedNotificationService.instance.clearRead();
    // 统一服务会触发监听器，自动同步数据
  }

  /// 清空所有通知
  /// 
  /// 危险操作：会删除所有通知，无论是否已读
  /// 清空：删除所有通知（包括未读的）
  void clearAll() async {
    // 调用统一通知服务的清空方法
    await UnifiedNotificationService.instance.clearAll();
    // 统一服务会触发监听器，自动同步数据
  }
  
  /// 清除新通知标记
  /// 
  /// 在弹跳动画播放后调用，避免重复触发动画
  void clearNewNotificationFlag() {
    _hasNewNotification = false;
  }
  
  /// 按类型获取通知列表
  /// 
  /// 参数：[type] 要筛选的通知类型
  /// 返回：指定类型的通知列表
  List<BubbleNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }
  
  /// 按级别获取通知列表
  /// 
  /// 参数：[level] 要筛选的通知级别
  /// 返回：指定级别的通知列表
  List<BubbleNotification> getNotificationsByLevel(NotificationLevel level) {
    return _notifications.where((n) => n.level == level).toList();
  }
  
  /// 按来源获取通知列表
  /// 
  /// 参数：[sourceId] 要筛选的来源ID
  /// 返回：指定来源的通知列表
  List<BubbleNotification> getNotificationsBySource(String sourceId) {
    return _notifications.where((n) => n.source?.id == sourceId).toList();
  }
  
  /// 获取未读通知数量
  /// 
  /// 参数：[type] 可选，指定类型的未读数量
  /// 返回：未读通知数量
  int getUnreadCount({NotificationType? type}) {
    var notifications = _notifications.where((n) => !n.isRead);
    if (type != null) {
      notifications = notifications.where((n) => n.type == type);
    }
    return notifications.length;
  }
  
  /// 获取紧急通知列表
  /// 
  /// 返回：所有紧急级别的通知
  List<BubbleNotification> getUrgentNotifications() {
    return _notifications
        .where((n) => n.level == NotificationLevel.urgent && !n.isRead)
        .toList();
  }
}