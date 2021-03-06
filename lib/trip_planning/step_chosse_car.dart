import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:madar_booking/app_bloc.dart';
import 'package:madar_booking/bloc_provider.dart';
import 'package:madar_booking/car_card_widget.dart';
import 'package:madar_booking/madarLocalizer.dart';
import 'package:madar_booking/models/Car.dart';
import 'package:madar_booking/my_flutter_app_icons.dart';
import 'package:madar_booking/rate_widget.dart';
import 'package:madar_booking/trip_planning/bloc/choose_car_bloc.dart';
import 'package:madar_booking/trip_planning/bloc/trip_planing_bloc.dart';
import 'package:madar_booking/widgets/language_tag.dart';
import 'package:shimmer/shimmer.dart';

class StepChooseCar extends StatefulWidget {
  @override
  StepChooseCarState createState() {
    return new StepChooseCarState();
  }
}

class StepChooseCarState extends State<StepChooseCar>
    with TickerProviderStateMixin {
  ChooseCarBloc bloc;
  TripPlaningBloc planingBloc;
  AnimationController _controller;
  Animation<Offset> _offsetFloat;

  @override
  void initState() {
    planingBloc = BlocProvider.of<TripPlaningBloc>(context);
    bloc = ChooseCarBloc(
        planingBloc.trip, BlocProvider.of<AppBloc>(context).token);
    bloc.pushCars;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    final CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: _controller, curve: ElasticOutCurve(0.5));

    _offsetFloat = Tween<Offset>(begin: Offset(0.0, 200), end: Offset.zero)
        .animate(curvedAnimation);

    _offsetFloat.addListener(() {
      setState(() {});
    });

    _controller.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle infoLabelStyle = TextStyle(
        color: Colors.grey[700],
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 0.8);
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          StreamBuilder<List<Car>>(
              stream: bloc.carsStream,
              builder: (context, carsSnapshot) {
                if (carsSnapshot.hasData && carsSnapshot.data.isNotEmpty)
                  planingBloc.tripCar(carsSnapshot.data[0]);
                return AnimatedBuilder(
                  animation: _offsetFloat,
                  builder: (context, widget) {
                    return Transform.translate(
                      offset: _offsetFloat.value,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 24, left: 24),
                            height: MediaQuery.of(context).size.height - 120,
                            width: MediaQuery.of(context).size.width,
                            padding:
                                EdgeInsets.only(right: 16, left: 16, top: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: carsSnapshot.hasData &&
                                    carsSnapshot.data.isNotEmpty
                                ? StreamBuilder<Car>(
                                    stream: bloc.selectedCarStream,
                                    initialData: carsSnapshot.data[0],
                                    builder: (context, carSnapshot) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Text(
                                                  MadarLocalizations.of(context)
                                                      .trans('estim_cost'),
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 0.5),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Text(
                                                    planingBloc.trip
                                                        .estimationPrice()
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontSize: 60,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        height: 0.5),
                                                  ),
                                                  Text(
                                                    '\$',
                                                    style: TextStyle(
                                                        color: Colors.grey[800],
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    carSnapshot.data.name,
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey[800],
                                                        height: 0.5),
                                                  ),
                                                  Text(
                                                    carSnapshot
                                                        .data.driver.username,
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.grey[600],
                                                        height: 0.5),
                                                  ),
                                                ],
                                              ),
                                              RateWidget(
                                                carSnapshot.data.rate
                                                    .toString(),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: 15,
                                          ),
                                          Wrap(
                                            spacing: 4,
                                            children: carSnapshot
                                                .data.driver.driverLangs
                                                .map((language) => LanguageTag(
                                                      text: Text(
                                                        language.language.name,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            height: 0.8),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                          Container(
                                            height: 40,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Column(
                                                  children: <Widget>[
                                                    Icon(
                                                      MyFlutterApp.cal,
                                                      size: 28,
                                                      color: Colors.grey[800],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                          carSnapshot.data
                                                              .productionDate
                                                              .toString(),
                                                          style:
                                                              infoLabelStyle),
                                                    ),
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Icon(
                                                        MyFlutterApp.gender,
                                                        size: 28,
                                                        color: Colors.grey[800],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                            MadarLocalizations
                                                                    .of(context)
                                                                .trans(
                                                                    carSnapshot
                                                                        .data
                                                                        .driver
                                                                        .gender),
                                                            style:
                                                                infoLabelStyle),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: <Widget>[
                                                    Icon(
                                                      MyFlutterApp.seats,
                                                      size: 28,
                                                      color: Colors.grey[800],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 8.0),
                                                      child: Text(
                                                          '${carSnapshot.data.numOfSeat.toString()} ' +
                                                              MadarLocalizations
                                                                      .of(
                                                                          context)
                                                                  .trans(
                                                                      'seats'),
                                                          style:
                                                              infoLabelStyle),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    })
                                : carsSnapshot.hasData &&
                                        carsSnapshot.data.isEmpty
                                    ? _empty()
                                    : _topShimmer(),
                          ),
                          carsSnapshot.hasData && carsSnapshot.data.isNotEmpty
                              ? StreamBuilder<int>(
                                  stream: bloc.indexStream,
                                  initialData: 0,
                                  builder: (context, indexSnapshot) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              2.2),
                                      height:
                                          MediaQuery.of(context).size.width / 1.8,
                                      child: ListView.builder(
                                        itemBuilder: (context, index) {
                                          return CarCard(
                                            car: carsSnapshot.data[index],
                                            onTap: (car) {
                                              bloc.selectCar(car, index);
                                              planingBloc.tripCar(
                                                  carsSnapshot.data[index]);
                                            },
                                            selected:
                                                index == indexSnapshot.data,
                                          );
                                        },
                                        scrollDirection: Axis.horizontal,
                                        itemCount: carsSnapshot.data.length,
                                      ),
                                    );
                                  })
                              : carsSnapshot.hasData &&
                                      carsSnapshot.data.isEmpty
                                  ? Container()
                                  : _listShimmer(),
                        ],
                      ),
                    );
                  },
                );
              }),
        ],
      ),
    );
  }

  _topShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100],
      highlightColor: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  MadarLocalizations.of(context).trans('estim_cost'),
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 0.5),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    height: 24,
                    width: 40,
                    color: Colors.grey[300],
                  ),
                  Container(
                    height: 18,
                    width: 80,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 4),
                height: 14,
                width: 32,
                color: Colors.grey[300],
              ),
            ],
          ),
          Container(
            height: 30,
          ),
          Wrap(spacing: 4, children: [
            Container(
              height: 10,
              width: 40,
              color: Colors.grey[300],
            ),
            Container(
              height: 10,
              width: 40,
              color: Colors.grey[300],
            ),
            Container(
              height: 10,
              width: 40,
              color: Colors.grey[300],
            ),
          ]),
          Container(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Icon(
                      MyFlutterApp.cal,
                      size: 28,
                      color: Colors.grey[800],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        height: 12,
                        width: 40,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Icon(
                        MyFlutterApp.gender,
                        size: 28,
                        color: Colors.grey[800],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          height: 12,
                          width: 40,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Icon(
                      MyFlutterApp.seats,
                      size: 28,
                      color: Colors.grey[800],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        height: 12,
                        width: 40,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _listShimmer() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.2),
      height: MediaQuery.of(context).size.width / 2,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[200],
            child: Container(
              margin: EdgeInsets.all(8),
              width: MediaQuery.of(context).size.width / 1.3,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.grey[300],
              ),
            ),
          );
        },
        scrollDirection: Axis.horizontal,
        itemCount: 2,
      ),
    );
  }

  Widget _empty() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            MadarLocalizations.of(context).trans('no_cars_error'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          FlatButton(
            onPressed: () => planingBloc.navBackward,
            child: Text(
              MadarLocalizations.of(context).trans('back'),
            ),
          ),
        ],
      ),
    );
  }
}
