import 'dart:io';
import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model/user_model.dart';
import '../provider/auth_provider.dart';
import '../utils/utils.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_button.dart';

class UserInfromationScreen extends StatefulWidget {
  String phonenumber;
  UserInfromationScreen({super.key,required this.phonenumber});

  @override
  State<UserInfromationScreen> createState() => _UserInfromationScreenState();
}

class _UserInfromationScreenState extends State<UserInfromationScreen> {
  File? image;
  TextEditingController phoneController = TextEditingController();
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  TextEditingController dateinput = TextEditingController();


  @override
  void initState() {
    dateinput.text = ""; //set the initial value of text field
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
  }

  // for selecting image
  void selectImage() async {
    image = await pickImage(context);
    setState(() {});
  }
  Country selectedCountry = Country(
    phoneCode: "84",
    countryCode: "VN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Vietnam",
    example: "Vietnam",
    displayName: "Vietnam",
    displayNameNoCountryCode: "VN",
    e164Key: "",
  );


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/image/background.png'),
                fit: BoxFit.cover),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            body: SafeArea(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text('Nhập thông tin',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 22),),
                      ),
                      InkWell(
                        onTap: () => selectImage(),
                        child: image == null
                            ? const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 50,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 30,
                            color: Colors.black,
                          ),
                        )
                            : CircleAvatar(
                          backgroundImage: FileImage(image!),
                          radius: 50,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            // name field
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: TextFormField(
                                cursorColor: Colors.black,
                                controller: nameController,
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.purple,
                                    ),
                                    child: Icon(
                                      Icons.account_circle,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  hintText: 'Tên của bạn',
                                  alignLabelWithHint: true,
                                  border: InputBorder.none,
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                              ),
                            ),
                            // email
                            // bio
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: TextFormField(
                                readOnly: true,
                                controller: dateinput,
                                cursorColor: Colors.black,
                                onTap: () async{
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context, initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      lastDate: DateTime.now()
                                  );
                                  if(pickedDate != null ){
                                    print(pickedDate);
                                    String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                    print(formattedDate);

                                    setState(() {
                                      dateinput.text = formattedDate; //set output date to TextField value.
                                    });
                                  }else{
                                    print("Date is not selected");
                                  }
                                },
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.purple,
                                    ),
                                    child: Icon(
                                      Icons.calendar_month,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  hintText: '**-**-****',
                                  alignLabelWithHint: true,
                                  border: InputBorder.none,
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: TextFormField(
                                cursorColor: Colors.black,
                                controller: bioController,
                                decoration: InputDecoration(
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.purple,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  hintText: 'Sở trường của bạn',
                                  alignLabelWithHint: true,
                                  border: InputBorder.none,
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: CustomButton(
                          text: "Continue",
                          onPressed: () => storeData(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget textFeld({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Colors.white,
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.purple,
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
  // store user data to database
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      birthday: dateinput.text,
      profilePic: "",
      createdAt: "",
      phoneNumber: widget.phonenumber,
      uid: "",
      status: " "
    );
    if (image != null) {
      ap.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        profilePic: image!,
        onSuccess: () {
          ap.saveUserDataToSP().then(
                (value) => ap.setSignIn().then(
                      (value) => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyHomePage(),
                      ),
                          (route) => false),
                ),
              );
        },
      );
    } else {
      showSnackBar(context, "Hãy chọn ảnh đại diện");
    }
  }
}
