import 'dart:math';
import 'package:flutter/material.dart';

/// 数独游戏页面
class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  static const int _gridSize = 9;
  static const int _boxSize = 3;

  // 难度配置：[挖空数量, 提示次数]
  static const Map<String, List<int>> _difficulties = {
    '简单': [30, 10],
    '中等': [45, 5],
    '困难': [55, 3],
  };

  late List<List<int>> _solution; // 完整解
  late List<List<int?>> _board; // 当前盘面（null 表示空格）
  late List<List<bool>> _given; // 是否是初始给定的数字
  late List<List<bool>> _isWrong; // 标记错误
  late String _currentDifficulty;
  int _hintCount = 0;

  @override
  void initState() {
    super.initState();
    _currentDifficulty = '中等';
    _newGame(_currentDifficulty);
  }

  void _newGame(String difficulty) {
    final rng = Random();
    _solution = _generateFullSolution(rng);
    _currentDifficulty = difficulty;
    final blanks = _difficulties[difficulty]![0];
    _hintCount = _difficulties[difficulty]![1];

    // 复制解并挖空
    _board = List.generate(
      _gridSize,
      (r) => List<int?>.from(_solution[r].map((v) => v)),
    );
    _given = List.generate(
      _gridSize,
      (r) => List<bool>.filled(_gridSize, true),
    );
    _isWrong = List.generate(
      _gridSize,
      (r) => List<bool>.filled(_gridSize, false),
    );

    // 随机挖空
    final positions = List.generate(_gridSize * _gridSize, (i) => i);
    positions.shuffle(rng);
    for (int i = 0; i < blanks && i < positions.length; i++) {
      final r = positions[i] ~/ _gridSize;
      final c = positions[i] % _gridSize;
      _board[r][c] = null;
      _given[r][c] = false;
    }
  }

  /// 生成一个完整的有效数独解
  List<List<int>> _generateFullSolution(Random rng) {
    final board = List.generate(_gridSize, (_) => List.filled(_gridSize, 0));
    _fillBoard(board, rng);
    return board;
  }

  bool _fillBoard(List<List<int>> board, Random rng) {
    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (board[r][c] == 0) {
          final nums = List.generate(_gridSize, (i) => i + 1);
          nums.shuffle(rng);
          for (final num in nums) {
            if (_isValidPlacement(board, r, c, num)) {
              board[r][c] = num;
              if (_fillBoard(board, rng)) {
                return true;
              }
              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValidPlacement(
      List<List<int>> board, int row, int col, int num) {
    // 检查行
    for (int c = 0; c < _gridSize; c++) {
      if (board[row][c] == num) return false;
    }
    // 检查列
    for (int r = 0; r < _gridSize; r++) {
      if (board[r][col] == num) return false;
    }
    // 检查3x3宫格
    final boxRow = (row ~/ _boxSize) * _boxSize;
    final boxCol = (col ~/ _boxSize) * _boxSize;
    for (int r = boxRow; r < boxRow + _boxSize; r++) {
      for (int c = boxCol; c < boxCol + _boxSize; c++) {
        if (board[r][c] == num) return false;
      }
    }
    return true;
  }

  void _onCellTap(int row, int col) {
    if (_given[row][col]) return; // 初始数字不可编辑

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _buildNumberPicker(ctx, row, col, colorScheme),
    );
  }

  Widget _buildNumberPicker(
      BuildContext ctx, int row, int col, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '选择数字',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(9, (i) {
              final num = i + 1;
              // 检查该数字在行/列/宫格中是否已存在（用于视觉提示）
              final isInRow = _board[row].contains(num);
              final isInCol =
                  _board.any((r) => r[col] == num);
              final boxRow = (row ~/ _boxSize) * _boxSize;
              final boxCol = (col ~/ _boxSize) * _boxSize;
              bool isInBox = false;
              for (int r = boxRow; r < boxRow + _boxSize; r++) {
                for (int c = boxCol; c < boxCol + _boxSize; c++) {
                  if (_board[r][c] == num) {
                    isInBox = true;
                    break;
                  }
                }
                if (isInBox) break;
              }
              final isConflict = isInRow || isInCol || isInBox;

              return SizedBox(
                width: 56,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    _placeNumber(row, col, num);
                    Navigator.of(ctx).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: isConflict
                        ? colorScheme.errorContainer
                        : colorScheme.primaryContainer,
                    foregroundColor: isConflict
                        ? colorScheme.onErrorContainer
                        : colorScheme.onPrimaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    '$num',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              _placeNumber(row, col, null);
              Navigator.of(ctx).pop();
            },
            icon: const Icon(Icons.clear, size: 18),
            label: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _placeNumber(int row, int col, int? num) {
    setState(() {
      _board[row][col] = num;
      if (num == null) {
        _isWrong[row][col] = false;
      } else {
        _isWrong[row][col] = (num != _solution[row][col]);
      }
    });

    // 检查是否胜利
    if (_checkVictory()) {
      _showVictory();
    }
  }

  bool _checkVictory() {
    for (int r = 0; r < _gridSize; r++) {
      for (int c = 0; c < _gridSize; c++) {
        if (_board[r][c] == null || _board[r][c] != _solution[r][c]) {
          return false;
        }
      }
    }
    return true;
  }

  void _showVictory() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('🎉 恭喜通关！'),
        content: Text(
          '你成功完成了 $_currentDifficulty 级别的数独！\n'
          '剩余提示次数：$_hintCount',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('太棒了！'),
          ),
        ],
      ),
    );
  }

  void _useHint() {
    if (_hintCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('提示次数已用完！'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // 找到一个空格填入正确答案
    final rng = Random();
    final emptyCells = <int>[];
    for (int i = 0; i < _gridSize * _gridSize; i++) {
      final r = i ~/ _gridSize;
      final c = i % _gridSize;
      if (_board[r][c] == null) {
        emptyCells.add(i);
      }
    }
    if (emptyCells.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('没有空单元格了！'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final idx = emptyCells[rng.nextInt(emptyCells.length)];
    final r = idx ~/ _gridSize;
    final c = idx % _gridSize;

    setState(() {
      _board[r][c] = _solution[r][c];
      _given[r][c] = true; // 提示填入后变为不可编辑
      _isWrong[r][c] = false;
      _hintCount--;
    });

    // 检查胜利
    if (_checkVictory()) {
      _showVictory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // 顶部信息栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // 难度显示
                _InfoChip(
                  icon: Icons.tune,
                  label: _currentDifficulty,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                // 提示次数
                _InfoChip(
                  icon: Icons.lightbulb_outline,
                  label: '提示: $_hintCount',
                  color: colorScheme.tertiary,
                ),
                const Spacer(),
                // 新游戏按钮
                FilledButton.tonalIcon(
                  onPressed: () => _showNewGameDialog(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('新游戏'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 数独网格
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = constraints.maxWidth / _gridSize;
                      return Column(
                        children: List.generate(_gridSize, (row) {
                          return Expanded(
                            child: Row(
                              children:
                                  List.generate(_gridSize, (col) {
                                return _buildCell(
                                  row,
                                  col,
                                  cellSize,
                                  colorScheme,
                                );
                              }),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // 底部操作
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.tonalIcon(
                onPressed: _useHint,
                icon: const Icon(Icons.lightbulb),
                label: Text('提示 (剩余 $_hintCount)'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col, double cellSize, ColorScheme colorScheme) {
    final value = _board[row][col];
    final isGiven = _given[row][col];
    final isWrong = _isWrong[row][col];

    // 判断是否是宫格边框
    final isRightBorder = (col + 1) % _boxSize == 0 && col != _gridSize - 1;
    final isBottomBorder = (row + 1) % _boxSize == 0 && row != _gridSize - 1;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isRightBorder
                  ? colorScheme.onSurface
                  : colorScheme.outlineVariant,
              width: isRightBorder ? 2.0 : 0.5,
            ),
            bottom: BorderSide(
              color: isBottomBorder
                  ? colorScheme.onSurface
                  : colorScheme.outlineVariant,
              width: isBottomBorder ? 2.0 : 0.5,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () => _onCellTap(row, col),
          child: Container(
            color: isWrong
                ? colorScheme.errorContainer.withValues(alpha: 0.3)
                : null,
            alignment: Alignment.center,
            child: value != null
                ? Text(
                    '$value',
                    style: TextStyle(
                      fontSize: cellSize * 0.45,
                      fontWeight:
                          isGiven ? FontWeight.bold : FontWeight.normal,
                      color: isWrong
                          ? colorScheme.error
                          : isGiven
                              ? colorScheme.onSurface
                              : colorScheme.primary,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _showNewGameDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择难度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _difficulties.keys.map((difficulty) {
            final blanks = _difficulties[difficulty]![0];
            final hints = _difficulties[difficulty]![1];
            final isSelected = difficulty == _currentDifficulty;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(difficulty),
                subtitle: Text('挖空 $blanks 格 / 提示 $hints 次'),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                selected: isSelected,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _newGame(difficulty);
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 信息展示小部件
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
