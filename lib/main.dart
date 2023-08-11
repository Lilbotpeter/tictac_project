import 'package:flutter/material.dart';
import 'package:tic_project/local_database.dart';
import 'package:tic_project/tictac.dart';
import 'package:sqflite/sqflite.dart';


void main() {
  
  runApp(TicTacToeApp());
  
}

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TicTacToeGame(size: 3),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  final int size; 

  TicTacToeGame({required this.size});

  @override
  _TicTacToeGameState createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  late TicTacToeBoard board;
  late bool playerTurn;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

void resetGame() {
  setState(() {
    board = TicTacToeBoard(widget.size);
    playerTurn = true;
    if (board.size % 2 == 0) {
      playerTurn = false;
      AIMove();
    }
  });
}

  void AIMove() {
    List<int> bestMove = board.minimax('O');
    if (bestMove[1] != -1 && bestMove[2] != -1) {
      setState(() {
        board.board[bestMove[1]][bestMove[2]] = 'O';
        playerTurn = true;
        if (board.checkWin('O')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Player O Wins!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                  },
                  child: Text('Play Again'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  void playerMove(int row, int col) {
    if (board.board[row][col] == '' && playerTurn) {
      setState(() {
        board.board[row][col] = 'X';
        playerTurn = false;

        if (board.checkWin('X')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Player X Wins!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                  },
                  child: Text('Play Again'),
                ),
              ],
            ),
          );
       } else if (board.isBoardFull()) {
  //showPlayHistory(); 
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('It\'s a Tie!'),
      actions: [
        ElevatedButton(
          onPressed: (){Navigator.of(context).pop();
          resetGame();},
          child: Text('Reset Game'),
        ),
      ],
    ),
  );
} else {
  AIMove();
}
      });
    }
  }

  

  Future<void> savePlayHistory(String result) async {
    await DatabaseHelper.instance.insertPlayHistory(
      playerTurn ? 'X' : 'O',
      result,
    );
  }

  Future<void> showPlayHistory() async {
    List<Map<String, dynamic>> playHistory =
        await DatabaseHelper.instance.queryAllPlayHistory();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Play History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: playHistory.map((historyItem) {
            return ListTile(
              title: Text('Player: ${historyItem['player']}'),
              subtitle: Text('Result: ${historyItem['result']}'),
            );
          }).toList(),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange,
        shadowColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.size,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: widget.size * widget.size,
        itemBuilder: (context, index) {
          int row = index ~/ widget.size;
          int col = index % widget.size;
          return GestureDetector(
        onTap: () => playerMove(row, col),
        child: Container(
          color: const Color.fromARGB(255, 243, 170, 33),
          alignment: Alignment.center,
          child: Text(
            board.board[row][col],
            style: TextStyle(fontSize: 32),
          ),
        ),
          );
        },
      ),
      
      
            IconButton(
              onPressed: resetGame,
              icon: Icon(Icons.restart_alt_outlined,size: 30,),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     savePlayHistory('Saved');
            //   },
            //   child: Text('Save Play History'),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 120,vertical: 15 ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange
                ),
                onPressed: () {
                  showPlayHistory();
                },
                child: Text('Show History'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
