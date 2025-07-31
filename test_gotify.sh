#!/bin/bash

echo "发送测试通知到 Gotify..."
echo "使用应用令牌: Ahw0duy05PwdA_q"

# 发送第一条测试消息
curl "http://43.139.248.238:8088/message?token=Ahw0duy05PwdA_q" \
  -F "title=测试通知 1" \
  -F "message=这是第一条测试消息，优先级为普通" \
  -F "priority=5"

echo -e "\n"

# 等待2秒
sleep 2

# 发送第二条紧急消息
curl "http://43.139.248.238:8088/message?token=Ahw0duy05PwdA_q" \
  -F "title=紧急通知！" \
  -F "message=这是一条紧急测试消息" \
  -F "priority=8"

echo -e "\n"

# 等待2秒
sleep 2

# 发送第三条低优先级消息
curl "http://43.139.248.238:8088/message?token=Ahw0duy05PwdA_q" \
  -F "title=信息提示" \
  -F "message=这是一条低优先级的信息" \
  -F "priority=2"

echo -e "\n\n测试完成！请查看应用左侧的通知气泡"