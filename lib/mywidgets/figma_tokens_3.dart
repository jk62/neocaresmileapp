import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';

class FigmaTokens {
  final Map<String, dynamic> md;
  final Map<String, dynamic> m3;

  FigmaTokens({required this.md, required this.m3});

  factory FigmaTokens.fromJson(Map<String, dynamic> json) {
    return FigmaTokens(
      md: json['md'],
      m3: json['m3'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'md': md,
      'm3': m3,
    };
  }

  // Function to load Figma tokens from a JSON file
  static Future<FigmaTokens> loadFromJsonFile() async {
    final String jsonString =
        await rootBundle.loadString('lib/tokens/figma_tokens_3.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert FontWeight strings to FontWeight enums
    jsonMap['md']['palette']['typescale']['headline-large']['value']
            ['fontWeight'] =
        convertToFontWeight(jsonMap['md']['palette']['typescale']
            ['headline-large']['value']['fontWeight']);

    jsonMap['md']['palette']['typescale']['headline-medium']['value']
            ['fontWeight'] =
        convertToFontWeight(jsonMap['md']['palette']['typescale']
            ['headline-medium']['value']['fontWeight']);

    return FigmaTokens.fromJson(jsonMap);
  }

  // // Helper function to convert FontWeight strings to FontWeight enum
  // static FontWeight convertToFontWeight(String fontWeight) {
  //   switch (fontWeight) {
  //     case 'Regular':
  //       return FontWeight.normal;
  //     case 'Medium':
  //       return FontWeight.w500; // Adjust as needed
  //     // Add more cases for other FontWeight strings
  //     default:
  //       return FontWeight.normal;
  //   }
  // }
  // Helper function to convert FontWeight strings to FontWeight enum
  static FontWeight convertToFontWeight(String fontWeight) {
    switch (fontWeight) {
      case 'Regular':
        return FontWeight.normal;
      case 'Medium':
        return FontWeight.w500; // Adjust as needed
      // Add more cases for other FontWeight strings
      default:
        return FontWeight.normal;
    }
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'dart:convert';

// class FigmaTokens {
//   final Map<String, dynamic> md;
//   final Map<String, dynamic> m3;

//   FigmaTokens({required this.md, required this.m3});

//   factory FigmaTokens.fromJson(Map<String, dynamic> json) {
//     return FigmaTokens(
//       md: json['md'],
//       m3: json['m3'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'md': md,
//       'm3': m3,
//     };
//   }

//   // Function to load Figma tokens from a JSON file
//   static Future<FigmaTokens> loadFromJsonFile() async {
//     final String jsonString =
//         await rootBundle.loadString('lib/tokens/figma_tokens_3.json');
//     final Map<String, dynamic> jsonMap = json.decode(jsonString);

//     // Convert FontWeight strings to FontWeight enums
//     jsonMap['md']['palette']['typescale']['headline-large']['value']
//             ['fontWeight'] =
//         convertToFontWeight(
//             jsonMap['md']['palette']['typescale']['headline-large']['value']
//                 ['fontFamily'],
//             jsonMap['md']['palette']['typescale']['headline-large']['value']
//                 ['fontWeight']);

//     jsonMap['md']['palette']['typescale']['headline-medium']['value']
//             ['fontWeight'] =
//         convertToFontWeight(
//             jsonMap['md']['palette']['typescale']['headline-medium']['value']
//                 ['fontFamily'],
//             jsonMap['md']['palette']['typescale']['headline-medium']['value']
//                 ['fontWeight']);

//     return FigmaTokens.fromJson(jsonMap);
//   }

//   // Helper function to convert FontWeight strings to FontWeight enum
//   // FontWeight convertToFontWeight(String fontWeight) {
//   static FontWeight convertToFontWeight(
//       String fontWeight, Map<String, dynamic> md) {
//     switch (fontWeight) {
//       case 'Regular':
//         return FontWeight.normal;
//       case 'Medium':
//         return FontWeight.w500; // Adjust as needed
//       // Add more cases for other FontWeight strings
//       default:
//         return FontWeight.normal;
//     }
//   }
// }


// import 'dart:convert';
// import 'package:flutter/services.dart';

// class FigmaTokens {
//   final Map<String, dynamic> md;
//   final Map<String, dynamic> m3;

//   FigmaTokens({required this.md, required this.m3});

//   factory FigmaTokens.fromJson(Map<String, dynamic> json) {
//     return FigmaTokens(
//       md: json['md'],
//       m3: json['m3'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'md': md,
//       'm3': m3,
//     };
//   }

//   // Function to load Figma tokens from a JSON file
//   static Future<FigmaTokens> loadFromJsonFile() async {
//     final String jsonString =
//         await rootBundle.loadString('lib/tokens/figma_tokens_3.json');
//     final Map<String, dynamic> jsonMap = json.decode(jsonString);
//     return FigmaTokens.fromJson(jsonMap);
//   }
// }
