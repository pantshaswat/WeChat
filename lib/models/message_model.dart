import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageModel {
  final String msg;
  final dynamic time;
  final String senderId;
  final String receiverId;
  final bool isSeen;
  final int msgType;

  MessageModel({
    required this.msg,
    required this.time,
    required this.senderId,
    required this.receiverId,
    required this.isSeen,
    required this.msgType,
  });
}
