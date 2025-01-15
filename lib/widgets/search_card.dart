import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/restaurant_screen.dart';
import 'package:flutter_foodybite/util/review.dart';
import 'package:flutter_foodybite/util/review_service.dart';
import 'package:flutter_foodybite/util/restaurants.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class SearchCard extends StatefulWidget {
  @override
  _SearchCardState createState() => _SearchCardState();
}

class _SearchCardState extends State<SearchCard> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map> _filteredRestaurants = [];
  final ReviewService reviewService = ReviewService();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool showingOverlay = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterRestaurants(_searchController.text);
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && showingOverlay) {
        _hideOverlay();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPop() {
    super.didPop();
    _hideOverlay(); // Ocultar overlay cuando se haga pop
  }

  @override
  void didPush() {
    super.didPush();
    _hideOverlay(); // Opcionalmente ocultar overlay al empujar una nueva ruta
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _hideOverlay();
    }
  }

  void _filterRestaurants(String query) {
    if (query.isEmpty) {
      _filteredRestaurants = restaurants.take(5).toList();
    } else {
      _filteredRestaurants = restaurants
          .where((restaurant) =>
              (restaurant["title"]?.toLowerCase() ?? "").contains(query.toLowerCase()))
          .take(5)
          .toList();
    }
    _updateOverlay();
  }

  void _showOverlay() {
    showingOverlay = !showingOverlay;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    showingOverlay = !showingOverlay;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    showingOverlay = true;
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 250,
              ),
              child: _filteredRestaurants.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredRestaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = _filteredRestaurants[index];
                        return ListTile(
                          leading: Image.asset(
                            restaurant["img"],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            restaurant["title"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            restaurant["address"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            List<Review> reviews = await reviewService.getReviewsByRestaurant(restaurant["title"]);
                            print('Se hizo onTap');
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantScreen(
                                  imageUrl: restaurant["img"],
                                  restaurantName: restaurant["title"],
                                  reviews: reviews,
                                  latitude: restaurant['latitude'],
                                  longitude: restaurant['longitude'],
                                  address: restaurant['address']
                                ),
                              ),
                            );
                            _hideOverlay();
                          },
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text("No restaurants found.")),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // Método para cerrar el overlay desde fuera
  void closeOverlay() {
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onTap: () {
              if (_focusNode.hasFocus && !showingOverlay) {
                _showOverlay();
              } else {
                _hideOverlay();
              }
            },
            onEditingComplete: () {
              _hideOverlay();
            },
            decoration: InputDecoration(
              hintText: "Search for a restaurant...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Desuscribir del RouteObserver
    if (ModalRoute.of(context) is PageRoute) {
      routeObserver.unsubscribe(this);
    }
    _hideOverlay();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
