import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MinesweeperPage extends StatefulWidget {
  const MinesweeperPage({super.key});

  @override
  State<MinesweeperPage> createState() => _MinesweeperPageState();
}

class _MinesweeperPageState extends State<MinesweeperPage> {
  static const int rows = 9;
  static const int cols = 9;
  static const int mineCount = 10;

  // Cell states
  late List<List<CellData>> _grid;
  bool _gameOver = false;
  bool _gameWon = false;
  bool _firstClick = true;
  int _flagCount = 0;
  int _revealedCount = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  final Random _random = Random();

  // Number colors
  static const Map<int, Color> numberColors = {
    1: Color(0xFF1565C0), // Blue
    2: Color(0xFF2E7D32), // Green
    3: Color(0xFFC62828), // Red
    4: Color(0xFF0D47A1), // Dark blue
    5: Color(0xFF4A148C), // Purple
    6: Color(0xFF006064), // Teal
    7: Color(0xFF37474F), // Dark grey
    8: Color(0xFF616161), // Grey
  };

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
    _grid = List.generate(
      rows,
      (_) => List.generate(cols, (_) => CellData()),
    );
    _gameOver = false;
    _gameWon = false;
    _firstClick = true;
    _flagCount = 0;
    _revealedCount = 0;
    _elapsedSeconds = 0;
    _timer?.cancel();
    _timer = null;
  }

  void _placeMines(int safeRow, int safeCol) {
    int placed = 0;
    while (placed < mineCount) {
      final r = _random.nextInt(rows);
      final c = _random.nextInt(cols);
      // Skip the first clicked cell and its neighbors
      if ((r == safeRow && c == safeCol) ||
          (r >= safeRow - 1 &&
              r <= safeRow + 1 &&
              c >= safeCol - 1 &&
              c <= safeCol + 1)) {
        continue;
      }
      if (!_grid[r][c].isMine) {
        _grid[r][c].isMine = true;
        placed++;
      }
    }

    // Calculate numbers
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (_grid[r][c].isMine) continue;
        int count = 0;
        for (final neighbor in _getNeighbors(r, c)) {
          if (_grid[neighbor.$1][neighbor.$2].isMine) count++;
        }
        _grid[r][c].adjacentMines = count;
      }
    }

    _startTimer();
  }

  List<(int, int)> _getNeighbors(int row, int col) {
    final List<(int, int)> neighbors = [];
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr;
        final nc = col + dc;
        if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
          neighbors.add((nr, nc));
        }
      }
    }
    return neighbors;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_gameOver && !_gameWon) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _onCellTap(int row, int col) {
    if (_gameOver || _gameWon) return;
    final cell = _grid[row][col];
    if (cell.isRevealed || cell.isFlagged) return;

    if (_firstClick) {
      _firstClick = false;
      _placeMines(row, col);
    }

    setState(() {
      if (cell.isMine) {
        _revealAllMines();
        _gameOver = true;
        _timer?.cancel();
      } else {
        _revealCell(row, col);
        _checkWinCondition();
      }
    });
  }

  void _onCellLongPress(int row, int col) {
    if (_gameOver || _gameWon) return;
    final cell = _grid[row][col];
    if (cell.isRevealed) return;

    setState(() {
      cell.isFlagged = !cell.isFlagged;
      _flagCount += cell.isFlagged ? 1 : -1;
    });
  }

  void _revealCell(int row, int col) {
    final cell = _grid[row][col];
    if (cell.isRevealed || cell.isFlagged || cell.isMine) return;

    cell.isRevealed = true;
    _revealedCount++;

    // Flood fill for blank cells
    if (cell.adjacentMines == 0) {
      for (final neighbor in _getNeighbors(row, col)) {
        _revealCell(neighbor.$1, neighbor.$2);
      }
    }
  }

  void _revealAllMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (_grid[r][c].isMine) {
          _grid[r][c].isRevealed = true;
        }
      }
    }
  }

  void _checkWinCondition() {
    // Win when all non-mine cells are revealed
    final totalSafeCells = rows * cols - mineCount;
    if (_revealedCount >= totalSafeCells) {
      _gameWon = true;
      _timer?.cancel();
      // Auto-flag remaining mines
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (_grid[r][c].isMine && !_grid[r][c].isFlagged) {
            _grid[r][c].isFlagged = true;
            _flagCount++;
          }
        }
      }
    }
  }

  void _resetGame() {
    _timer?.cancel();
    setState(() {
      _initGame();
    });
  }

  String get _formattedTime {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get _remainingMines => mineCount - _flagCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('扫雷'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Top info bar
            _buildInfoBar(theme),
            const SizedBox(height: 8),
            // Game status
            _buildGameStatus(theme),
            const SizedBox(height: 12),
            // Game grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildGrid(),
              ),
            ),
            // Restart button
            _buildRestartButton(theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Mine count
            Row(
              children: [
                const Text('💣', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  '$_remainingMines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _remainingMines < 0
                        ? Colors.red
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            // Timer
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 6),
                Text(
                  _formattedTime,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStatus(ThemeData theme) {
    String text;
    Color textColor;

    if (_gameOver) {
      text = '💥 游戏结束！';
      textColor = Colors.red;
    } else if (_gameWon) {
      text = '🎉 恭喜你赢了！';
      textColor = Colors.green;
    } else {
      text = '点击格子开始游戏';
      textColor = theme.colorScheme.onSurface;
    }

    if (_gameOver || _gameWon) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            text,
            key: ValueKey('${_gameOver}_$_gameWon'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final availableSize = maxWidth < constraints.maxHeight
            ? maxWidth
            : constraints.maxHeight;
        final cellSize = (availableSize - (cols - 1) * 2) / cols;

        return Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            padding: const EdgeInsets.all(4),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                final row = index ~/ cols;
                final col = index % cols;
                return _buildCell(row, col, cellSize);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(int row, int col, double cellSize) {
    final cell = _grid[row][col];
    final isExploded = cell.isMine && cell.isRevealed && _gameOver;

    Color backgroundColor;
    Widget? child;

    if (cell.isRevealed) {
      if (cell.isMine) {
        backgroundColor = isExploded ? Colors.red.shade400 : Colors.grey[300]!;
        child = const Text('💣', style: TextStyle(fontSize: 16));
      } else if (cell.adjacentMines > 0) {
        backgroundColor = Colors.grey[300]!;
        child = Text(
          '${cell.adjacentMines}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: numberColors[cell.adjacentMines] ?? Colors.black,
          ),
        );
      } else {
        backgroundColor = Colors.grey[300]!;
      }
    } else if (cell.isFlagged) {
      backgroundColor = Colors.grey.shade100;
      child = const Text('🚩', style: TextStyle(fontSize: 16));
    } else {
      backgroundColor = Colors.grey.shade50;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _onCellTap(row, col),
        onLongPress: () => _onCellLongPress(row, col),
        child: Center(child: child ?? const SizedBox.shrink()),
      ),
    );
  }

  Widget _buildRestartButton(ThemeData theme) {
    return FilledButton.icon(
      onPressed: _resetGame,
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.refresh),
      label: const Text(
        '重新开始',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class CellData {
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int adjacentMines = 0;
}
