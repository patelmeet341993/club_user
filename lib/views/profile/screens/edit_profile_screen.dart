import 'dart:io';
import 'dart:math';

import 'package:club_model/backend/user/user_controller.dart';
import 'package:club_model/club_model.dart';
import 'package:club_user/backend/navigation/navigation_arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = "/EditProfileScreen";

  final EditProfileScreenNavigationArguments arguments;

  const EditProfileScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with MySafeState {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uint8List? profileImageBytes;
  String? profileImageUrl;
  List<String> filesToDelete = [];

  String userId = "";
  TextEditingController nameController = TextEditingController();

  Future getBussinessImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty && (result.files.first.path?.isNotEmpty ?? false)) {
      PlatformFile platformFile = result.files.first;

      //Calculating Size Of File in MB
      int bytes = File(platformFile.path ?? "").lengthSync();
      double length = bytes / pow(1024, 2);
      MyPrint.printOnConsole("Length:$length");

      if (length <= 5) {
        int quality = 100;

        if (length >= 2.5) {
          quality = 10;
        } else if (length >= 2) {
          quality = 20;
        } else if (length >= 1) {
          quality = 25;
        } else if (length >= 0.5) {
          quality = 50;
        } else if (length >= 0.3) {
          quality = 70;
        }

        CroppedFile? newImage = await ImageCropper().cropImage(
          compressFormat: ImageCompressFormat.png,
          sourcePath: platformFile.path!,
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: themeData.colorScheme.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              aspectRatioLockEnabled: false,
            ),
          ],
        );

        if (newImage == null) {
          MyPrint.printOnConsole("image file null");
        } else {
          MyPrint.printOnConsole("image file not null");
          MyPrint.printOnConsole("Cropped Image Path:${newImage.path}");

          try {
            Directory directory = await getTemporaryDirectory();

            String newPath = "${directory.path}/image_compressor_${DateTime.now().millisecondsSinceEpoch}.png";
            MyPrint.printOnConsole('New Path:$newPath');

            XFile? result = await FlutterImageCompress.compressAndGetFile(
              newImage.path,
              newPath,
              quality: quality,
              format: CompressFormat.png,
            );
            MyPrint.printOnConsole("FlutterImageCompress path:${result?.path}");

            if (result != null) {
              Uint8List bytes = await result.readAsBytes();
              double length = bytes.lengthInBytes / pow(1024, 2);
              MyPrint.printOnConsole("New Image Length:$length");
              MyPrint.printOnConsole("New Image Path:${result.path}");
              profileImageBytes = bytes;
              mySetState();
            }
          } catch (e, s) {
            MyPrint.printOnConsole("Error in Getting Image:$e");
            MyPrint.printOnConsole(s);
          }
        }
      } else {
        if (context.checkMounted() && context.mounted) {
          MyToast.showError(context: context, msg: "Image Size Should not be greater than 5 MB");
        }
      }
    }
  }

  Future<List<String>> uploadImages({required String bussinessId, required List<Uint8List> images}) async {
    List<String> downloadUrls = [];

    String tempUserId = userId;

    if (tempUserId.isEmpty) {
      tempUserId = "user";
    }

    await Future.wait(
      images.map((Uint8List bytes) async {
        // String fileName = file.path.substring(file.path.lastIndexOf("/") + 1);
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        Reference reference = FirebaseStorage.instance.ref().child("profile").child(tempUserId).child(bussinessId).child(fileName);
        UploadTask uploadTask = reference.putData(bytes);

        TaskSnapshot snapshot = await uploadTask.then((snapshot) => snapshot);
        if (snapshot.state == TaskState.success) {
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);

          /*final String downloadUrl = "https://storage.googleapis.com/${Firebase.app().options.storageBucket}/profile/$tempUserId/$bussinessId/$fileName";
          downloadUrls.add(downloadUrl);*/

          MyPrint.printOnConsole('$fileName Upload success');
        } else {
          MyPrint.printOnConsole('Error from image repo uploading $fileName: ${snapshot.toString()}');
          //throw ('This file is not an image');
        }
      }),
      eagerError: true,
      cleanUp: (_) {
        MyPrint.printOnConsole('eager cleaned up');
      },
    );

    return downloadUrls;
  }

  void editBussiness() async {
    isLoading = true;
    mySetState();

    String imageUrl;

    MyPrint.printOnConsole("filesToDelete:$filesToDelete");
    if (filesToDelete.isNotEmpty) {
      await DataController.deleteImages(images: filesToDelete);
    }

    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      imageUrl = profileImageUrl!;
    } else {
      if (profileImageBytes != null) {
        List<String> images = await uploadImages(bussinessId: userId, images: [profileImageBytes!]);
        imageUrl = images.isNotEmpty ? images.first : "";
        // imageUrl = await CloudinaryManager().uploadBussinessImage(bussinessId: model.id, image: bussinessImageFile!);
      } else {
        imageUrl = "";
      }
    }

    ProfileUpdateRequestModel requestModel = ProfileUpdateRequestModel(
      id: userId,
      name: nameController.text.trim(),
      imageUrl: imageUrl,
    );

    bool isAdded = await UserController().updateProfileDetails(requestModel: requestModel);
    MyPrint.printOnConsole("IsAdded:$isAdded");

    isLoading = false;
    mySetState();

    if (isAdded) {
      UserModel userModel = widget.arguments.userModel;
      if (requestModel.name != null) {
        userModel.name = requestModel.name!;
      }
      if (requestModel.imageUrl != null) {
        userModel.imageUrl = requestModel.imageUrl!;
      }
      if (requestModel.updatedTime != null) {
        userModel.updatedTime = requestModel.updatedTime!;
      }

      // AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.business_event, parameters: {AnalyticsParameters.event_value : "Edited"});
      if (context.checkMounted() && context.mounted) Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    UserModel userModel = widget.arguments.userModel;

    userId = userModel.id;
    nameController.text = userModel.name;
    profileImageUrl = userModel.imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return WillPopScope(
      onWillPop: () async {
        // return true;
        return !isLoading;
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Edit Profile"),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    getImageWidget(),
                    getNameTextField(),
                    getEditBussinessButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getImageWidget() {
    if (profileImageBytes == null && (profileImageUrl == null || profileImageUrl!.isEmpty)) {
      return Column(
        children: [
          InkWell(
            onTap: () {
              getBussinessImage();
            },
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: themeData.colorScheme.onBackground),
              ),
              child: const Icon(
                Icons.cloud_upload,
                size: 40,
              ),
            ),
          ),
          Text(
            "Add Your Profile Pic",
            style: themeData.textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    } else {
      if (profileImageBytes != null) {
        return Container(
          width: 100,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: ClipRRect(
                  //borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: Image.memory(profileImageBytes!),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    profileImageBytes = null;
                    mySetState();
                  },
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeData.colorScheme.primary,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          width: 100,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: ClipRRect(
                  //borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: profileImageUrl!,
                    placeholder: (context, url) => SpinKitCircle(
                      color: themeData.colorScheme.primary,
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    filesToDelete.add(profileImageUrl!);
                    profileImageUrl = null;
                    mySetState();
                  },
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeData.colorScheme.primary,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget getNameTextField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: TextFormField(
        controller: nameController,
        validator: (val) {
          if (val?.isEmpty ?? true) {
            return "Name Cannot be empty";
          } else {
            return null;
          }
        },
        decoration: const InputDecoration(
          hintText: "Name",
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
      ),
    );
  }

  Widget getEditBussinessButton() {
    return InkWell(
      onTap: () {
        if (_formKey.currentState?.validate() ?? false) {
          //MyPrint.printOnConsole("Valid");
          editBussiness();
        } else {
          //MyPrint.printOnConsole("Not Valid");
          /*if(!((bussinessImageUrl != null && bussinessImageUrl.isNotEmpty) || bussinessImageFile != null)) {
            MyToast.showError("Select Bussiness Image", context);
          }*/
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: themeData.colorScheme.primary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          "Edit",
          style: themeData.textTheme.bodyLarge?.copyWith(
            color: themeData.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
