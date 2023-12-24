import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/colors.dart';
import 'package:spoto/core/constant/images.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/router/app_router.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/entities/user/user.dart';
import 'package:spoto/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/widgets/adaptive_alert_dialog.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<UserBloc>().state.props.first as UserModel;
  }

  Widget buildName(User user) => Column(
        children: [
          Text(
            "${user.firstName} ${user.lastName}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          EasyLoading.dismiss();
          if (state is UserLoading) {
            EasyLoading.show(status: loadingTitle, dismissOnTap: false);
          } else if (state is UserLogged) {
            setState(() {
              currentUser =
                  context.read<UserBloc>().state.props.first as UserModel;
            });
            EasyLoading.showSuccess("User details updated successfully.");
          } else if (state is UserUpdateFail) {
            EasyLoading.showError(
                "User update failed. Please try again later.");
          }
        },
        child: Scaffold(
            // appBar: AppBar(
            //   // title: const Text('Settings'),
            //   backgroundColor: Colors.white,
            //   surfaceTintColor: Colors.white,
            // ),
            backgroundColor: Colors.black.withOpacity(0.05),
            // body: SettingsList(
            //   contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            //   sections: [
            //     SettingsSection(
            //       title: const Text(
            //         'PROFILE',
            //         style: TextStyle(color: Colors.black, fontSize: 12),
            //       ),
            //       tiles: <SettingsTile>[
            //         SettingsTile.navigation(
            //           title: const Text('Name'),
            //         ),
            //         SettingsTile.navigation(
            //           title: const Text('Language'),
            //           value: const Text('English'),
            //         ),
            //         SettingsTile.switchTile(
            //           onToggle: (value) {},
            //           initialValue: false,
            //           title: const Text('Notifications'),
            //         ),
            //       ],
            //     ),
            //     SettingsSection(
            //       title: const Text(
            //         'APPEARANCE',
            //         style: TextStyle(color: Colors.black, fontSize: 12),
            //       ),
            //       tiles: <SettingsTile>[
            //         SettingsTile.switchTile(
            //           onToggle: (value) {},
            //           initialValue: true,
            //           title: const Text('Dark mode'),
            //         ),
            //       ],
            //     ),
            //     SettingsSection(
            //       title: const Text(
            //         'ACCOUNT',
            //         style: TextStyle(color: Colors.black, fontSize: 12),
            //       ),
            //       tiles: <SettingsTile>[
            //         SettingsTile.navigation(
            //           title: const Text('Delete account', style: TextStyle(color: Colors.red),),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            body: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
              child: ListView(
                children: [
                  const Text("Settings",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.black)),
                  const SizedBox(height: 10),
                  SmallUserCard(
                    cardColor: kLightPrimaryColor,
                    userName:
                        "${currentUser.firstName} ${currentUser.lastName}",
                    userProfilePic: (currentUser.image != null
                            ? NetworkImage(currentUser.image!)
                            : const AssetImage(kUserAvatar))
                        as ImageProvider<Object>,
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.userProfile,
                        arguments: currentUser,
                      );
                    },
                  ),
                  SettingsGroup(
                    iconItemSize: 25,
                    items: [
                      SettingsItem(
                        onTap: () {},
                        icons: Icons.dark_mode_rounded,
                        iconStyle: IconStyle(
                          iconsColor: Colors.black54,
                          withBackground: true,
                          backgroundColor: Colors.transparent,
                        ),
                        title: 'Dark mode',
                        // subtitle: "Automatic",
                        trailing: Switch.adaptive(
                          value: false,
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                  SettingsGroup(
                    items: [
                      SettingsItem(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AppRouter.myPublications);
                        },
                        icons: CupertinoIcons.square_list_fill,
                        iconStyle: IconStyle(
                          iconsColor: Colors.black54,
                          withBackground: true,
                          backgroundColor: Colors.transparent,
                        ),
                        title: 'Publications',
                      ),
                      SettingsItem(
                        onTap: () {},
                        icons: Icons.notifications_active_rounded,
                        iconStyle: IconStyle(
                          iconsColor: Colors.black54,
                          withBackground: true,
                          backgroundColor: Colors.transparent,
                        ),
                        title: 'Notifications',
                        trailing: Switch.adaptive(
                          value: false,
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),

                  SettingsGroup(
                    items: [
                      SettingsItem(
                        onTap: () {},
                        icons: CupertinoIcons.mail_solid,
                        iconStyle: IconStyle(
                          iconsColor: Colors.black54,
                          withBackground: true,
                          backgroundColor: Colors.transparent,
                        ),
                        title: 'Contact us',
                      ),
                      SettingsItem(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRouter.about);
                        },
                        icons: CupertinoIcons.info_circle_fill,
                        iconStyle: IconStyle(
                          iconsColor: Colors.black54,
                          withBackground: true,
                          backgroundColor: Colors.transparent,
                        ),
                        title: 'About',
                      ),
                    ],
                  ),
                  // You can add a settings title
                  SettingsGroup(
                    settingsGroupTitle: "Account",
                    items: [
                      SettingsItem(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SignOutConfirmationAlert(
                                onSignOut: () {
                                  context.read<UserBloc>().add(SignOutUser());
                                  context
                                      .read<FavoritesBloc>()
                                      .add(const ClearFavorites());
                                },
                              );
                            },
                          );
                        },
                        icons: Icons.exit_to_app_rounded,
                        title: "Sign Out",
                      ),
                      SettingsItem(
                        onTap: () {},
                        icons: CupertinoIcons.delete_solid,
                        iconStyle: IconStyle(
                          iconsColor: Colors.red,
                          withBackground: true,
                          backgroundColor: Colors.transparent,
                        ),
                        title: "Delete account",
                        titleStyle: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }
}
