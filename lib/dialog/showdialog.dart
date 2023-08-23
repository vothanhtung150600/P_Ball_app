import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Future faillogin(context, String message,{ Function? onPressOK, Function? onPressCancel, bool isInfo = false } ) async {
  await Future.delayed(Duration(milliseconds: 100), () {
    if (message != null || message.isNotEmpty) {
      return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.all(0),
            title: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        message,
                        maxLines: 20,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            height: 1.2
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(height: 1,width: double.infinity,color: Colors.black,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (onPressCancel != null)
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                        width: 1,
                                        color: Colors.black,
                                      )
                                  )
                              ),
                              child: TextButton(
                                child: Text('Cancel',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        letterSpacing: 0.05,
                                        height: 1.3
                                    )),
                                onPressed: () {
                                  onPressCancel();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ),
                        //if (onPressCancel != null)
                        //Container(height: SizeConfig.textMultiplier * 5,width:SizeConfig.heightMultiplier*0.1,color: AppColors.colorMain4,),
                        if (onPressOK != null)
                          Expanded(
                            flex: 1,
                            child: TextButton(
                              child: Text('Thử lại',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      letterSpacing: 0.05,
                                      fontWeight: FontWeight.w700
                                  )),
                              onPressed: () {
                                onPressOK();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  });
}



Future messageReport(context,String name,int price,{ Function(TextEditingController ctlreport)? onPressOK} ) async {
  await Future.delayed(Duration(milliseconds: 100), () {
    TextEditingController ctlreport = TextEditingController();
    return showModalBottomSheet<void>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              margin: EdgeInsets.only(bottom: 20,left: 10,right: 10),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(left: 10,right: 30),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.close,color: Colors.black,),
                            ),
                            SizedBox(width: 50,),
                            Container(
                              width: 200,
                              child: Text(
                                name,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(height: 1,width: double.infinity,decoration: BoxDecoration(border: Border.all(color: Colors.black),color: Colors.white.withOpacity(0.5)),),
                    Expanded(
                        flex: 4,
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              Text('Nếu giá có thay đổi hãy cập nhật bên dưới',style: TextStyle(fontSize: 18),),
                              SizedBox(height: 30,),
                              Container(
                                margin: EdgeInsets.only(left: 10,right: 10),
                                child: TextFormField(
                                  obscureText:  false,
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  textAlignVertical: TextAlignVertical.top,
                                  minLines: 1,
                                  style: TextStyle(color: Colors.black),
                                  controller: ctlreport,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelStyle: TextStyle(color: Colors.grey),
                                    enabledBorder:  OutlineInputBorder(
                                      borderSide:  BorderSide(color: Colors.black, width: 0.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
                    Container(height: 1,width: double.infinity,color: Colors.white.withOpacity(0.5),),

                    Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: GestureDetector(
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Center(
                                          child: Text('Cập nhật',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white,
                                                  letterSpacing: 0.05,
                                                  fontWeight: FontWeight.w700
                                              )),
                                        ),
                                      ),
                                      onTap: () {
                                        onPressOK!(ctlreport);
                                        Navigator.pop(context);

                                      },
                                    ),
                                  )
                              ),
                          ],
                        )
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) {});
  });
}


Future messageAccess(context, String message,{ Function? onPressOK, Function? onPressCancel, bool isInfo = false } ) async {
  await Future.delayed(Duration(milliseconds: 100), () {
    if (message != null || message.isNotEmpty) {
      return showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.all(0),
            title: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                    color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (onPressCancel != null)
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextButton(
                              child: Text('Chưa',
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 0.05,
                                      fontWeight: FontWeight.w700
                                  )),
                              onPressed: () {
                                onPressCancel();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        //if (onPressCancel != null)
                        //Container(height: SizeConfig.textMultiplier * 5,width:SizeConfig.heightMultiplier*0.1,color: AppColors.colorMain4,),
                        if (onPressOK != null)
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextButton(
                              child: Text('Thử lại',
                                  style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 0.05,
                                      fontWeight: FontWeight.w700
                                  )),
                              onPressed: () {
                                onPressOK();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  });
}

