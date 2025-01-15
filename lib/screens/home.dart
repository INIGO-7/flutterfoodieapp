import 'package:flutter/material.dart';
import 'package:flutter_foodybite/screens/categories.dart';
import 'package:flutter_foodybite/screens/restaurant_screen.dart';
import 'package:flutter_foodybite/screens/restaurants_category.dart';
import 'package:flutter_foodybite/screens/trending.dart';
import 'package:flutter_foodybite/util/categories.dart';
import 'package:flutter_foodybite/util/restaurants.dart';
import 'package:flutter_foodybite/util/review_service.dart';
import 'package:flutter_foodybite/widgets/category_item.dart';
import 'package:flutter_foodybite/widgets/search_card.dart';
import 'package:flutter_foodybite/widgets/slide_item.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ReviewService _reviewService = ReviewService();
  Map<String, double> restaurantRatings = {};

  @override
  void initState() {
    super.initState();
    _calculateRatings();
  }

  Future<void> _calculateRatings() async {
    final reviews = await _reviewService.loadReviews(); // Método público ahora
    final Map<String, List<double>> ratingsMap = {};

    for (var review in reviews) {
      final restaurant = review['restaurant'] as String;
      final rating = review['rating'] as double;

      if (!ratingsMap.containsKey(restaurant)) {
        ratingsMap[restaurant] = [];
      }
      ratingsMap[restaurant]?.add(rating);
    }

    final Map<String, double> computedRatings = {};
    ratingsMap.forEach((restaurant, ratings) {
      computedRatings[restaurant] =
          ratings.reduce((a, b) => a + b) / ratings.length;
    });

    setState(() {
      restaurantRatings = computedRatings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Este GestureDetector cierra el foco (y también el overlay)
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
          child: ListView(
            children: <Widget>[
              buildSearchBar(context),
              SizedBox(height: 20.0),
              buildRestaurantRow('Trending Restaurants', context),
              SizedBox(height: 10.0),
              buildRestaurantList(context),
              SizedBox(height: 10.0),
              buildCategoryRow('Category', context),
              SizedBox(height: 10.0),
              buildCategoryList(context),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  buildRestaurantRow(String restaurant, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "$restaurant",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextButton(
          child: Text(
            "See all (" + restaurants.length.toString() + ")",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return Trending();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  buildCategoryRow(String category, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          "$category",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextButton(
          child: Text(
            "See all (" + categories.length.toString() + ")",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return Categories();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  buildSearchBar(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(10, 5, 10, 0), child: SearchCard());
  }

  buildCategoryList(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 6,
      child: ListView.builder(
        primary: false,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: categories == null ? 0 : categories.take(5).length,
        itemBuilder: (BuildContext context, int index) {
          Map cat = categories[index];

          return GestureDetector(
            onTap: () {
              // Filtrar restaurantes por categoría y navegar a RestaurantCategory
              var filteredRestaurants = restaurants.where((restaurant) {
                return restaurant['foodType'] ==
                    cat['name']; // Filtra por tipo de comida
              }).toList();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantCategory(
                    categoryName: cat["name"], // Nombre de la categoría
                    filteredRestaurants:
                        filteredRestaurants, // Restaurantes filtrados
                  ),
                ),
              );
            },
            child: CategoryItem(
              cat: cat,
            ),
          );
        },
      ),
    );
  }

  bool isRestaurantOpen(String openingTime, String closingTime) {
    // Obtener la hora actual en formato de 24 horas (ej. "09:30")
    DateTime now = DateTime.now();
    String currentTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    // Verificar si la hora actual está dentro del rango de apertura
    return currentTime.compareTo(openingTime) >= 0 &&
        currentTime.compareTo(closingTime) <= 0;
  }

  buildRestaurantList(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.4,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: restaurants == null ? 0 : restaurants.take(6).length,
        itemBuilder: (BuildContext context, int index) {
          Map restaurant = restaurants[index];

          // Obtener la nota media del restaurante
          double rating = restaurantRatings[restaurant["title"]] ?? 0.0;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                // Aquí puedes agregar lo que deseas hacer al tocar el SlideItem
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantScreen(
                      imageUrl: restaurant["img"],
                      restaurantName: restaurant["title"],
                      latitude: double.parse(restaurant["latitude"].toString()),
                      longitude: double.parse(restaurant["longitude"].toString()),
                      address: restaurant["address"],
                      reviews: [] // Agrega las reseñas que necesites
                    ),
                  ),
                );
              },
              child: SlideItem(
                img: restaurant["img"],
                title: restaurant["title"],
                address: restaurant["address"],
                opened: isRestaurantOpen(
                    restaurant["openingTime"], restaurant["closingTime"]),
                rating: rating.toStringAsFixed(1), // Conversión a String
              ),
            ),
          );
        },
      ),
    );
  }
}
