package com.lumi.assistant.model

data class Message(
    val id: Long = System.currentTimeMillis(),
    val content: String,
    val isFromUser: Boolean,
    val type: MessageType = MessageType.TEXT
)

enum class MessageType {
    TEXT,
    VOICE
}
