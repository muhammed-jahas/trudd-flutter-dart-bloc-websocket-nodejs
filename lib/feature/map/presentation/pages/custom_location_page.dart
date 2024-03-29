import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trudd_track_your_buddy/core/utils/colors.dart';
import 'package:trudd_track_your_buddy/feature/map/presentation/bloc/search/search_bloc.dart';
import 'package:trudd_track_your_buddy/feature/room/presentation/bloc/spot_bloc.dart';
import '../../../../config/map_theme.dart';
import '../widgets/result_viewer.dart';
import '../widgets/search_bar.dart';

class ScreenCustomLocation extends StatelessWidget {
  ScreenCustomLocation({super.key, required this.location});
  final LatLng location;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  @override
  Widget build(BuildContext context) {
    final dheight = MediaQuery.sizeOf(context).height;
    final dPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(140), child: CustomAppBar()),
      body: SingleChildScrollView(
        child: SizedBox(
          height: dheight - 140 - dPadding,
          child: Column(
            children: [
              Expanded(
                  child: Stack(
                children: [
                  BlocBuilder<SearchBloc, SearchState>(
                    buildWhen: (previous, current) =>
                        current is! SearchActionState,
                    builder: (context, state) {
                      Set<Marker> marker =
                          (state is MapLocationSetState) ? {state.marker} : {};
                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: location,
                          zoom: 13,
                        ),
                        onMapCreated: (controller) async {
                          String darkTheme = '';
                          await DefaultAssetBundle.of(context)
                              .loadString(googleMapDarkTheme)
                              .then((value) {
                            // print(value);
                            darkTheme = value;
                          });
                          await controller.setMapStyle(darkTheme);
                          _controller.complete(controller);
                        },
                        compassEnabled: false,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: true,
                        markers: marker,
                        onTap: (LatLng pos) {
                          context
                              .read<SearchBloc>()
                              .add(SetLocationEvent(position: pos));
                        },
                      );
                    },
                  ),
                  ResultViewer(controller: _controller),
                ],
              )),
              Container(
                color: AppColor.accentColor,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    BlocBuilder<SearchBloc, SearchState>(
                      builder: (context, state) {
                        VoidCallback onPressed = (state is MapLocationSetState)
                            ? () {
                                context.read<SpotBloc>().add(
                                    SetDestinationEvent(
                                        destination: state.marker.position));
                                Navigator.pop(context);
                              }
                            : () {};
                        return ElevatedButton(
                          onPressed: onPressed,
                          child: const Text('Submit'),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
