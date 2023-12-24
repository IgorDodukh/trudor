import 'package:flutter/material.dart';
import 'package:spoto/core/constant/colors.dart';
import 'package:spoto/core/constant/images.dart';

class ProfileWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Colors.black87;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = imagePath != null
        ? NetworkImage(imagePath!)
        : const AssetImage(kUserAvatar);

    return ClipOval(
      child: Material(
        shadowColor: kLightPrimaryColor,
        color: Colors.transparent,
        child: Ink.image(
          image: image as ImageProvider<Object>,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          // child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 1,
        child: buildCircle(
          color: color,
          all: 0,
          child: IconButton(
              onPressed: onClicked,
              icon: Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              )),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          width: 40,
          height: 40,
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
