// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


// Demonstrates:
// list, maps, random, strings, string interpolation
// cascade, fat arrow, ternary operator
// named constructors
// optional parameters
// a class
// getters
// httprequest, JSON
// local storage
// static class-level methods/fields
// top-level variables and functions
// typecasting with 'as'
// futures
// import, also with show
// dart:core, html, math, convert and async libraries

import 'dart:html';
import 'dart:math' show Random;
import 'dart:convert' show JSON;
import 'dart:async' show Future;
import 'package:angular/angular.dart';
import 'package:di/di.dart';

final String TREASURE_KEY = 'pirateName';


class PirateModule extends Module {
  PirateModule(){
    type(PirateController);
  }
}

@NgController(selector: '[pirate]', publishAs : 'ctrl')
class PirateController {
  
  String pirateName = "";
  String generatorButton = "Aye! Gimme a name!";
  String inputName = "";
  bool piratesNamesLoaded = false;
  
  PirateController(){
    PirateName.readyThePirates()
      .then((_) {
        piratesNamesLoaded = true;
        _setBadgeName(_getBadgeNameFromStorage());
      })
      .catchError((arrr) {
        print('Error initializing pirate names: $arrr');
        pirateName = 'Arrr! No names.';
      });   
  }
  
  bool get emptyName =>
    inputName == null || inputName.trim().isEmpty;  
  
  void generateBadge() {
    _setBadgeName(new PirateName());
  }
  
  void updateBadge() {
    _setBadgeName(new PirateName(firstName: inputName));
    if (inputName.trim().isEmpty) {
      generatorButton = "Aye! Gimme a name!";
    } else {
      generatorButton = "Arrr! Write yer name!";
    }
  }

  void _setBadgeName(PirateName newName) {
    if (newName == null) {
      return;
    }
    pirateName = newName.pirateName;
    window.localStorage[TREASURE_KEY] = newName.jsonString;
  }
  
  PirateName _getBadgeNameFromStorage() {
    String storedName = window.localStorage[TREASURE_KEY];
    if (storedName != null) {
      return new PirateName.fromJSON(storedName);
    } else {
      return null;
    }
  }  

}

void main(){
  ngBootstrap(module: new PirateModule());
}

class PirateName {
  
  static final Random indexGen = new Random();

  static List<String> names = [];
  static List<String> appellations = [];

  String _firstName;
  String _appellation;
  
  PirateName({String firstName, String appellation}) {
    
    if (firstName == null) {
      _firstName = names[indexGen.nextInt(names.length)];
    } else {
      _firstName = firstName;
    }
    if (appellation == null) {
      _appellation = appellations[indexGen.nextInt(appellations.length)];
    } else {
      _appellation = appellation;
    }
  }

  PirateName.fromJSON(String jsonString) {
    Map storedName = JSON.decode(jsonString);
    _firstName = storedName['f'];
    _appellation = storedName['a'];
  }

  String toString() => pirateName;

  String get jsonString => '{ "f": "$_firstName", "a": "$_appellation" } ';

  String get pirateName => _firstName.isEmpty ? '' : '$_firstName the $_appellation';

  static Future readyThePirates() {
    String path = 'piratenames.json';
    return HttpRequest.getString(path)
        .then(_parsePirateNamesFromJSON);
  }
  
  static _parsePirateNamesFromJSON(String jsonString) {
    Map pirateNames = JSON.decode(jsonString);
    names = pirateNames['names'];
    appellations = pirateNames['appellations'];
  }
}
