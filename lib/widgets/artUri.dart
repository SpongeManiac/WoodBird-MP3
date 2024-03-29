import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ArtUri extends StatefulWidget {
  ArtUri(this.uri, {super.key, this.maxSize, this.padding, this.opacity});

  Uri uri;
  double? padding;
  double? maxSize;
  double? opacity;

  @override
  State<StatefulWidget> createState() => _ArtUriState();
}

class _ArtUriState extends State<ArtUri> {
  _ArtUriState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  List<String> VALID_IMAGE_TYPES = [
    'png',
    'jpg',
    'jpeg',
  ];

  //timer for making requests
  late Timer timer;
  Completer<bool> completer = Completer<bool>();
  Uri currentSearch = Uri.parse('');
  bool currentSearchValid = false;

  bool isWebImg(String path) {
    var containsHttp = path.contains('http://');
    var containsHttps = path.contains('https://');
    var containsFile = path.contains('file://');
    //print('path is http: $containsHttp');
    //print('path is https: $containsHttps');
    //print('path is file: $containsHttps');
    return containsHttp || containsHttps;
  }

  Future<bool> validate_image(Uri image) async {
    String imgPath = image.toString();
    //print('validating image: $imgPath');
    if (imgPath.isEmpty) {
      //no url
      //print('No image to check.');
      return false;
    }

    //print('validating image: ${image}');
    bool valid = false;
    if (isWebImg(imgPath)) {
      // Encapsulate in try/catch to prevent serverside errors
      //print('web image');
      completer = Completer<bool>();
      if (currentSearchValid) {
        return true;
      }
      currentSearch = image;
      timer = Timer(
        const Duration(milliseconds: 50),
        () async {
          //print('starting timer');
          if (!completer.isCompleted) {
            completer.complete(imageRequest(currentSearch));
            //print('finished imageRequest');
          }
        },
      );
      try {
        valid = await completer.future;
        //completer.complete(imageRequest(currentSearch));
        //print('finished imageRequest');
      } catch (e) {
        //print('something went wrong, image invalidated');
      }
    } else {
      //print('local image');
      try {
        File img = File.fromUri(image);
        if (await img.exists()) {
          valid = true;
        } else {
          //print('Image does not exist at: ${img.toString()}');
        }
      } catch (e) {
        //print('something went wrong, image invalidated');
      }
    }

    ///print('image was valid: $valid');
    currentSearchValid = valid;
    return valid;
  }

  Future<bool> imageRequest(Uri image) async {
    print('making head request to: ${image.toString()}');
    // Send a 'HEAD' request to the given url. It will follow redirects
    // until it reaches the specified max redirects
    var response = await http.head(image);
    // Check if the last response was 'OK' (200)
    if (response.statusCode == 200) {
      // Get the content type (Mime-Type) of the response
      String type = response.headers['content-type'] ?? '';
      // Split the content type at the slash
      var splitText = type.split('/');
      // Check if the content type is an image
      if (splitText[0] == 'image') {
        // Check if the image type is in 'VALID_IMAGE_TYPES'
        if (VALID_IMAGE_TYPES.contains(splitText[1])) {
          //image is valid
          print('image is valid');
          return true;
        } else {
          print('invalid content encoding');
        }
      } else {
        print('invalid content type');
        // Content type was not an image, add an error
        //self.add_error('image', ValidationError(_('URL is not an image. Expected \'image/(png, jpg, jpeg)\', got \''+type+'\' instead.')))
      }
    } else {
      print('response was not \'200\' (OK)');
      // Response was not 'OK', add an error
      //self.add_error('image', ValidationError(_('URL is not valid.')))
    }
    return false;
  }

  Widget getDefaultArt() {
    if (widget.maxSize != null) {
      return Opacity(
        opacity: widget.opacity ?? 1,
        child: SizedBox(
          height: widget.maxSize,
          width: widget.maxSize,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              Icons.music_note_rounded,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    } else {
      return Opacity(
        opacity: widget.opacity ?? 1,
        child: Container(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              Icons.music_note_rounded,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
    }
  }

  Widget getLoading() {
    return const FittedBox(
      fit: BoxFit.contain,
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var noArt = getDefaultArt();
    var loading = getLoading();
    return Padding(
      padding: EdgeInsets.all(widget.padding ?? 0),
      child: FutureBuilder<bool>(
        future: validate_image(widget.uri),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              //print('No future to await');
              return noArt;
            case ConnectionState.waiting:
              return loading;
            case ConnectionState.active:
              return loading;
            case ConnectionState.done:
              //print('future has finished');
              if (snapshot.data!) {
                String path = widget.uri.toString();
                if (isWebImg(path)) {
                  //print('is web img');
                  return SizedBox(
                    height: widget.maxSize,
                    width: widget.maxSize,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Opacity(
                        opacity: widget.opacity ?? 1,
                        child: Image.network(path),
                      ),
                    ),
                  );
                } else {
                  //print('is file img');
                  return SizedBox(
                    //color: Colors.red,
                    height: widget.maxSize,
                    width: widget.maxSize,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Opacity(
                        opacity: widget.opacity ?? 1,
                        child: Image.file(
                          File.fromUri(widget.uri),
                        ),
                      ),
                    ),
                  );
                }
              } else {
                return noArt;
              }
            default:
              return noArt;
          }
        },
      ),
    );
  }
}
