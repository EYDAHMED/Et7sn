import '../models/localized_text.dart';
import '../models/meal.dart';

/// Meal recipes built from affordable local ingredients. Amounts are for the
/// base portion; the planner scales them to the user's calorie target.
class MealLibrary {
  MealLibrary._();

  static const List<MealTemplate> all = [
    // ---------------------------------------------------------------- Breakfast
    MealTemplate(
      id: 'b_ful_eggs',
      slot: MealSlot.breakfast,
      name: LocalizedText('Ful medames with eggs', 'فول مدمس بالبيض'),
      howTo: LocalizedText(
        'Warm the ful with a little olive oil, boil or fry the eggs without extra fat, and serve with baladi bread and fresh vegetables.',
        'سخّن الفول مع قليل من زيت الزيتون، واسلق البيض أو اقلِه بدون دهون إضافية، وقدّمه مع العيش البلدي والخضار الطازجة.',
      ),
      items: [
        IngredientAmount('ful', 200),
        IngredientAmount('egg', 2),
        IngredientAmount('baladi', 60),
        IngredientAmount('oil', 5),
        IngredientAmount('veg', 100),
      ],
    ),
    MealTemplate(
      id: 'b_oats_milk',
      slot: MealSlot.breakfast,
      name: LocalizedText(
        'Oats with milk, banana and peanuts',
        'شوفان باللبن والموز والفول السوداني',
      ),
      howTo: LocalizedText(
        'Cook the oats in the milk for 5 minutes, then top with sliced banana and crushed peanuts.',
        'اطبخ الشوفان في اللبن لمدة 5 دقائق ثم زيّنه بشرائح الموز والفول السوداني المجروش.',
      ),
      items: [
        IngredientAmount('oats', 60),
        IngredientAmount('milk', 250),
        IngredientAmount('banana', 100),
        IngredientAmount('peanuts', 15),
      ],
    ),
    MealTemplate(
      id: 'b_cottage_bread',
      slot: MealSlot.breakfast,
      name: LocalizedText(
        'Cottage cheese, egg and baladi bread',
        'جبنة قريش وبيض وعيش بلدي',
      ),
      howTo: LocalizedText(
        'Serve the cottage cheese with a boiled egg, baladi bread, a drizzle of olive oil and a cucumber-tomato salad.',
        'قدّم الجبنة القريش مع بيضة مسلوقة وعيش بلدي وقليل من زيت الزيتون وسلطة خيار وطماطم.',
      ),
      items: [
        IngredientAmount('cottage', 150),
        IngredientAmount('baladi', 80),
        IngredientAmount('veg', 150),
        IngredientAmount('egg', 1),
        IngredientAmount('oil', 5),
      ],
    ),
    MealTemplate(
      id: 'b_omelette',
      slot: MealSlot.breakfast,
      name: LocalizedText(
        'Vegetable omelette with white cheese',
        'عجة خضار بالجبنة البيضاء',
      ),
      howTo: LocalizedText(
        'Whisk the eggs, add chopped vegetables and crumbled white cheese, cook in a non-stick pan with the oil, and eat with baladi bread.',
        'اخفق البيض وأضف الخضار المقطعة والجبنة البيضاء المفتتة، واطهِه في طاسة غير لاصقة مع الزيت، وتناوله مع العيش البلدي.',
      ),
      items: [
        IngredientAmount('egg', 3),
        IngredientAmount('whitecheese', 40),
        IngredientAmount('baladi', 70),
        IngredientAmount('veg', 100),
        IngredientAmount('oil', 5),
      ],
    ),
    MealTemplate(
      id: 'b_yogurt_bowl',
      slot: MealSlot.breakfast,
      name: LocalizedText(
        'Yogurt, cottage cheese and oats bowl',
        'بول زبادي وقريش وشوفان',
      ),
      howTo: LocalizedText(
        'Mix the yogurt with the cottage cheese, then top with raw oats, chopped dates and peanuts.',
        'اخلط الزبادي مع الجبنة القريش، ثم أضف الشوفان والتمر المقطع والفول السوداني.',
      ),
      items: [
        IngredientAmount('yogurt', 250),
        IngredientAmount('cottage', 100),
        IngredientAmount('oats', 40),
        IngredientAmount('dates', 30),
        IngredientAmount('peanuts', 10),
      ],
    ),
    MealTemplate(
      id: 'b_tuna_sandwich',
      slot: MealSlot.breakfast,
      name: LocalizedText(
        'Tuna and egg baladi sandwich',
        'ساندويتش تونة وبيض بالعيش البلدي',
      ),
      howTo: LocalizedText(
        'Mash the tuna with a boiled egg and a little olive oil, stuff it into baladi bread with sliced vegetables.',
        'اهرس التونة مع بيضة مسلوقة وقليل من زيت الزيتون، واحشِ بها العيش البلدي مع شرائح الخضار.',
      ),
      items: [
        IngredientAmount('tuna', 70),
        IngredientAmount('egg', 1),
        IngredientAmount('baladi', 90),
        IngredientAmount('veg', 100),
        IngredientAmount('oil', 6),
      ],
    ),

    // -------------------------------------------------------------------- Lunch
    MealTemplate(
      id: 'l_chicken_rice',
      slot: MealSlot.lunch,
      name: LocalizedText(
        'Grilled chicken, rice and salad',
        'دجاج مشوي مع أرز وسلطة',
      ),
      howTo: LocalizedText(
        'Season the chicken with salt, pepper, cumin and lemon, grill or pan-sear it, and serve with boiled rice and a fresh salad dressed with the oil.',
        'تبّل الدجاج بالملح والفلفل والكمون والليمون، واشوه أو حمّره في الطاسة، وقدّمه مع أرز مسلوق وسلطة طازجة بالزيت.',
      ),
      items: [
        IngredientAmount('chicken', 200),
        IngredientAmount('rice', 80),
        IngredientAmount('veg', 150),
        IngredientAmount('oil', 8),
      ],
    ),
    MealTemplate(
      id: 'l_chicken_potato',
      slot: MealSlot.lunch,
      name: LocalizedText(
        'Chicken with boiled potatoes and vegetables',
        'دجاج مع بطاطس مسلوقة وخضار',
      ),
      howTo: LocalizedText(
        'Bake or grill the seasoned chicken, boil the potatoes, and serve with steamed or fresh vegetables and the oil.',
        'اشوِ الدجاج المتبّل أو اخبزه، واسلق البطاطس، وقدّمه مع خضار مطهوة على البخار أو طازجة والزيت.',
      ),
      items: [
        IngredientAmount('chicken', 200),
        IngredientAmount('potato', 250),
        IngredientAmount('veg', 150),
        IngredientAmount('oil', 8),
      ],
    ),
    MealTemplate(
      id: 'l_lentil_chicken',
      slot: MealSlot.lunch,
      name: LocalizedText(
        'Lentils and rice with chicken',
        'عدس وأرز مع دجاج',
      ),
      howTo: LocalizedText(
        'Mix cooked lentils with cooked rice, top with diced grilled chicken and a fresh vegetable side.',
        'اخلط العدس المطبوخ مع الأرز المطبوخ، وضع فوقه قطع الدجاج المشوي مع طبق خضار طازجة.',
      ),
      items: [
        IngredientAmount('chicken', 100),
        IngredientAmount('lentils', 150),
        IngredientAmount('rice', 60),
        IngredientAmount('veg', 100),
        IngredientAmount('oil', 8),
      ],
    ),
    MealTemplate(
      id: 'l_kofta_rice',
      slot: MealSlot.lunch,
      name: LocalizedText(
        'Lean kofta with rice and salad',
        'كفتة قليلة الدهن مع أرز وسلطة',
      ),
      howTo: LocalizedText(
        'Mix the minced beef with onion and parsley, shape it and grill or bake it; serve with boiled rice and salad.',
        'اخلط اللحم المفروم مع البصل والبقدونس، وشكّله واشوه أو اخبزه، وقدّمه مع أرز مسلوق وسلطة.',
      ),
      items: [
        IngredientAmount('beefmince', 150),
        IngredientAmount('rice', 80),
        IngredientAmount('veg', 150),
        IngredientAmount('oil', 5),
      ],
    ),
    MealTemplate(
      id: 'l_chicken_pasta',
      slot: MealSlot.lunch,
      name: LocalizedText(
        'Chicken pasta with vegetables',
        'مكرونة بالدجاج والخضار',
      ),
      howTo: LocalizedText(
        'Boil the pasta, sauté the diced chicken and vegetables in the oil, then toss together with a little tomato sauce.',
        'اسلق المكرونة، وحمّر الدجاج المقطع والخضار في الزيت، ثم اخلطهم معاً مع قليل من صلصة الطماطم.',
      ),
      items: [
        IngredientAmount('chicken', 180),
        IngredientAmount('pasta', 80),
        IngredientAmount('veg', 120),
        IngredientAmount('oil', 8),
      ],
    ),
    MealTemplate(
      id: 'l_chicken_sweetpotato',
      slot: MealSlot.lunch,
      name: LocalizedText(
        'Chicken with baked sweet potato',
        'دجاج مع بطاطا مشوية',
      ),
      howTo: LocalizedText(
        'Bake the sweet potato until soft, grill the seasoned chicken, and serve with a green salad and the oil.',
        'اشوِ البطاطا حتى تنضج، واشوِ الدجاج المتبّل، وقدّمه مع سلطة خضراء والزيت.',
      ),
      items: [
        IngredientAmount('chicken', 200),
        IngredientAmount('sweetpotato', 250),
        IngredientAmount('veg', 100),
        IngredientAmount('oil', 8),
      ],
    ),
    MealTemplate(
      id: 'l_liver_baladi',
      slot: MealSlot.lunch,
      name: LocalizedText(
        'Sautéed liver with baladi bread and salad',
        'كبدة سوتيه مع عيش بلدي وسلطة',
      ),
      howTo: LocalizedText(
        'Sauté the sliced liver quickly with onion and the oil so it stays tender, and serve with baladi bread and salad.',
        'سوتيه شرائح الكبدة بسرعة مع البصل والزيت لتبقى طرية، وقدّمها مع العيش البلدي والسلطة.',
      ),
      items: [
        IngredientAmount('liver', 150),
        IngredientAmount('baladi', 80),
        IngredientAmount('veg', 150),
        IngredientAmount('oil', 8),
      ],
    ),
    MealTemplate(
      id: 'l_tuna_rice',
      slot: MealSlot.lunch,
      name: LocalizedText(
        'Tuna and rice plate with salad',
        'طبق تونة وأرز مع سلطة',
      ),
      howTo: LocalizedText(
        'Drain the tuna and serve it over boiled rice with a lemony vegetable salad dressed with the oil.',
        'صفّي التونة وقدّمها فوق الأرز المسلوق مع سلطة خضار بالليمون والزيت.',
      ),
      items: [
        IngredientAmount('tuna', 150),
        IngredientAmount('rice', 80),
        IngredientAmount('veg', 150),
        IngredientAmount('oil', 8),
      ],
    ),

    // -------------------------------------------------------------------- Snack
    MealTemplate(
      id: 's_yogurt_banana',
      slot: MealSlot.snack,
      name: LocalizedText(
        'Yogurt with banana and peanuts',
        'زبادي بالموز والفول السوداني',
      ),
      howTo: LocalizedText(
        'Slice the banana into the yogurt and sprinkle with crushed peanuts.',
        'قطّع الموز فوق الزبادي ورشّ الفول السوداني المجروش.',
      ),
      items: [
        IngredientAmount('yogurt', 200),
        IngredientAmount('banana', 100),
        IngredientAmount('peanuts', 10),
      ],
    ),
    MealTemplate(
      id: 's_apple_peanuts',
      slot: MealSlot.snack,
      name: LocalizedText(
        'Apple, peanuts and yogurt',
        'تفاح وفول سوداني وزبادي',
      ),
      howTo: LocalizedText(
        'Eat the sliced apple with a handful of peanuts and a small bowl of yogurt.',
        'تناول التفاح المقطع مع حفنة من الفول السوداني وطبق صغير من الزبادي.',
      ),
      items: [
        IngredientAmount('peanuts', 25),
        IngredientAmount('apple', 150),
        IngredientAmount('yogurt', 100),
      ],
    ),
    MealTemplate(
      id: 's_eggs_cucumber',
      slot: MealSlot.snack,
      name: LocalizedText(
        'Boiled eggs with cucumber and bread',
        'بيض مسلوق مع خيار وعيش',
      ),
      howTo: LocalizedText(
        'Boil the eggs for 9 minutes and eat them with sliced cucumber and a little baladi bread.',
        'اسلق البيض لمدة 9 دقائق وتناوله مع شرائح الخيار وقليل من العيش البلدي.',
      ),
      items: [
        IngredientAmount('egg', 2),
        IngredientAmount('veg', 150),
        IngredientAmount('baladi', 30),
      ],
    ),
    MealTemplate(
      id: 's_cottage_dates',
      slot: MealSlot.snack,
      name: LocalizedText(
        'Cottage cheese with dates',
        'جبنة قريش مع تمر',
      ),
      howTo: LocalizedText(
        'Serve the cottage cheese topped with chopped dates.',
        'قدّم الجبنة القريش مزينة بالتمر المقطع.',
      ),
      items: [
        IngredientAmount('cottage', 120),
        IngredientAmount('dates', 25),
      ],
    ),
    MealTemplate(
      id: 's_oat_shake',
      slot: MealSlot.snack,
      name: LocalizedText(
        'Oat and banana milk shake',
        'ميلك شيك شوفان وموز',
      ),
      howTo: LocalizedText(
        'Blend the milk, oats and banana until smooth and drink it cold.',
        'اخلط اللبن والشوفان والموز في الخلاط حتى يصبح ناعماً واشربه بارداً.',
      ),
      items: [
        IngredientAmount('milk', 250),
        IngredientAmount('oats', 30),
        IngredientAmount('banana', 80),
      ],
    ),
    MealTemplate(
      id: 's_tuna_bread',
      slot: MealSlot.snack,
      name: LocalizedText(
        'Mini tuna bread with vegetables',
        'ساندويتش تونة صغير بالخضار',
      ),
      howTo: LocalizedText(
        'Fill a small piece of baladi bread with drained tuna and sliced vegetables.',
        'احشُ قطعة صغيرة من العيش البلدي بالتونة المصفاة وشرائح الخضار.',
      ),
      items: [
        IngredientAmount('tuna', 60),
        IngredientAmount('baladi', 40),
        IngredientAmount('veg', 50),
      ],
    ),
    MealTemplate(
      id: 's_chickpeas',
      slot: MealSlot.snack,
      name: LocalizedText(
        'Spiced chickpeas with vegetables',
        'حمص مُتبّل مع خضار',
      ),
      howTo: LocalizedText(
        'Warm the chickpeas with cumin, salt and the oil, and serve with chopped fresh vegetables.',
        'سخّن الحمص مع الكمون والملح والزيت، وقدّمه مع خضار طازجة مقطعة.',
      ),
      items: [
        IngredientAmount('chickpeas', 120),
        IngredientAmount('oil', 4),
        IngredientAmount('veg', 50),
      ],
    ),

    // ------------------------------------------------------------------- Dinner
    MealTemplate(
      id: 'd_cottage_dinner',
      slot: MealSlot.dinner,
      name: LocalizedText(
        'Cottage cheese plate with vegetables and bread',
        'طبق جبنة قريش مع خضار وعيش',
      ),
      howTo: LocalizedText(
        'Serve the cottage cheese with a large plate of cucumber, tomato and greens and baladi bread.',
        'قدّم الجبنة القريش مع طبق كبير من الخيار والطماطم والخضرة والعيش البلدي.',
      ),
      items: [
        IngredientAmount('cottage', 200),
        IngredientAmount('baladi', 60),
        IngredientAmount('veg', 200),
      ],
    ),
    MealTemplate(
      id: 'd_tuna_egg_salad',
      slot: MealSlot.dinner,
      name: LocalizedText(
        'Tuna and egg salad with bread',
        'سلطة تونة وبيض مع عيش',
      ),
      howTo: LocalizedText(
        'Toss tuna, boiled eggs and chopped vegetables with olive oil and lemon, and serve with a little baladi bread.',
        'اخلط التونة والبيض المسلوق والخضار المقطعة مع زيت الزيتون والليمون، وقدّمها مع قليل من العيش البلدي.',
      ),
      items: [
        IngredientAmount('tuna', 100),
        IngredientAmount('egg', 2),
        IngredientAmount('veg', 250),
        IngredientAmount('oil', 8),
        IngredientAmount('baladi', 40),
      ],
    ),
    MealTemplate(
      id: 'd_egg_veg_saute',
      slot: MealSlot.dinner,
      name: LocalizedText(
        'Eggs sautéed with vegetables and white cheese',
        'بيض سوتيه بالخضار والجبنة البيضاء',
      ),
      howTo: LocalizedText(
        'Sauté the vegetables in the oil, add the eggs and cook until set, crumble the white cheese on top, and eat with baladi bread.',
        'سوتيه الخضار في الزيت، أضف البيض واتركه حتى يتماسك، وفتّت الجبنة البيضاء فوقه، وتناوله مع العيش البلدي.',
      ),
      items: [
        IngredientAmount('egg', 3),
        IngredientAmount('veg', 200),
        IngredientAmount('baladi', 60),
        IngredientAmount('whitecheese', 30),
        IngredientAmount('oil', 5),
      ],
    ),
    MealTemplate(
      id: 'd_chicken_veg',
      slot: MealSlot.dinner,
      name: LocalizedText(
        'Chicken breast with vegetables and a little rice',
        'صدر دجاج مع خضار وقليل من الأرز',
      ),
      howTo: LocalizedText(
        'Pan-sear the seasoned chicken, steam the vegetables, and serve with a small portion of rice.',
        'حمّر صدر الدجاج المتبّل، واسلق الخضار على البخار، وقدّمه مع كمية صغيرة من الأرز.',
      ),
      items: [
        IngredientAmount('chicken', 150),
        IngredientAmount('veg', 250),
        IngredientAmount('rice', 40),
        IngredientAmount('oil', 8),
      ],
    ),
    MealTemplate(
      id: 'd_lentil_soup',
      slot: MealSlot.dinner,
      name: LocalizedText(
        'Lentil soup with bread and yogurt',
        'شوربة عدس مع عيش وزبادي',
      ),
      howTo: LocalizedText(
        'Blend the cooked lentils into a smooth soup with cumin and the oil; serve with baladi bread and a bowl of yogurt.',
        'اخلط العدس المطبوخ ليصبح شوربة ناعمة مع الكمون والزيت، وقدّمها مع العيش البلدي وطبق زبادي.',
      ),
      items: [
        IngredientAmount('lentils', 250),
        IngredientAmount('baladi', 60),
        IngredientAmount('oil', 5),
        IngredientAmount('yogurt', 100),
      ],
    ),
    MealTemplate(
      id: 'd_yogurt_cottage_bowl',
      slot: MealSlot.dinner,
      name: LocalizedText(
        'Light yogurt, cottage cheese and banana bowl',
        'بول خفيف زبادي وقريش وموز',
      ),
      howTo: LocalizedText(
        'Layer yogurt and cottage cheese in a bowl, then top with sliced banana and oats.',
        'ضع الزبادي والجبنة القريش في طبق، ثم زيّنه بشرائح الموز والشوفان.',
      ),
      items: [
        IngredientAmount('yogurt', 200),
        IngredientAmount('cottage', 100),
        IngredientAmount('banana', 100),
        IngredientAmount('oats', 30),
      ],
    ),
  ];

  static List<MealTemplate> forSlot(MealSlot slot) =>
      all.where((meal) => meal.slot == slot).toList();

  static MealTemplate? byId(String id) {
    for (final meal in all) {
      if (meal.id == id) return meal;
    }
    return null;
  }

  /// Deterministic daily rotation so every day starts with a different meal.
  static MealTemplate defaultFor(MealSlot slot, int dayNumber) {
    final options = forSlot(slot);
    final index = (dayNumber + slot.index * 3) % options.length;
    return options[index];
  }
}
