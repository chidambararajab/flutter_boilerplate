import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_deer/res/resources.dart';
import 'package:flutter_deer/util/device_utils.dart';
import 'package:flutter_deer/util/image_utils.dart';
import 'package:flutter_deer/util/theme_utils.dart';
import 'package:flutter_deer/util/toast_utils.dart';
import 'package:image_picker/image_picker.dart';

class SelectedImage extends StatefulWidget {
  const SelectedImage({
    super.key,
    this.url,
    this.heroTag,
    this.size = 80.0,
  });

  final String? url;
  final String? heroTag;
  final double size;

  @override
  SelectedImageState createState() => SelectedImageState();
}

class SelectedImageState extends State<SelectedImage> {
  final ImagePicker _picker = ImagePicker();
  ImageProvider? _imageProvider;
  XFile? pickedFile;

  Future<void> _getImage() async {
    try {
      pickedFile =
          await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
      if (pickedFile != null) {
        if (Device.isWeb) {
          _imageProvider = NetworkImage(pickedFile!.path);
        } else {
          _imageProvider = FileImage(File(pickedFile!.path));
        }
      } else {
        _imageProvider = null;
      }
      setState(() {});
    } catch (e) {
      if (e is MissingPluginException) {
        Toast.show('The current platform does not support it! ');
      } else {
        Toast.show('Unable to open the album without permission! ');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorFilter colorFilter = ColorFilter.mode(
        ThemeUtils.isDark(context)
            ? Colours.dark_unselected_item_color
            : Colours.text_gray,
        BlendMode.srcIn);

    Widget image = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        // Picture fillet display
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
            image: _imageProvider ??
                ImageUtils.getImageProvider(widget.url,
                    holderImg: 'store/icon_zj'),
            fit: BoxFit.cover,
            colorFilter: _imageProvider == null && TextUtil.isEmpty(widget.url)
                ? colorFilter
                : null),
      ),
    );

    if (widget.heroTag != null && !Device.isWeb) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return Semantics(
      label: 'Select Image',
      hint: 'Jump to the album to select a picture',
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: _getImage,
        child: image,
      ),
    );
  }
}
