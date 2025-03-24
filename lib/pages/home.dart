// Flutter Imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dart Imports
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Local Imports
import 'package:kar_color/helpers/ase_parser.dart';

// Home Page Class
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? selectedFile;
  String currentlyHoveringColor = "";
  Map<String, Map<String, dynamic>> colors = {};

  Widget buildOpenFileButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: IconButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          colors = await parseAseFile(result!.files.single.path!);
          setState(() {
              selectedFile = File(result.files.single.path!);
            }
          );
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            )
          )
        ),
        icon: Icon(Icons.folder_open_outlined)
      ),
    );
  }

  Widget buildEditor() {
    return Column(
      children: [
        Divider(endIndent: 0,indent: 0,thickness: 1,height: 1,),
        buildFilebar(),
        Divider(endIndent: 0,indent: 0,thickness: 1,height: 1,),
        Expanded(child: buildFileContent())
      ],
    );
  }

  Widget buildFilebar() {
    return Container(
      decoration: BoxDecoration(
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Text(
              selectedFile!.path.split(Platform.pathSeparator).last,
              style: TextStyle(
                color: Color(0xff949392),
                fontWeight: FontWeight.bold
              ),
            )
          ]
        ),
      ),
    );
  }

  Widget buildFileContent() {
    List<Widget> widgets = [];
    colors.forEach((key, value) {
      List<Widget> colorTileContent = [
        Spacer(),
        Text(
          key.toUpperCase().replaceAll("#", ""),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDarkColor(value['hex']) ? Color(0xffF2F0EF) : Colors.black
          ),
        )
      ];
      widgets.add(
        Flexible(
          fit: FlexFit.tight,
          child: InkWell(
            onDoubleTap: () => setState(() {
              Clipboard.setData(ClipboardData(text: key.toUpperCase()));
            }),
            onHover: (isHovered) => setState(() {
              currentlyHoveringColor = isHovered? key:"";
            }),
            child: AnimatedScale(
              alignment: Alignment.bottomCenter,
              duration: Duration(milliseconds: 200),
              scale: currentlyHoveringColor == key ? 1.1 : 1,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Color(hexcodeToDecimal(value['hex'], opacity: 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 80),
                  child: Column(
                    children: colorTileContent,
                  )
                )
              ),
            ),
          ),
        )
      );
    },);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('karCOLOR'),
        backgroundColor: Color(0xffF2F0EF),
        actions: [
          buildOpenFileButton()
        ],
      ),
      body: selectedFile == null ? Container() : buildEditor()
    );
  }
}