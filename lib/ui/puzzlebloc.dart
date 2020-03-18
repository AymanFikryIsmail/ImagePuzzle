import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image/image.dart' as imglib;
import 'package:collection/collection.dart';

class PuzzleBloc {
  final BehaviorSubject _imageListController = BehaviorSubject<List<Image>>();

  Observable<List<Image>> get selectImageResponse =>
      _imageListController.stream;

  getImage() async {
    try {
      // Saved with this method.
      var imageId = await ImageDownloader.downloadImage(
          "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.png");
      if (imageId == null) {
        return;
      }
      var path = await ImageDownloader.findPath(imageId);
      File file = File(path);
      splitImage(file);
    } on PlatformException catch (error) {
      print(error);
    }
  }

  bool checkForEquality(List<int> originalImageListData , List<int> changedImageListData)  {
    Function eq = const ListEquality().equals;
    bool isEqual = eq(changedImageListData, originalImageListData);
    print(isEqual);
    return isEqual;
  }
  moveImage(List<Image> imageList)  {
    _imageListController.sink.add(imageList);

  }

  List<Image> imageList = new List(4);
  List<Image> shuffledImageList = new List(4);

  List<int> getImageList() {
    List<int> list = imageList.map((image) {
      return image.hashCode;
    }).toList();
    return list;
  }

  List<int> getShuffledImageList() {
    List<int> list = shuffledImageList.map((image) {
      return image.hashCode;
    }).toList();
    return list;
  }

  splitImage(File file) {
    // convert image to image from image package
//    imglib.Image image1 = imglib.decodeImage(input);
    List<int> input = file.readAsBytesSync();
    print(imglib.decodeImage(input));
    imglib.Image image = imglib.decodeImage(input);

    int x = 0, y = 0;
    int width = (image.width / 2).round();
    int height = (image.height / 2).round();

    // split image to parts
    List<imglib.Image> parts = List<imglib.Image>();
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }

    // convert image from image package to Image Widget to display
    List<Image> output = List<Image>();
    for (var img in parts) {
      output.add(Image.memory(imglib.encodeJpg(img)));
    }
    imageList = output;
    shuffledImageList = output.toList()..shuffle();
    _imageListController.sink.add(shuffledImageList);
  }
}
