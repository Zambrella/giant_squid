import 'package:giant_squid/giant_squid.dart' as giant_squid;
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';

class Square {
  Square(this.number, this.isMarked);
  int number;
  bool isMarked;

  @override
  String toString() {
    return '{$number:$isMarked}';
  }
}

typedef Board = List<List<Square>>;
typedef Numbers = List<int>;

void main(List<String> arguments) async {
  ArgParser parser = ArgParser()..addOption('fileLocation', abbr: 'f');
  ArgResults argResults = parser.parse(arguments);
  final path = argResults['fileLocation'];
  final file = await File(path).readAsString();
  final List<String> list = LineSplitter().convert(file);
  final numbers = parseNumbers(list[0]);
  final boards = parseBoards(list.sublist(1), 5);
  print(calculateWinningBoard(boards, numbers));
}

int? calculateWinningBoard(List<Board> boards, Numbers numbers) {
  for (int i = 0; i < numbers.length; i++) {
    for (Board board in boards) {
      markNumberOnBoard(board, numbers[i]);
      if (isWinningBoard(board)) {
        print('Winning board: $board');
        print('Winning number: ${numbers[i]}');
        return calculateScore(numbers[i], board);
      }
    }
  }
}

void markNumberOnBoard(Board board, int number) {
  for (final row in board) {
    for (final square in row) {
      if (square.number == number) {
        square.isMarked = true;
      }
    }
  }
}

int calculateScore(int finalNumber, Board winningBoard) {
  final List<int> unMarkedNumbers = [];
  for (final row in winningBoard) {
    for (final square in row) {
      if (!square.isMarked) {
        unMarkedNumbers.add(square.number);
      }
    }
  }
  print('Sum: ${unMarkedNumbers.reduce((a, b) => a + b)}');

  return unMarkedNumbers.reduce((value, element) => value + element) * finalNumber;
}

/// Given a [Board], returns [true] if it is a winning board.
bool isWinningBoard(Board board) {
  bool isWinningBoard = false;

  // Check rows
  for (final row in board) {
    isWinningBoard = checkLine(row);
    if (isWinningBoard) {
      break;
    }
  }

  // No need to check columns if board has already won
  if (!isWinningBoard) {
    // Check columns
    for (int i = 0; i < board[0].length; i++) {
      final column = board.map((line) => line[i]).toList();
      isWinningBoard = checkLine(column);
      if (isWinningBoard) {
        break;
      }
    }
  }
  return isWinningBoard;
}

/// Helper function that checks if a line is a winning line and returns [true] if it is
bool checkLine(List<Square> line) {
  return line.every((square) => square.isMarked);
}

Numbers parseNumbers(String input) {
  return input.split(',').map((s) => int.parse(s)).toList();
}

List<Board> parseBoards(List<String> input, int boardSize) {
  // First remove any empty lines
  input.removeWhere((element) {
    return element == '' || element == '\n';
  });

  List<Board> result = [];

  for (int i = 0; i < input.length; i += boardSize) {
    result.add(input
        .sublist(i, i + boardSize)
        .map((line) => line.split(' '))
        .map((e) => e.map((e) => int.tryParse(e)).where((element) => element != null).toList())
        .map((e) => e.map((e) => Square(e!, false)).toList())
        .toList()
        .toList());
  }
  return result;
}
