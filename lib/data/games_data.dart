import 'package:flutter/material.dart';
import '../models/game_option.dart';

const List<GameOption> gameOptions = [
  GameOption(
    name: '井字棋',
    icon: Icons.grid_3x3,
    description: '经典双人策略游戏，轮流在3x3棋盘上落子',
    color: Color(0xFFFF6B6B),
  ),
  GameOption(
    name: '扫雷',
    icon: Icons.warning_amber_rounded,
    description: '经典逻辑推理游戏，找出所有地雷',
    color: Color(0xFF4ECDC4),
  ),
  GameOption(
    name: '贪吃蛇',
    icon: Icons.timeline,
    description: '经典街机游戏，控制贪吃蛇不断成长',
    color: Color(0xFF45B7D1),
  ),
  GameOption(
    name: '2048',
    icon: Icons.grid_on,
    description: '数字合并游戏，挑战2048高分',
    color: Color(0xFFFFA07A),
  ),
  GameOption(
    name: '记忆翻牌',
    icon: Icons.style,
    description: '考验记忆力的配对翻牌游戏',
    color: Color(0xFF98D8C8),
  ),
  GameOption(
    name: '数独',
    icon: Icons.nine_k,
    description: '经典数字推理谜题，锻炼逻辑思维',
    color: Color(0xFFDDA0DD),
  ),
];
