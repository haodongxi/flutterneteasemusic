import 'dart:ui';

import 'package:flutter/cupertino.dart';
class ContextTool{
  BuildContext context;
  static ContextTool _shareValue =  ContextTool._internal();
  factory ContextTool.shareValue(){
    return _shareValue;
  }
  ContextTool._internal();
}