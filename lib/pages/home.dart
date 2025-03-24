// Flutter Imports
import 'package:flutter/material.dart';

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildFilebar(),
        buildFileContent()
      ],
    );
  }

  Widget buildFilebar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffC9C8C7),
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
      widgets.add(
        Flexible(
          fit: FlexFit.tight,
          child: Container(
            decoration: BoxDecoration(
              color: Color(hexcodeToDecimal(value['hex'], opacity: 1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    key.toUpperCase().replaceAll("#", ""),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDarkColor(value['hex']) ? Color(0xffF2F0EF) : Colors.black
                    ),
                  )
                ],
              )
            )
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