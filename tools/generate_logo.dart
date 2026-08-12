import 'dart:io';
import 'package:image/image.dart';

void main() {
  const int size = 1024;
  final Image img = Image(size, size);
  // Transparent background
  fill(img, getColor(0, 0, 0, 0));

  // Block letter grid definitions (5 cols x 7 rows) for CHOWK
  final Map<String, List<List<int>>> letters = {
    'C': [
      [1,1,1,1,1],
      [1,0,0,0,0],
      [1,0,0,0,0],
      [1,0,0,0,0],
      [1,0,0,0,0],
      [1,0,0,0,0],
      [1,1,1,1,1],
    ],
    'H': [
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,1,1,1,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
    ],
    'O': [
      [1,1,1,1,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,1,1,1,1],
    ],
    'W': [
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
      [1,0,1,0,1],
      [1,1,0,1,1],
      [1,0,0,0,1],
      [1,0,0,0,1],
    ],
    'K': [
      [1,0,0,0,1],
      [1,0,0,1,0],
      [1,0,1,0,0],
      [1,1,0,0,0],
      [1,0,1,0,0],
      [1,0,0,1,0],
      [1,0,0,0,1],
    ],
  };

  // layout params
  final int colsPerLetter = 5;
  final int rowsPerLetter = 7;
  final double scale = 28; // size of one block
  final double letterWidth = colsPerLetter * scale;
  final double letterHeight = rowsPerLetter * scale;
  final double spacing = scale * 1.4; // space between letters

  final double totalWidth = (letterWidth * letters.length) + (spacing * (letters.length - 1));
  double startX = (size - totalWidth) / 2;
  final double startY = (size - letterHeight) / 2;

  final int black = getColor(0, 0, 0);

  for (final ch in ['C', 'H', 'O', 'W', 'K']) {
    final pattern = letters[ch]!;
    for (int r = 0; r < rowsPerLetter; r++) {
      for (int c = 0; c < colsPerLetter; c++) {
        if (pattern[r][c] == 1) {
          final int x = (startX + c * scale).toInt();
          final int y = (startY + r * scale).toInt();
          // draw filled rectangle slightly inset for crisp look
          fillRect(img, x, y, x + scale.toInt() - 1, y + scale.toInt() - 1, black);
        }
      }
    }
    startX += letterWidth + spacing;
  }

  // Save PNG
  final outFile = File('assets/images/chowk_launcher.png');
  outFile.createSync(recursive: true);
  outFile.writeAsBytesSync(encodePng(img));
  print('Generated assets/images/chowk_launcher.png');
}
