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
  DatabaseHelper databaseHelper = DatabaseHelper();
  late List<Map<String, dynamic>> dataList = [];
  late String result = "";
  
  



  @override
  void initState() {
    super.initState();
    resetGame();
    initDatabase();
    fetchDataFromDatabase();

  }

  Future<void> initDatabase() async {
  await databaseHelper.initDB();
}

Future<void> fetchDataFromDatabase() async {
  Database db = await databaseHelper.initDB();
  List<Map<String, dynamic>> data = await db.query('History', orderBy: 'id DESC');
  print(data);
  setState(() {
    dataList = data;
  });
}



  // Future<void> checkDatabase() async{
  //   bool isOpen = await DatabaseHelper().isDatabaseOpen();
  //   print('Database is open : $isOpen');
  // }

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
    result = "Player O Win";
    List<int> bestMove = board.minimax('O');
    if (bestMove[1] != -1 && bestMove[2] != -1) {
      setState(() {
        board.board[bestMove[1]][bestMove[2]] = 'O';
        playerTurn = true;
        if (board.checkWin('O')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(result),
              actions: [
                TextButton(
                  onPressed: () async{
                    await databaseHelper.insertData("Player O Win");
                    fetchDataFromDatabase();
                    Navigator.of(context).pop();
                    resetGame();
                  },
                  child: Text('Play Again & Save'),
                ),
              ],
            ),
          );
        }
      });
    }
  }

  void playerMove(int row, int col) {
    result = "Player X Win";
    if (board.board[row][col] == '' && playerTurn) {
      setState(() {
        board.board[row][col] = 'X';
        playerTurn = false;

        if (board.checkWin('X')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(result),
              actions: [
                TextButton (
                  onPressed: () async{
                    await databaseHelper.insertData(result);
                    Navigator.of(context).pop();
                    fetchDataFromDatabase();
                    resetGame();
                  },
                  child: Text('Play Again & Save'),
                ),
              ],
            ),
          );
       } else if (board.isBoardFull()) {
        result = "It\'s a Tie!";
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(result),
      actions: [
        ElevatedButton(
          onPressed: () async{
            Navigator.of(context).pop();
          resetGame();
          await databaseHelper.insertData(result);
          },
          
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
      
  
      Padding(padding: const EdgeInsets.only(right:300,top: 20,bottom: 10),
        child: Text("History",
          style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 20),
        ),
      ),

         Expanded(
  child: ListView.builder(
    itemCount: dataList.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text('Result'),
        subtitle: Text('${dataList[index]['winner']}'),
      );
    },
  ),
)
          ],
        ),
      ),
      
    );
  }
}
