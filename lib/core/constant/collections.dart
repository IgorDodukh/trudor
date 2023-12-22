import 'package:atlas_icons/atlas_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const productType = ['New', 'Used'];

enum ProductStatus { active, inactive, draft }

// add const with mapping between category name and CupertinoIcons
const categoryIcon = {
  'Electronics': CupertinoIcons.desktopcomputer,
  'Transport': CupertinoIcons.car_detailed,
  'Fashion': Atlas.scarf_fashion_thin,
  'Kids': Icons.child_friendly_outlined,
  'House & Garden': CupertinoIcons.tree,
  'Real Estate': CupertinoIcons.house,
  'Entertainment': CupertinoIcons.gamecontroller,
  'Sport': CupertinoIcons.sportscourt,
  'Pets': CupertinoIcons.paw,
  'Free': CupertinoIcons.gift,
  'Other': CupertinoIcons.question,
  'Cars': CupertinoIcons.car_detailed,
  'Motorcycles': Icons.motorcycle,
  'Boats': Icons.directions_boat_filled_outlined,
  'Campers': Atlas.caravan,
  'Parts & Accessories': CupertinoIcons.wrench,

  // add subcategories with icons for House & Garden
  'Furniture': CupertinoIcons.bed_double,
  'Kitchen': Atlas.microwave,
  'Garden': CupertinoIcons.leaf_arrow_circlepath,
  'Tools': CupertinoIcons.wrench,
  'Repair': CupertinoIcons.hammer,

  // add subcategories with icons for Fashion
  'Clothes': Atlas.clothing_hanger,
  'Shoes': Atlas.sneakers_footware_shoe,
  'Accessories': CupertinoIcons.bag,
  'Jewelry': Atlas.diamond_ring,
  'Watches': Icons.watch,
  'Bags': CupertinoIcons.bag,

  // add subcategories with icons for Electronics
  'Computers': CupertinoIcons.desktopcomputer,
  'Laptops': CupertinoIcons.device_laptop,
  'Phones': CupertinoIcons.phone,
  'TV': CupertinoIcons.tv,
  'Audio': CupertinoIcons.headphones,
  'Photo & Video': CupertinoIcons.camera,
  'Video Games': CupertinoIcons.gamecontroller,

  // add subcategories with icons for Sport
  'Bicycles': Atlas.bicycle,
  'Fitness': Icons.fitness_center,
  'Winter Sports': CupertinoIcons.snow,
  'Water Sports': CupertinoIcons.drop,
  'Hunting & Fishing': CupertinoIcons.sportscourt,

  // add subcategories with icons for Pets
  'Dogs': CupertinoIcons.paw,
  'Cats': CupertinoIcons.paw,
  'Fish': Icons.water,
  'Birds': Atlas.dove,
  'Other Pets': CupertinoIcons.paw,

  // add subcategories with icons for Entertainment
  'Books': CupertinoIcons.book,
  'Board Games': CupertinoIcons.gamecontroller,
  'Musical Instruments': CupertinoIcons.music_note_2,
  'Movies & Music': CupertinoIcons.film,
  'Tickets': CupertinoIcons.ticket,
  'Collectibles': CupertinoIcons.gift,

};

// add list of shopping categories for ecommerce app