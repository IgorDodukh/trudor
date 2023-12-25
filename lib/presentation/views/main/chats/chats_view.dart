import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/images.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';

class ChatsView extends StatefulWidget {
  const ChatsView({Key? key}) : super(key: key);

  @override
  _ChatsViewState createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          EasyLoading.dismiss();
          if (state is UserLoading) {
            EasyLoading.show(status: loadingTitle, dismissOnTap: false);
          } else if (state is UserLogged) {
            EasyLoading.showSuccess("User details updated successfully.");
          } else if (state is UserUpdateFail) {
            EasyLoading.showError(
                "User update failed. Please try again later.");
          }
        },
        child: Scaffold(
            // backgroundColor: Colors.black.withOpacity(0.05),
            body: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
          child: ListView(
            children: [
              const Text(chatsTitle,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.black)),
              const SizedBox(height: 10),
              const SizedBox(height: 120),
              Image.asset(noChatsAsset),
              const Center(
                child: Text(noChatsYetTitle,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
              )
            ],
          ),
        )));
  }
}
