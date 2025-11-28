package com.lumi.assistant.wakeup

/**
 * 语音唤醒回调接口
 */
interface WakeupListener {
    /**
     * 唤醒成功回调
     * @param keyword 唤醒词
     * @param score 唤醒置信度分数
     */
    fun onWakeupSuccess(keyword: String, score: Int)

    /**
     * 预唤醒回调(可选,用于提前准备)
     */
    fun onPreWakeup()

    /**
     * 唤醒错误回调
     * @param errorCode 错误码
     * @param errorMsg 错误信息
     */
    fun onWakeupError(errorCode: Int, errorMsg: String)

    /**
     * 音频数据回调(用于VAD检测或录音)
     * @param audioData 音频数据
     */
    fun onAudioData(audioData: ByteArray)
}
