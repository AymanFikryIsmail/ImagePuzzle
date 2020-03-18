import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:puzzle_app/custom_widgets/custom_dialog.dart';
import 'package:puzzle_app/ui/puzzlebloc.dart';
import 'package:collection/collection.dart';

class MyPuzzleScreen extends StatefulWidget {
  MyPuzzleScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyPuzzleScreenState createState() => _MyPuzzleScreenState();
}

class _MyPuzzleScreenState extends State<MyPuzzleScreen>
    with TickerProviderStateMixin {
  List<int> originalImageListData = new List(4);

  List<int> changedImageListData = new List(4);
  List<Image> ImageListData = new List(4);
  PuzzleBloc bloc = new PuzzleBloc();

  @override
  void initState() {
    super.initState();
    bloc.getImage();
  }

  Widget buildGrid(int index, Image image) {
    final fromChange = ImageListData[index];
    Card card = Card(
      key: ValueKey(index),
      child: new Container(
        decoration: new BoxDecoration(
            image: new DecorationImage(
                alignment: FractionalOffset.topCenter,
                image: fromChange.image,
                fit: BoxFit.fill)),
      ),
    );
    Draggable dragGridCard = LongPressDraggable(
      data: fromChange,
      maxSimultaneousDrags: 1,
      child: card,
      childWhenDragging: Opacity(
        opacity: 0.2,
        child: card,
      ),
      feedback: Material(
        color: Colors.black.withOpacity(0.2),
        child: card,
        elevation: 4.0,
      ),
    );

    return DragTarget(
      onWillAccept: (fromChange) {
        return ImageListData.indexOf(fromChange) != index;
      },
      onAccept: (fromChange) {
        int changeFromIndex = ImageListData.indexOf(fromChange);

        ImageListData[index] = fromChange;
        ImageListData[changeFromIndex] = ImageListData[index];
        bloc.moveImage(ImageListData);

        var changerdListChangeToValue = changedImageListData[index];
        changedImageListData[index] = changedImageListData[changeFromIndex];
        changedImageListData[changeFromIndex] = changerdListChangeToValue;

        bool isEqual =
            bloc.checkForEquality(changedImageListData, originalImageListData);
        if (isEqual) {
          showCustomDialog();
        }
        print('index after   $fromChange $ImageListData]');
      },
      builder:
          (BuildContext context, selectedData, List<dynamic> rejectedData) {
        return Container(
          // color: Colors.orange,
          child: selectedData.isEmpty ? dragGridCard : card,
        );
      },
    );
  }

  showCustomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "Success",
        description: "Congratulation , you solved it ",
        buttonText: "Okay",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: StreamBuilder<List<Image>>(
                stream: bloc.selectImageResponse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    ImageListData = snapshot.data;
                    if (originalImageListData[0] == null) {
                      originalImageListData = bloc.getImageList();
                      changedImageListData = bloc.getShuffledImageList();
                    }
                    return new GridView.builder(
                        itemCount: 4,
                        gridDelegate:
                            new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return buildGrid(index, snapshot.data[index]);
                        });
                  } else {
                    return Text("loading");
                  }
                })));
  }
}
