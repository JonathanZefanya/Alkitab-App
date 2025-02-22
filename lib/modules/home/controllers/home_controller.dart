import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firman/core/constans/constans.dart';
import 'package:firman/core/constans/response_constans.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firman/core/models/book/book_model.dart';
import 'package:firman/core/models/database/database_model.dart';
import 'package:firman/core/models/passage/header/headers_model.dart';
import 'package:firman/core/models/passage/verse/verses_model.dart';
import 'package:firman/core/services/api/api_service.dart';
import 'package:firman/core/services/db/database_service.dart';
import 'package:firman/core/services/user_service.dart';
import 'package:firman/styles/style_app.dart';

class HomeController extends GetxController {
  final apiService = Get.put(ApiService());
  RxBool isLoading = false.obs;
  RxList<BookModel> bookModelList = <BookModel>[].obs;
  RxList<int> chapterList = <int>[].obs;
  RxBool isLoadingAi = false.obs;
  int verse = 0;
  String abbr = "";
  Rx<HeadersModel> headerModel = HeadersModel().obs;
  RxString verseSelected = "".obs;
  RxString abbrSelected = "".obs;
  String idDatabase = "";
  RxBool isPlaying = false.obs;
  FlutterTts flutterTts = FlutterTts();
  RxString aiResult = "".obs;
  RxBool isVerseSaved = false.obs;
  RxBool isLoadingLoadSavedVerse = false.obs;
  String apiKey = "";
  RxList<DatabaseModel> databaseModelList = <DatabaseModel>[].obs;
  late DatabaseService databaseService;
  late UserService userService;
  RxDouble abbrFontSize = 20.sp.obs,
      titleSize = 17.sp.obs,
      textSize = 16.sp.obs,
      verseSize = 10.sp.obs,
      textSizeMin = 16.sp.obs,
      textSizeMax = 50.sp.obs,
      textCurrentSize = 16.sp.obs;
  RxBool isSettingButtonClicked = false.obs;
  RxBool isBookmarkButtonClicked = false.obs;
  RxBool isDeveloperButtonClicked = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await _initialize();
  }

  // Metode async terpisah
  Future<void> _initialize() async {
    userService = Get.find<UserService>();
    initFontSize();
    await initLastAbbrVerse();
    await getBook();
    databaseService = Get.find<DatabaseService>();
    await databaseService.database;
    await dotenv.load(fileName: ".env");
    apiKey = dotenv.env['API_KEY'] ?? "";
  }

  Future initLastAbbrVerse() async {
    String lastAbbr =
        await userService.getString(Constans.PREF_LAST_ABBR_SAVED);
    int lastVerse = await userService.getInt(Constans.PREF_LAST_VERSE_SAVED);
    int lastVerseLength =
        await userService.getInt(Constans.PREF_LAST_VERSE_LENGTH_SAVED);

    if (lastAbbr != "" && lastVerse != 0 && lastVerseLength != 0) {
      abbr = lastAbbr;
      verse = lastVerse;
      print('kevin: $lastVerseLength');
      for (var i = 1; i < lastVerseLength; i++) {
        chapterList.add(i);
      }
    } else {
      abbr = Constans.INIT_LAST_ABBR;
      verse = Constans.INIT_LAST_VERSE;
      for (var i = 1; i < 50; i++) {
        chapterList.add(i);
      }
    }

    print(chapterList.length);

    return await getChapter(abbr, verse);
  }

  Future<void> prompToAI(String text) async {
    isLoadingAi.value = true;

    if (apiKey.isEmpty) {
      Get.snackbar("Error", "Terjadi kesalahan");
      aiResult.value = "";
      isLoadingAi.value = false; // ✅ Pastikan loading dihentikan
      return;
    }

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final content = [Content.text(text)];
      final response = await model.generateContent(content);

      // ✅ Tambahkan logging untuk memastikan respons dari API
      print("Response AI: ${response.text}");

      aiResult.value = response.text ?? "";
    } catch (e) {
      print("Error AI: $e");
      Get.snackbar("Error", "Something went wrong");
      aiResult.value = "";
    } finally {
      isLoadingAi.value = false; // ✅ Pastikan loading dihentikan di semua kondisi
    }
  }


  void initFontSize() {
    final abbrSize = userService.getDouble(Constans.PREF_SIZE_ABBR);
    final titleFontSize = userService.getDouble(Constans.PREF_SIZE_TITLE);
    final textFontSize = userService.getDouble(Constans.PREF_SIZE_TEXT);
    final verseFontSize = userService.getDouble(Constans.PREF_SIZE_VERSE);

    if (abbrSize != 0.0) {
      abbrFontSize.value = abbrSize;
    }

    if (titleFontSize != 0.0) {
      titleSize.value = titleFontSize;
    }

    if (textFontSize != 0.0) {
      textSize.value = textFontSize;
      textCurrentSize.value = textFontSize;
    }

    if (verseFontSize != 0.0) {
      verseSize.value = verseFontSize;
    }

    // **Pastikan min dan max tidak nol**
    if (textSizeMin.value == 0.0) textSizeMin.value = 16.0;
    if (textSizeMax.value == 0.0) textSizeMax.value = 50.0;

    print('size current value : $textCurrentSize');
  }

  Future<void> getBook() async {
    bookModelList.clear();

    final dataBook = await apiService.getBook();

    if (dataBook.state == ResponseConstans.success_state) {
      bookModelList.addAll(dataBook.data);

      return;
    } else {
      Get.snackbar("Notifikasi", dataBook.message ?? "Terjadi kesalahan",
          backgroundColor: Colors.red[50], colorText: StyleApp.black);
    }
  }

  Future<void> getChapter(String abbr, int verse) async {
    isLoading.value = true;
    final responseApi = await apiService.getChapter(abbr, verse);
    isLoading.value = false;

    if (responseApi.state == ResponseConstans.success_message) {
      headerModel.value = HeadersModel();
      headerModel.value = responseApi.data;
      print(headerModel.toString());
    } else {
      Get.snackbar("Notifikasi", responseApi.message ?? "Terjadi kesalahan",
          backgroundColor: Colors.red[50], colorText: StyleApp.black);
    }
  }

  String getTimeOfDay() {
    // Dapatkan waktu saat ini
    var now = DateTime.now();
    // Format waktu untuk mendapatkan jam saja
    var formatter = DateFormat('HH');
    String formatted = formatter.format(now);
    int hour = int.parse(formatted);

    // Tentukan waktu berdasarkan jam
    if (hour >= 5 && hour < 12) {
      return 'Selamat Pagi ☀️,';
    } else if (hour >= 12 && hour < 15) {
      return 'Selamat Siang 🌞,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore ⛅,';
    } else {
      return 'Selamat Malam 🌙,';
    }
  }

  Future<void> getVerseSaved() async {
    isLoadingLoadSavedVerse.value = true;
    databaseModelList.clear();

    try {
      final databaseList = await databaseService.getVerseSaved();
      if (databaseList.isNotEmpty) {
        databaseModelList.addAll(databaseList);
      }
      isLoadingLoadSavedVerse.value = false;
      print(databaseModelList.toString());

      return;
    } catch (e) {
      isLoadingLoadSavedVerse.value = false;

      Get.snackbar("Gagal", "Ooops,Terjadi kesalahan");
      print(e.toString());
      return;
    }
  }

  void resetState() {
    if (isPlaying.value) {
      voiceStop();
    }

    verseSelected.value = "";
    abbrSelected.value = "";
    isPlaying.value = false;
    isVerseSaved.value = false;
    aiResult.value = "";
  }

  void voiceSpeak() async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(verseSelected.value);
    isPlaying.value = true;
  }

  void voiceStop() async {
    await flutterTts.pause();

    isPlaying.value = false;
  }

  void validateDataSavedVerse() {
    if (idDatabase.isEmpty ||
        idDatabase == "" ||
        abbrSelected.value.isEmpty ||
        abbrSelected.value == "" ||
        verseSelected.value.isEmpty ||
        verseSelected.value == "") {
      print(idDatabase);
      print(abbrSelected.value);
      print(verseSelected.value);
      Get.snackbar("Gagal", "Oops, pilih ayat terlebih dahulu");
      return;
    }
    DatabaseModel databaseModel = DatabaseModel(
        id: idDatabase,
        abbr_verse: abbrSelected.value,
        text: verseSelected.value);
    saveVerse(databaseModel);
  }

  Future<void> saveVerse(DatabaseModel databaseModel) async {
    try {
      await databaseService.insertVerse(databaseModel);
      isVerseSaved.value = true;

      Get.snackbar("Berhasil", "Yeay ayat berhasil disimpan",
          backgroundColor: StyleApp.primary, colorText: StyleApp.white);
      return;
    } catch (e) {
      Get.snackbar("Error", "Yahh, gagal menyimpan ayat");
      print(e.toString());
      return;
    }
  }

  Future<void> saveLastVerse() async {
    if (abbr != "" && verse != 0) {
      await userService.saveString(Constans.PREF_LAST_ABBR_SAVED, abbr);
      await userService.saveInt(Constans.PREF_LAST_VERSE_SAVED, verse);
      await userService.saveInt(
          Constans.PREF_LAST_VERSE_LENGTH_SAVED, chapterList.length);
    }
  }

  Future<void> saveSetting(double val) async {
    double stateAbbrSize = val + 4;
    double stateTitleSize = val + 1;
    double stateTextSize = val;
    double stateVerseSize = val - 6;

    // set size
    abbrFontSize.value = stateAbbrSize.toDouble();
    titleSize.value = stateTitleSize.toDouble();
    textSize.value = stateTextSize.toDouble();
    verseSize.value = stateVerseSize.toDouble();
    textCurrentSize.value = stateTextSize.toDouble();

    await userService.saveDouble(
        Constans.PREF_SIZE_ABBR, stateAbbrSize.toDouble());
    await userService.saveDouble(
        Constans.PREF_SIZE_TITLE, stateTitleSize.toDouble());
    await userService.saveDouble(
        Constans.PREF_SIZE_TEXT, stateTextSize.toDouble());
    await userService.saveDouble(
        Constans.PREF_SIZE_VERSE, stateVerseSize.toDouble());
  }

  void setVerseSelected(String val) {
    verseSelected.value = val;
  }

  Future<void> removeVerseSaved(String id, int position) async {
    try {
      await databaseService.deleteSavedVerse(id);
      databaseModelList.removeAt(position);
    } catch (e) {
      Get.snackbar("Error", "Yah, gagal menghapus ayat");
      return;
    }
  }

  void setChapterList(int val) {
    chapterList.clear();
    for (int i = 1; i <= val; i++) {
      chapterList.add(i);
    }
  }
}
