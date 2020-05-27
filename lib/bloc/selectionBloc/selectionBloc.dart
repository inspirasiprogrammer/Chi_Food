

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chifood/bloc/authBloc/AuthBloc.dart';
import 'package:chifood/bloc/authBloc/AuthState.dart';
import 'package:chifood/bloc/implementation/SelectionImplement.dart';
import 'package:chifood/bloc/selectionBloc/selectionEvent.dart';
import 'package:chifood/bloc/selectionBloc/selectionState.dart';
import 'package:chifood/model/category.dart';
import 'package:chifood/model/cuisine.dart';
import 'package:chifood/model/establishment.dart';
import 'package:chifood/model/geoLocation.dart';
import 'package:flutter/cupertino.dart';

class SelectionBloc extends Bloc<SelectionEvent,SelectionState>{
  final SelectionImplement selectionRepo;
  final AuthenticationBloc AuthBloc;
  StreamSubscription authSubscription;
  SelectionBloc({@required this.selectionRepo,this.AuthBloc}){
    authSubscription=AuthBloc.listen((state){

      if(state is Authenticated){
//        add(LoadCusines(city_id: state.user.cityId));
//        add(LoadEstablishment(city_id: state.user.cityId));
//        add(LoadGeoInfo(state.user.lat,state.user.long));
      add(LoadAllBaseChoice(city_id: state.user.cityId,lon: state.user.long,lat: state.user.lat));
      }
    });
  }
  @override
  // TODO: implement initialState
  SelectionState get initialState => LoadingSelectionState();

  @override
  Stream<SelectionState> mapEventToState(SelectionEvent event) async*{

   if(event is LoadAllBaseChoice){
        yield* _mapLoadAllToState(event);
    }
  }
  @override
  Future<void> close() {
    authSubscription.cancel();
    return super.close();
  }


  Stream<SelectionState> _mapLoadAllToState(LoadAllBaseChoice data) async*{
    try{
      List<Establishment> establishment= await selectionRepo.getEstablishments(city_id: data.city_id,lat:data.lat,lon:data.lon);
      GeoLocation geoLocation=await selectionRepo.getGeoLocation(lat: data.lat,lon: data.lon);
      List<Category> categoryList= await selectionRepo.getCategories();
      List<Cuisine> cuisineList= await selectionRepo.getCuisines(city_id: data.city_id,lat:data.lat,lon:data.lon);

      yield BaseChoice(establishment,categoryList,geoLocation,cuisineList);
    }catch(e){
      print(e);
      yield SelectionLoadFailState();
    }
  }




}