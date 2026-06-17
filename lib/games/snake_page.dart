import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakePage extends StatefulWidget {
  const SnakePage({super.key});

  @override
  State<SnakePage> createState() => _SnakePageState();
}

class _SnakePageState extends State<SnakePage> {
  static const int gridSize = 20;
  static const int initialSpeedMs = 250;

  late List<Offset> _snake;
  Offset _food = Offset.zero;
  Direction _direction = Direction.right;
  Direction _nextDirection = Direction.right;
  int _score = 0;
  int _speedMs = initialSpeedMs;
  bool _isGameOver = false;
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initGame() {
    final startX = gridSize ~/ 2;
    final startY = gridSize ~/ 2;
    _snake = [
      Offset(startX.toDouble(), startY.toDouble()),
      Offset((startX - 1).toDouble(), startY.toDouble()),
      Offset((startX - 2).toDouble(), startY.toDouble()),
    ];
    _direction = Direction.right;
    _nextDirection = Direction.right;
    _score = 0;
    _speedMs = initialSpeedMs;
    _isGameOver = false;
    _generateFood();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _speedMs), (_) => _update());
  }

  void _generateFood() {
    final occupied = _snake.toSet();
    final available = <Offset>[];
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final pos = Offset(x.toDouble(), y.toDouble());
        if (!occupied.contains(pos)) {
          available.add(pos);
        }
      }
    }
    if (available.isNotEmpty) {
      _food = available[_random.nextInt(available.length)];
    }
  }

  void _update() {
    if (_isGameOver) return;

    _direction = _nextDirection;
    final head = _snake.first;
    Offset newHead;

    switch (_direction) {
      case Direction.up:
        newHead = Offset(head.dx, head.dy - 1);
        break;
      case Direction.down:
        newHead = Offset(head.dx, head.dy + 1);
        break;
      case Direction.left:
        newHead = Offset(head.dx - 1, head.dy);
        break;
      case Direction.right:
        newHead = Offset(head.dx + 1, head.dy);
        break;
    }

    // Check wall collision
    if (newHead.dx < 0 ||
        newHead.dx >= gridSize ||
        newHead.dy < 0 ||
        newHead.dy >= gridSize) {
      _gameOver();
      return;
    }

    // Check self collision
    if (_snake.contains(newHead)) {
      _gameOver();
      return;
    }

    setState(() {
      _snake.insert(0, newHead);

      if (newHead == _food) {
        _score += 10;
        _generateFood();
        _speedMs = max(80, _speedMs - 5);
        _timer?.cancel();
        _timer = Timer.periodic(Duration(milliseconds: _speedMs), (_) => _update());
      } else {
        _snake.removeLast();
      }
    });
  }

  void _gameOver() {
    _timer?.cancel();
    setState(() {
      _isGameOver = true;
    });
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('游戏结束'),
        content: Text('最终得分: $_score'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restart();
            },
            child: const Text('重新开始'),
          ),
        ],
      ),
    );
  }

  void _changeDirection(Direction newDirection) {
    if (_isGameOver) return;
    if ((_direction == Direction.up && newDirection == Direction.down) ||
        (_direction == Direction.down && newDirection == Direction.up) ||
        (_direction == Direction.left && newDirection == Direction.right) ||
        (_direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    _nextDirection = newDirection;
  }

  void _restart() {
    setState(() {
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('贪吃蛇'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              '分数: $_score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: gridSize * 18.0,
                height: gridSize * 18.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    childAspectRatio: 1,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    final x = index % gridSize;
                    final y = index ~/ gridSize;
                    final pos = Offset(x.toDouble(), y.toDouble());

                    if (_isGameOver) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      );
                    }

                    if (pos == _food) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      );
                    }

                    if (_snake.contains(pos)) {
                      final isHead = pos == _snake.first;
                      return Container(
                        decoration: BoxDecoration(
                          color: isHead ? Colors.green[700] : Colors.green,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDirectionButton(
                  icon: Icons.keyboard_arrow_up,
                  onTap: () => _changeDirection(Direction.up),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDirectionButton(
                      icon: Icons.keyboard_arrow_left,
                      onTap: () => _changeDirection(Direction.left),
                    ),
                    const SizedBox(width: 64),
                    _buildDirectionButton(
                      icon: Icons.keyboard_arrow_right,
                      onTap: () => _changeDirection(Direction.right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDirectionButton(
                  icon: Icons.keyboard_arrow_down,
                  onTap: () => _changeDirection(Direction.down),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

enum Direction { up, down, left, right }
