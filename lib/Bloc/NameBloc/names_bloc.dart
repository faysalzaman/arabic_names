// ignore_for_file: unnecessary_null_comparison, avoid_print

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arabic_names/DataBase/Converter.dart';
import 'package:arabic_names/DataBase/SharedPrefrences.dart';
import 'package:arabic_names/DataBase/dataBase.dart';
import 'package:arabic_names/Model/names_model.dart';
part 'names_event.dart';
part 'names_state.dart';

class NamesBloc extends Bloc<NamesEvent, NamesState> {
  NamesBloc() : super(NamesInitial()) {
    SqlLiteDb obj = SqlLiteDb();
    on<GetNames>(
      (event, emit) async {
        emit(NamesLoading());
        List<NameModel> list = [];
        bool? isViewed =
            await SharedPreference.getbool(SharedPreference.isViewed);
        if (isViewed == true) {
          list = await obj.getItems();
          emit(NamesSuccess(model: list));
        } else {
          // var fenaledata = await jsonDecode(maleresponse);
          //  list = await fireBase.getData();
          //  Future.delayed(Duration(seconds: 4), () async {
          obj.createItem(model: list);
          await SharedPreference.savebool(SharedPreference.isViewed, true);
          emit(
            NamesSuccess(model: list),
          );
          //  });
        }
      },
    );
    on<RefreshNames>(
      (event, emit) async {
        emit(NamesLoading());

        List<NameModel> gendermodel = [];
        List<NameModel> combinelist = [];

        List<NameModel>? list = [];

        if (event.gender == "Male") {
          var maleresponse =
              await rootBundle.loadString('assets/ArabicData.json');
          final malepraser = DataParser(encodedJson: maleresponse);
          gendermodel = await malepraser.parseInBackground();
        } else if (event.gender == "Male") {
          var Maleresponse =
              await rootBundle.loadString('assets/ArabicData.json');
          final Malepraser = DataParser(encodedJson: Maleresponse);
          gendermodel = await Malepraser.parseInBackground();
        } else if (event.gender == "Boy") {
          try {
            var boysResponse = await rootBundle.loadString('assets/TBoys.json');
            if (boysResponse != null) {
              final femalepraser = DataParser(encodedJson: boysResponse);
              gendermodel = await femalepraser.parseInBackground();
              print("Data loaded successfully for TBoys.");
            } else {
              print("No data found for TBoys.");
            }
          } catch (e) {
            print("Error loading data for TBoys: $e");
          }
        } else if (event.gender == "Girl") {
          try {
            var girlsResponse =
                await rootBundle.loadString('assets/TGirls.json');
            if (girlsResponse != null) {
              final femalepraser = DataParser(encodedJson: girlsResponse);
              gendermodel = await femalepraser.parseInBackground();
              print("Data loaded successfully for TGirls.");
            } else {
              print("No data found for TGirls.");
            }
          } catch (e) {
            print("Error loading data for TGirls: $e");
          }
        } else if (event.gender == "Larka") {
          try {
            var boysResponse = await rootBundle.loadString('assets/cboys.json');
            if (boysResponse != null) {
              final femalepraser = DataParser(encodedJson: boysResponse);
              gendermodel = await femalepraser.parseInBackground();
              print("Data loaded successfully for CBoys.");
            } else {
              print("No data found for CBoys.");
            }
          } catch (e) {
            print("Error loading data for CBoys: $e");
          }
        } else if (event.gender == "Larki") {
          try {
            var girlsResponse =
                await rootBundle.loadString('assets/cgirls.json');
            if (girlsResponse != null) {
              final femalepraser = DataParser(encodedJson: girlsResponse);
              gendermodel = await femalepraser.parseInBackground();
              print("Data loaded successfully for CGirls.");
            } else {
              print("No data found for CGirls.");
            }
          } catch (e) {
            print("Error loading data for CGirls: $e");
          }
        }

        var existingItems = await obj.getItems();
        if (existingItems != null) {
          var filteredlist =
              list.where((element) => existingItems.contains(element)).toList();
          if (filteredlist.isNotEmpty) {
            obj.createItem(model: filteredlist);
          }
        }

        combinelist = [gendermodel, list].expand((data) => data).toList();

        var filteredList = combinelist
            .where((element) => element.gender == event.gender)
            .toList();

        // remove duplicate values from the list
        filteredList = filteredList.toSet().toList();
        list = list.toSet().toList();

        emit(NamesSuccess(filteredList: filteredList, model: list));
      },
    );

    on<GetNamesOnGender>(
      (event, emit) async {
        emit(NamesLoading());
        List<NameModel> gendermodel = [];
        List<NameModel> combinelist = [];

        if (event.gender == "Male") {
          var maleresponse =
              await rootBundle.loadString('assets/ArabicData.json');
          final malepraser = DataParser(encodedJson: maleresponse);
          gendermodel = await malepraser.parseInBackground();
        } else if (event.gender == "Female") {
          var Maleresponse =
              await rootBundle.loadString('assets/girls_name.json');
          final Malepraser = DataParser(encodedJson: Maleresponse);
          gendermodel = await Malepraser.parseInBackground();
        } else if (event.gender == "Boy") {
          try {
            var boysResponse =
                await rootBundle.loadString('assets/trending_boys.json');
            if (boysResponse != null) {
              final femalepraser = DataParser(encodedJson: boysResponse);
              gendermodel = await femalepraser.parseInBackground();
              print("Data loaded successfully for TBoys.");
            } else {
              print("No data found for TBoys.");
            }
          } catch (e) {
            print("Error loading data for TBoys: $e");
          }
        } else if (event.gender == "Girl") {
          try {
            var girlsResponse =
                await rootBundle.loadString('assets/trending_girls.json');
            if (girlsResponse != null) {
              final femalepraser = DataParser(encodedJson: girlsResponse);
              gendermodel = await femalepraser.parseInBackground();
              print("Data loaded successfully for TGirls.");
            } else {
              print("No data found for TGirls.");
            }
          } catch (e) {
            print("Error loading data for TGirls: $e");
          }
        } else if (event.gender == "Larka") {
          try {
            var boysResponse = await rootBundle.loadString('assets/cboys.json');
            if (boysResponse != null) {
              final femalepraser = DataParser(encodedJson: boysResponse);
              gendermodel = await femalepraser.parseInBackground();
              print("Data loaded successfully for CBoys.");
            } else {
              print("No data found for CBoys.");
            }
          } catch (e) {
            print("Error loading data for CBoys: $e");
          }
        } else if (event.gender == "Larki") {
          try {
            var girlsResponse =
                await rootBundle.loadString('assets/cgirls.json');
            if (girlsResponse != null) {
              final femalepraser = DataParser(encodedJson: girlsResponse);
              gendermodel = await femalepraser.parseInBackground();
              print("Data loaded successfully for CGirls.");
            } else {
              print("No data found for CGirls.");
            }
          } catch (e) {
            print("Error loading data for CGirls: $e");
          }
        }

        combinelist = [gendermodel].expand((data) => data).toList();

        List<NameModel>? list = await obj.getItems();

        var filteredList = combinelist
            .where((element) => element.gender == event.gender)
            .toList();

        // remove duplicate values from the list
        filteredList = filteredList.toSet().toList();
        list = list.toSet().toList();

        emit(NamesSuccess(filteredList: filteredList, model: list));
        // emit(NamesSuccess(filteredList: filteredList, model: gendermodel));
      },
    );
  }
}
