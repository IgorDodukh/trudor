import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:spoto/core/constant/messages.dart';
import 'package:spoto/core/util/image_uploader.dart';
import 'package:spoto/data/models/user/user_model.dart';
import 'package:spoto/domain/usecases/user/update_user_details_usecase.dart';
import 'package:spoto/presentation/blocs/user/user_bloc.dart';
import 'package:spoto/presentation/widgets/buttons/back_button.dart';
import 'package:spoto/presentation/widgets/buttons/next_button.dart';
import 'package:spoto/presentation/widgets/profile/profile_widget.dart';

import '../../../../../domain/entities/user/user.dart' as auser;
import '../../../../widgets/input_text_form_field.dart';

class UserProfileScreen extends StatefulWidget {
  final auser.User user;

  const UserProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();

  double formDividerHeight = 20;
  final _formKey = GlobalKey<FormState>();
  String? userImage;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.user.firstName;
    lastNameController.text = widget.user.lastName;
    email.text = widget.user.email;
    phoneNumber.text = widget.user.phoneNumber ?? "";
    userImage = widget.user.image;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              EasyLoading.dismiss();
              if (state is UserLoading) {
                EasyLoading.show(status: loadingTitle, dismissOnTap: false);
              } else if (state is UserLogged) {
                final currentUser =
                    context.read<UserBloc>().state.props.first as UserModel;
                setState(() {
                  userImage = currentUser.image;
                });
                EasyLoading.showSuccess("User details updated successfully.");
              } else if (state is UserUpdateFail) {
                EasyLoading.showError(
                    "User update failed. Please try again later.");
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  surfaceTintColor: Colors.white,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  title: const Text('Profile'),
                ),
                body: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 40),
                  child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          Hero(
                            tag: "C001",
                            child: ProfileWidget(
                              imagePath: userImage,
                              onClicked: () {
                                ImageUploader.pickAndUploadImage()
                                    .then((value) {
                                  context
                                      .read<UserBloc>()
                                      .add(UpdateUserPicture(value));
                                });
                              },
                            ),

                            // child: CircleAvatar(
                            //   radius: 75.0,
                            //   backgroundColor: Colors.grey.shade200,
                            //   child: Image.asset(kUserAvatar),
                            // ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          InputTextFormField(
                            controller: firstNameController,
                            hint: firstNameHint,
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: formDividerHeight),
                          InputTextFormField(
                            controller: lastNameController,
                            hint: lastNameHint,
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: formDividerHeight),
                          InputTextFormField(
                            textInputType: TextInputType.phone,
                            controller: phoneNumber,
                            hint: phoneNumberHint,
                            maxCharacters: 9,
                            // validation: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please enter your phone number';
                            //   }
                            //   return null;
                            // },
                          ),
                          // SizedBox(height: formDividerHeight),
                          // InputTextFormField(
                          //   enable: false,
                          //   contentPadding:
                          //       const EdgeInsets.symmetric(horizontal: 12),
                          //   textInputType: TextInputType.emailAddress,
                          //   controller: email,
                          //   hint: 'Email Address',
                          //   maxCharacters: 256,
                          //   validation: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return 'Please enter your email address';
                          //     } else if (!EmailValidator.validate(value)) {
                          //       return invalidEmail;
                          //     }
                          //     return null;
                          //   },
                          // ),
                        ],
                      )),
                ),
                bottomNavigationBar: SizedBox(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          CustomNextButton(
                            buttonTitle: updateTitle,
                            onPressedAction: () async {
                              Navigator.of(context).pop();
                              if (_formKey.currentState!.validate()) {
                                context
                                    .read<UserBloc>()
                                    .add(UpdateUserDetails(UserDetailsParams(
                                      firstName: firstNameController.text,
                                      lastName: lastNameController.text,
                                      email: email.text,
                                      phoneNumber: phoneNumber.text,
                                    )));
                              }
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          CustomBackButton(
                            onPressedAction: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    )))));
  }
}
