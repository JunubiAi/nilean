import 'package:buai/ui/widgets/app_buttons.dart';
import 'package:buai/utils/colors.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class TranslateDisplay extends StatelessWidget {
  const TranslateDisplay({
    super.key,
    required this.displayText,
    required this.isLoading,
    required this.onLanguagePressed,
    required this.items,
    required this.activeItem,
  });

  final String displayText;
  final bool isLoading;
  final Function(String) onLanguagePressed;
  final List<String> items;
  final String activeItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryGrey,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 1.5, color: Colors.black),
      ),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            displayText,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 16),
          ),
          Row(
            children: [
              AppButtons.dropdownButton(
                onPressed: onLanguagePressed,
                context: context,
                items: items,
                activeItem: activeItem,
                color: AppColors.primaryBlue,
              ),
              const Spacer(),
              AppButtons.circularButton(
                onPressed: () {
                  FlutterClipboard.copy(displayText);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                context: context,
                color: AppColors.primaryYellow,
                icon: Icons.copy_sharp,
              ),
              const SizedBox(width: 2),
              AppButtons.circularButton(
                onPressed: () {},
                context: context,
                color: AppColors.primaryBlue,
                icon: Icons.volume_up,
              ),
              const SizedBox(width: 2),
              AppButtons.circularButton(
                onPressed: () {
                  Share.share(displayText);
                },
                context: context,
                color: AppColors.primaryGrey,
                icon: Icons.ios_share,
              ),
            ],
          )
        ],
      ),
    );
  }
}
