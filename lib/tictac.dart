class TicTacToeBoard {
  final int size;
  late List<List<String>> board;

  TicTacToeBoard(this.size) {
    board = List.generate(size, (_) => List.filled(size, '')); //board
  }

  bool isBoardFull() {//check board
    for (var row in board) {
      if (row.contains('')) {
        return false;
      }
    }
    return true;
  }
  
  //win check
  bool checkWin(String player) {
    for (int i = 0; i < size; i++) {
      bool win = true;
      for (int j = 0; j < size; j++) {
        if (board[j][i] != player) {
          win = false;
          break;
        }
      }
      if (win) {
        return true;
      }
    }

    for (int i = 0; i < size; i++) {
      bool win = true;
      for (int j = 0; j < size; j++) {
        if (board[i][j] != player) {
          win = false;
          break;
        }  
      }
      if (win) {
        return true;
      }
    }

    bool winDiagonal1 = true;
    bool winDiagonal2 = true;
    for (int i = 0; i < size; i++) {
      if (board[i][i] != player) {
        winDiagonal1 = false;
      }
      if (board[i][size - 1 - i] != player) {
        winDiagonal2 = false;
      }
    }
    if (winDiagonal1 || winDiagonal2) {
      return true;
    }

    return false;
  }

  List<int> minimax(String player) {
    int bestScore = (player == 'O') ? -1000 : 1000;
    late List<int> bestMove = [-1, -1];

    if (checkWin('X')) {
      return [-10, -1, -1];
    } else if (checkWin('O')) {
      return [10, -1, -1];
    } else if (isBoardFull()) {
      return [0, -1, -1];
    }

    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (board[i][j] == '') {
          board[i][j] = player;
          List<int> scoreMove = minimax((player == 'O') ? 'X' : 'O');
          board[i][j] = '';

          if (player == 'O') {
            if (scoreMove[0] > bestScore) {
              bestScore = scoreMove[0];
              bestMove = [i, j];
            }
          } else {
            if (scoreMove[0] < bestScore) {
              bestScore = scoreMove[0];
              bestMove = [i, j];
            }
          }
        }
      }
    }

    return [bestScore, bestMove[0], bestMove[1]];
  }
}
