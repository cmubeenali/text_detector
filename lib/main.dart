import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Detector',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imagePath = "";
  late File myImagePath;
  String finalText = ' ';
  bool isLoaded = false; 

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 100,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width,
              color: Colors.teal,
              child: isLoaded
                  ? Image.file(
                      myImagePath,
                      fit: BoxFit.fill,
                    )
                  : Text("This is image section "),
            ),
            Row(
                children:[
                  TextButton(
                    onPressed: () {
                      getImage();

                      // Future.delayed(Duration(seconds: 5), () {
                      //   getText(imagePath);
                      // });
                    },
                    child: Text(
                      "Pick Image",                      
                    )
                  ),
                  TextButton(
                    onPressed: () {
                      Future.delayed(Duration(seconds: 5), () {
                        getText(imagePath);
                      });
                    },
                    child: Text(
                      "Load Text",                      
                    )
                  ),
                  TextButton(
                    onPressed: () {
                      Future.delayed(Duration(seconds: 5), () {
                        _cropImage();
                      });
                    },
                    child: Text(
                      "Crop Image",                      
                    )
                  ),
                ] 
                ),
            Text(
              finalText,
              style:TextStyle(color: Colors.white),
              
            ),
          ],
        ),
      ),
    );
  }
   Future getText(String path) async {
     finalText="";
    final inputImage = InputImage.fromFilePath(path);
    final textDetector = GoogleMlKit.vision.textDetector();
    final RecognisedText _reconizedText =
        await textDetector.processImage(inputImage);

    List<String> arr_texts=[];    
    for (TextBlock block in _reconizedText.blocks) {
      for (TextLine textLine in block.lines) {
        for (TextElement textElement in textLine.elements) {
          setState(() {
            finalText = finalText + " " + textElement.text;
          });
        }

        finalText = finalText + '\n';
        arr_texts.add(finalText);
        finalText="";
      }
    }
    bool is_found=false;
    for (var item in arr_texts) {
      if(is_found){
        setState(() {
          finalText=item;
          is_found=false;          
        });
        break;
      }
      if(item.toLowerCase().contains('reference id')||item.toLowerCase().contains('transaction id')||item.toLowerCase().contains('txn id')||item.toLowerCase().contains('UTR:')){
        is_found=true;
      }
    }
  }

  // this is for getting the image form the gallery
  void getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      myImagePath = File(image!.path);
      isLoaded = true;
      imagePath = image.path.toString();
    });
  }
  Future<Null> _cropImage() async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: myImagePath.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {      
      setState(() {
        myImagePath=croppedFile;
        imagePath = croppedFile.path;        
      });
    }
  }
}
