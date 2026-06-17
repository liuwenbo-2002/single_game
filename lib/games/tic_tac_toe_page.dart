import 'package:flutter/material.dart';

class TicTacToePage extends StatefulWidget {
  const TicTacToePage({super.key});

  @override
  State<TicTacToePage> createState() => _TicTacToePageState();
}

class _TicTacToePageState extends State<TicTacToePage> {
  static const int gridSize = 3;
  static const Color xColor = Color(0xFFE57373); // Soft red for X
  static const Color oColor = Color(0xFF64B5F6); // Soft blue for O

  List<String?> _board = List.filled(gridSize * gridSize, null);
  bool _isXNext = true;
  String? _winner;
  List<int>? _winningLine;
  bool _isDraw = false;

  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;

  void _resetGame() {
    setState(() {
      _board = List.filled(gridSize * gridSize, null);
      _isXNext = true;
      _winner = null;
      _winningLine = null;
      _isDraw = false;
    });
  }

  void _onCellTapped(int index) {
    if (_board[index] != null || _winner != null || _isDraw) return;

    setState(() {
      _board[index] = _isXNext ? 'X' : 'O';
      _checkGameState();
      if (_winner == null && !_isDraw) {
        _isXNext = !_isXNext;
      }
    });
  }

  void _checkGameState() {
    // All possible winning lines: rows, columns, diagonals
    final List<List<int>> lines = [
      // Rows
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      // Columns
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      // Diagonals
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final line in lines) {
      final a = line[0];
      final b = line[1];
      final c = line[2];
      if (_board[a] != null &&
          _board[a] == _board[b] &&
          _board[a] == _board[c]) {
        _winner = _board[a];
        _winningLine = line;
        if (_winner == 'X') {
          _xWins++;
        } else {
          _oWins++;
        }
        return;
      }
    }

    // Check for draw
    if (_board.every((cell) => cell != null)) {
      _isDraw = true;
      _draws++;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('井字棋'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Scoreboard
            _buildScoreboard(theme),
            const SizedBox(height: 8),
            // Status text
            _buildStatusText(theme),
            const SizedBox(height: 16),
            // Game board
            _buildBoard(),
            const SizedBox(height: 24),
            // Restart button
            _buildRestartButton(theme),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboard(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildScoreItem('X (胜)', _xWins, xColor),
            Container(
              width: 1,
              height: 32,
              color: theme.dividerColor,
            ),
            _buildScoreItem('O (胜)', _oWins, oColor),
            Container(
              width: 1,
              height: 32,
              color: theme.dividerColor,
            ),
            _buildScoreItem('平局', _draws, theme.colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusText(ThemeData theme) {
    String text;
    Color textColor;

    if (_winner != null) {
      text = '🎉 玩家 ${_winner == 'X' ? 'X' : 'O'} 获胜！';
      textColor = _winner == 'X' ? xColor : oColor;
    } else if (_isDraw) {
      text = '🤝 平局！';
      textColor = theme.colorScheme.onSurface;
    } else {
      text = '轮到 ${_isXNext ? 'X' : 'O'} 落子';
      textColor = _isXNext ? xColor : oColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          text,
          key: ValueKey(text),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[100],
          ),
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: gridSize * gridSize,
            itemBuilder: (context, index) {
              return _buildCell(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    final value = _board[index];
    final isWinningCell = _winningLine?.contains(index) ?? false;

    Color cellColor = Colors.white;
    if (value == 'X') {
      cellColor = xColor.withValues(alpha: 0.1);
    } else if (value == 'O') {
      cellColor = oColor.withValues(alpha: 0.1);
    }

    Color? borderColor;
    if (isWinningCell) {
      borderColor = Colors.amber.shade600;
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 3)
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onCellTapped(index),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: value != null
                ? Text(
                    value,
                    key: ValueKey('$index-$value'),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: value == 'X' ? xColor : oColor,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
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
