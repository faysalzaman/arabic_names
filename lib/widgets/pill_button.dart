import 'package:arabic_names/utils/constants.dart';
import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.imageAsset,
    required this.onPressed,
  });

  final String label;
  final String imageAsset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: Constants.buttonColor,
      shape: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: 170,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 30,
                width: 30,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(imageAsset),
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Constants.textOnButtonColor,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
