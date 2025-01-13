import 'package:flutter/material.dart';
import 'package:flutter_foodybite/util/categories.dart';
import 'package:flutter_foodybite/screens/restaurants_category.dart';
import 'package:flutter_foodybite/util/restaurants.dart';

// Asegúrate de que la importación esté bien

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories'.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true, // Centra el texto
      ),
      body: Padding(
        padding: EdgeInsets.all(5.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: List.generate(
            categories.length,
            (index) {
              var cat = categories[index];
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
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Stack(
                      children: <Widget>[
                        Image.asset(
                          cat["img"],
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.height,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.2, 0.7],
                              colors: [
                                cat['color1'],
                                cat['color2'],
                              ],
                            ),
                          ),
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.height,
                        ),
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.height,
                            padding: const EdgeInsets.all(1),
                            child: Center(
                              child: Text(
                                cat["name"],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
