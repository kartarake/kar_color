import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

Future<Map<String, Map<String, dynamic>>> parseAseFile(String path) async {
  final file = File(path);
  final Uint8List data = await file.readAsBytes();

  Map<String, Map<String, dynamic>> colors = {};
  ByteData byteData = ByteData.sublistView(data);
  int index = 0;

  // ASE Header:
  // 4 bytes signature ("ASEF"), 4 bytes version (2xuint16), 4 bytes block count
  // Total: 12 bytes
  String signature = ascii.decode(data.sublist(index, index + 4));
  index += 4;
  if (signature != "ASEF") {
    throw Exception("Not a valid ASE file");
  }
  
  // Read version (4 bytes)
  // int versionMajor = byteData.getUint16(index, Endian.big);
  // int versionMinor = byteData.getUint16(index + 2, Endian.big);
  index += 4;
  
  // Read number of blocks (4 bytes)
  // int totalBlocks = byteData.getUint32(index, Endian.big);
  index += 4;
  
  // Iterate over blocks
  while (index < data.length) {
    try {
      // Block Type (2 bytes, 0x0001 = Color Entry)
      // int blockType = byteData.getUint16(index, Endian.big);
      index += 2;
      
      // Block Length (4 bytes)
      int blockLength = byteData.getUint32(index, Endian.big);
      index += 4;
      
      // Read Color Name Length (2 bytes)
      int nameLength = byteData.getUint16(index, Endian.big);
      index += 2;
      
      // Read Color Name (UTF-16 BE)
      Uint8List nameBytes = data.sublist(index, index + nameLength * 2);
      String colorName = decodeUtf16(nameBytes);
      index += nameLength * 2;
      
      // Read Color Mode (4 bytes, e.g., "RGB ")
      String colorMode = ascii.decode(data.sublist(index, index + 4));
      index += 4;
      
      if (colorMode.trim() == "RGB") {
        // Read 3 float values for RGB (Big-Endian)
        double r = byteData.getFloat32(index, Endian.big);
        double g = byteData.getFloat32(index + 4, Endian.big);
        double b = byteData.getFloat32(index + 8, Endian.big);
        index += 12;
        
        // Skip Color Type (2 bytes)
        index += 2;
        
        colors[colorName] = {
          "mode": "RGB",
          "value": {"r": r, "g": g, "b": b},
          "hex": rgbToHex(r, g, b),
        };
      } else {
        // Skip this block if color mode is not supported.
        index += blockLength - (6 + nameLength * 2 + 4);
      }
    } catch (e) {
      throw "Error parsing ASE file: $e";
    }
  }
  
  return colors;
}

// Custom UTF-16 BE decoder
String decodeUtf16(Uint8List bytes) {
  List<int> codeUnits = [];
  for (int i = 0; i < bytes.length; i += 2) {
    int unit = (bytes[i] << 8) | bytes[i + 1];
    codeUnits.add(unit);
  }
  return String.fromCharCodes(codeUnits).replaceAll("\x00", "");
}

// Convert RGB float (0.0–1.0) to hex code
String rgbToHex(double r, double g, double b) {
  int red = (r * 255).toInt();
  int green = (g * 255).toInt();
  int blue = (b * 255).toInt();
  return "#${red.toRadixString(16).padLeft(2, '0')}"
         "${green.toRadixString(16).padLeft(2, '0')}"
         "${blue.toRadixString(16).padLeft(2, '0')}";
}

// Example usage:
// void main() async {
//   String filePath = r"C:\Users\karpr\Downloads\Cyan Ocean.ase"; // Replace with your ASE file path
//   Map<String, Map<String, dynamic>> colors = await parseAseFile(filePath);
// 
//   colors.forEach((name, details) {
//     print("Color: $name, Mode: ${details['mode']}, "
//           "RGB: ${details['value']}, Hex: ${details['hex']}");
//   });
// }

int hexcodeToDecimal(String hex, {double opacity = 1}) {
  hex = hex.replaceAll("#", "");
  String opacityString = (opacity*255).toInt().toRadixString(16);
  hex = "$opacityString$hex";
  return int.parse(hex, radix: 16);
}

bool isDarkColor(String hexcode) {
  hexcode = hexcode.replaceAll("#", "");
  int r = int.parse(hexcode.substring(0, 2), radix: 16);
  int g = int.parse(hexcode.substring(2, 4), radix: 16);
  int b = int.parse(hexcode.substring(4, 6), radix: 16);
  return (r * 0.299 + g * 0.587 + b * 0.114) < 128;
}