import 'dart:math';
import 'package:flutter/material.dart';

class Game2048Page extends StatefulWidget {
  const Game2048Page({super.key});

  @override
  State<Game2048Page> createState() => _Game2048PageState();
}

class _Game2048PageState extends State<Game2048Page> {
  static const int gridSize = 4;
  static const int winValue = 2048;

  late List<List<int>> _grid;
  int _score = 0;
  bool _isGameOver = false;
  bool _hasWon = false;
  bool _keepPlaying = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    _score = 0;
    _isGameOver = false;
    _hasWon = false;
    _keepPlaying = false;
    _spawnTile();
    _spawnTile();
  }

  void _spawnTile() {
    final emptyCells = <int>[];
    for (int i = 0; i < gridSize * gridSize; i++) {
      final row = i ~/ gridSize;
      final col = i % gridSize;
      if (_grid[row][col] == 0) {
        emptyCells.add(i);
      }
    }
    if (emptyCells.isEmpty) return;

    final index = emptyCells[_random.nextInt(emptyCells.length)];
    final row = index ~/ gridSize;
    final col = index % gridSize;
    _grid[row][col] = _random.nextDouble() < 0.9 ? 2 : 4;
  }

  bool _isGridFull() {
    for (final row in _grid) {
      if (row.contains(0)) return false;
    }
    return true;
  }

  bool _canMerge() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (j + 1 < gridSize && _grid[i][j] == _grid[i][j + 1]) return true;
        if (i + 1 < gridSize && _grid[i][j] == _grid[i + 1][j]) return true;
      }
    }
    return false;
  }

  /// Returns the merged row and the score gained from merging.
  _SlideResult _slideAndMerge(List<int> row) {
    final filtered = row.where((v) => v != 0).toList();
    final merged = <int>[];
    int gainedScore = 0;
    int i = 0;
    while (i < filtered.length) {
      if (i + 1 < filtered.length && filtered[i] == filtered[i + 1]) {
        final mergedValue = filtered[i] * 2;
        merged.add(mergedValue);
        gainedScore += mergedValue;
        i += 2;
      } else {
        merged.add(filtered[i]);
        i++;
      }
    }
    while (merged.length < gridSize) {
      merged.add(0);
    }
    return _SlideResult(merged, gainedScore);
  }

  bool _moveLeft() {
    bool changed = false;
    int gainedScore = 0;
    for (int i = 0; i < gridSize; i++) {
      final result = _slideAndMerge(_grid[i]);
      if (result.row.join(',') != _grid[i].join(',')) {
        changed = true;
      }
      _grid[i] = result.row;
      gainedScore += result.score;
    }
    if (changed) {
      setState(() {
        _score += gainedScore;
      });
    }
    return changed;
  }

  bool _moveRight() {
    bool changed = false;
    int gainedScore = 0;
    for (int i = 0; i < gridSize; i++) {
      final reversed = _grid[i].reversed.toList();
      final result = _slideAndMerge(reversed);
      final newRow = result.row.reversed.toList();
      if (newRow.join(',') != _grid[i].join(',')) {
        changed = true;
      }
      _grid[i] = newRow;
      gainedScore += result.score;
    }
    if (changed) {
      setState(() {
        _score += gainedScore;
      });
    }
    return changed;
  }

  List<int> _getColumn(int col) {
    return List.generate(gridSize, (i) => _grid[i][col]);
  }

  void _setColumn(int col, List<int> values) {
    for (int i = 0; i < gridSize; i++) {
      _grid[i][col] = values[i];
    }
  }

  bool _moveUp() {
    bool changed = false;
    int gainedScore = 0;
    for (int j = 0; j < gridSize; j++) {
      final col = _getColumn(j);
      final result = _slideAndMerge(col);
      if (result.row.join(',') != col.join(',')) {
        changed = true;
      }
      _setColumn(j, result.row);
      gainedScore += result.score;
    }
    if (changed) {
      setState(() {
        _score += gainedScore;
      });
    }
    return changed;
  }

  bool _moveDown() {
    bool changed = false;
    int gainedScore = 0;
    for (int j = 0; j < gridSize; j++) {
      final col = _getColumn(j).reversed.toList();
      final result = _slideAndMerge(col);
      final newCol = result.row.reversed.toList();
      if (newCol.join(',') != _getColumn(j).join(',')) {
        changed = true;
      }
      _setColumn(j, newCol);
      gainedScore += result.score;
    }
    if (changed) {
      setState(() {
        _score += gainedScore;
      });
    }
    return changed;
  }

  void _handleMove(Direction2048 direction) {
    if (_isGameOver) return;
    if (_hasWon && !_keepPlaying) return;

    bool changed;
    switch (direction) {
      case Direction2048.left:
        changed = _moveLeft();
        break;
      case Direction2048.right:
        changed = _moveRight();
        break;
      case Direction2048.up:
        changed = _moveUp();
        break;
      case Direction2048.down:
        changed = _moveDown();
        break;
    }

    if (changed) {
      _spawnTile();

      if (!_hasWon && !_keepPlaying) {
        for (final row in _grid) {
          if (row.contains(winValue)) {
            setState(() {
              _hasWon = true;
            });
            _showWinDialog();
            return;
          }
        }
      }

      if (_isGridFull() && !_canMerge()) {
        setState(() {
          _isGameOver = true;
        });
        _showGameOverDialog();
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 恭喜你赢了！'),
        content: const Text('你达到了 2048！'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _keepPlaying = true;
              });
            },
            child: const Text('继续游戏'),
          ),
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

  void _restart() {
    setState(() {
      _initGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '分数',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withAlpha(180),
                          ),
                        ),
                        Text(
                          '$_score',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _restart,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('重新开始'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final boardSize = min(screenWidth - 32, 400.0);
                    return _buildGameBoard(boardSize);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard(double size) {
    final cellSize = (size - 16) / gridSize;
    final gap = 4.0;
    final totalCells = gridSize * gridSize;

    return GestureDetector(
      onPanEnd: (details) {
        final velocity = details.velocity;
        final dx = velocity.pixelsPerSecond.dx;
        final dy = velocity.pixelsPerSecond.dy;

        if (dx.abs() > dy.abs()) {
          if (dx > 0) {
            _handleMove(Direction2048.right);
          } else {
            _handleMove(Direction2048.left);
          }
        } else {
          if (dy > 0) {
            _handleMove(Direction2048.down);
          } else {
            _handleMove(Direction2048.up);
          }
        }
      },
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.brown[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Background grid cells
            ...List.generate(totalCells, (index) {
              final row = index ~/ gridSize;
              final col = index % gridSize;
              return Positioned(
                left: col * (cellSize + gap),
                top: row * (cellSize + gap),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: Colors.brown[100]?.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
            // Tiles
            ...List.generate(totalCells, (index) {
              final row = index ~/ gridSize;
              final col = index % gridSize;
              final value = _grid[row][col];
              if (value == 0) return const SizedBox.shrink();

              return Positioned(
                left: col * (cellSize + gap),
                top: row * (cellSize + gap),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: _getTileColor(value),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: value >= 1000 ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(value),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        if (value > 2048) {
          return const Color(0xFF3C3A32);
        }
        return const Color(0xFFCDC1B4);
    }
  }

  Color _getTextColor(int value) {
    if (value <= 4) {
      return const Color(0xFF776E65);
    }
    return const Color(0xFFF9F6F2);
  }
}

enum Direction2048 { up, down, left, right }

class _SlideResult {
  final List<int> row;
  final int score;

  const _SlideResult(this.row, this.score);
}
