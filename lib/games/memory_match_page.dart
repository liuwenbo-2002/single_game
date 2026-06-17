import 'dart:math';
import 'package:flutter/material.dart';

/// 记忆翻牌游戏页面
class MemoryMatchPage extends StatefulWidget {
  const MemoryMatchPage({super.key});

  @override
  State<MemoryMatchPage> createState() => _MemoryMatchPageState();
}

class _MemoryMatchPageState extends State<MemoryMatchPage>
    with SingleTickerProviderStateMixin {
  static const List<String> _emojis = ['🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼'];

  late List<_CardData> _cards;
  int _flipCount = 0;
  int _matchedPairs = 0;
  int? _firstIndex;
  bool _isProcessing = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _initGame();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _initGame() {
    final rng = Random();
    final List<String> emojiPool = [..._emojis, ..._emojis];
    emojiPool.shuffle(rng);
    _cards = List.generate(16, (i) => _CardData(emoji: emojiPool[i]));
    _flipCount = 0;
    _matchedPairs = 0;
    _firstIndex = null;
    _isProcessing = false;
  }

  void _onCardTap(int index) {
    if (_isProcessing) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFlipped) return;

    setState(() {
      _cards[index].isFlipped = true;
      _flipCount++;
    });

    if (_firstIndex == null) {
      _firstIndex = index;
    } else {
      _isProcessing = true;
      _checkMatch(_firstIndex!, index);
    }
  }

  void _checkMatch(int a, int b) {
    if (_cards[a].emoji == _cards[b].emoji) {
      // 配对成功
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _cards[a].isMatched = true;
          _cards[b].isMatched = true;
          _matchedPairs++;
          _firstIndex = null;
          _isProcessing = false;
        });
        if (_matchedPairs == 8) {
          _showVictory();
        }
      });
    } else {
      // 不配对，翻回
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _cards[a].isFlipped = false;
          _cards[b].isFlipped = false;
          _firstIndex = null;
          _isProcessing = false;
        });
      });
    }
  }

  void _showVictory() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 恭喜通关！'),
        content: Text('你用了 $_flipCount 次翻牌完成了全部配对！'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(_initGame);
            },
            child: const Text('再来一局'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('记忆翻牌'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // 统计信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            '翻牌次数',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_flipCount',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            '已配对',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_matchedPairs / 8',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 卡片网格
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: 16,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) => _buildCard(index),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 重新开始按钮
          Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  setState(_initGame);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('重新开始'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
          // 3D 翻转效果：先缩小宽度到0，再展开
          return RotationYTransition(
            turns: animation,
            child: child,
          );
        },
        child: card.isFlipped || card.isMatched
            ? _buildCardFront(card.emoji, key: ValueKey('front_$index'))
            : _buildCardBack(key: ValueKey('back_$index')),
      ),
    );
  }

  Widget _buildCardFront(String emoji, {Key? key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 36),
        ),
      ),
    );
  }

  Widget _buildCardBack({Key? key}) {
    final theme = Theme.of(context);
    return Container(
      key: key,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.help_outline,
          size: 28,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

/// 卡片数据模型
class _CardData {
  final String emoji;
  bool isFlipped = false;
  bool isMatched = false;

  _CardData({required this.emoji});
}

/// 实现沿Y轴旋转的过渡动画
class RotationYTransition extends StatelessWidget {
  final Animation<double> turns;
  final Widget child;

  const RotationYTransition({
    super.key,
    required this.turns,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: turns,
      builder: (context, child) {
        // 将 turns (0~1) 映射到旋转角度 (0~pi)
        final angle = turns.value * 3.14159265;
        // 使用 Matrix4 实现 Y 轴旋转
        // 当角度接近 pi/2 时，宽度为0，实现翻转效果
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);
        // 当角度超过 pi/2 时，内容应该反过来，但这里我们使用 AnimatedSwitcher 的换子逻辑
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}
