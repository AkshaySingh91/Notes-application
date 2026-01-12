import 'package:flutter/material.dart';
import 'package:my_learning_app/constants/tagsMaterialIconsList.dart';
import 'package:my_learning_app/services/crud/noteService.dart';
import 'package:my_learning_app/services/crud/tagService.dart';
import 'package:my_learning_app/utilities/AppColors.dart';
import 'package:my_learning_app/utilities/ShowErrorDialog.dart';

class Searchandfilter extends StatefulWidget {
  const Searchandfilter({super.key});

  @override
  State<Searchandfilter> createState() => _SearchandfilterState();
}

class _SearchandfilterState extends State<Searchandfilter>
    with SingleTickerProviderStateMixin {
  final _noteTagService = TagService();
  final _noteService = NoteService();

  late final AnimationController _pulseController;
  late Animation _pulseAnimation;

  Map<String, dynamic>? selection;

  final TextEditingController _searchController = TextEditingController();
  bool isBottomSheetOpen = false;
  List<NoteTag> userTags = [];

  @override
  void initState() {
    _getAllNoteTags();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _pulseAnimation = Tween<double>(
      begin: 5,
      end: 6,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeIn));
    _pulseController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _getAllNoteTags() async {
    try {
      List<NoteTag> tags = await _noteTagService.getAllNoteTags();
      setState(() {
        userTags = tags;
      });
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  Future<void> _filterAndSortNotes() async {
    try {
      final result = await _openFilterAndSortSheet(selection: selection);

      if (result != null) {
        _noteService.filterAndSortNotes(selection: result);
      }
      // we have to update state for persistent ui
      setState(() {
        selection = result;
      });
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.directional(
        start: 14,
        end: 14,
        top: 14,
        bottom: 38,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color.fromARGB(248, 253, 239, 216), // Solid color at top
            Color.fromARGB(
              248,
              246,
              234,
              214,
            ).withOpacity(0.0), // Fully transparent at bottom],
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 0.2,
                    offset: Offset(0, 4), // x, y
                  ),
                ],
              ),
              child: TextFormField(
                controller: _searchController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 28,
                    color: Colors.black87,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: const Color.fromARGB(255, 255, 126, 62),
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: "Search",
                  hintStyle: TextStyle(fontSize: 18, color: Colors.blueGrey),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            children: [
              ElevatedButton(
                onPressed: _filterAndSortNotes,
                style: ElevatedButton.styleFrom(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.2),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(width: 0, color: Colors.transparent),
                  ),
                ),
                child: const Icon(
                  Icons.filter_alt_rounded,
                  size: 28,
                  color: Colors.black54,
                ),
              ),
              if (selection != null && selection!['filterby'].isNotEmpty)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Positioned(
                      top: 0,
                      right: 0,
                      child: Transform.scale(
                        scale: 1 + (_pulseController.value * 0.5),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrange.withOpacity(
                                  0.6 * (1 - _pulseController.value),
                                ),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _openFilterAndSortSheet({
    required Map<String, dynamic>? selection,
  }) async {
    Map<String, dynamic> localSelection =
        selection ??
        {"sortby": "createdat", "filterby": <int>[], "sortorder": 'asc'};

    final result =
        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: true,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setLocalState) {
                return DraggableScrollableSheet(
                  maxChildSize: 0.9,
                  minChildSize: 0.4,
                  initialChildSize: 0.6,
                  expand: false,
                  builder: (context, scrollController) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // dragger
                          const SizedBox(height: 8),
                          Container(
                            width: 30,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 235, 235, 237),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // header
                          Row(
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Center(
                                      child: const Text(
                                        "Filter",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: -16,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, {
                                            "sortby": "createdat",
                                            "filterby": <int>[],
                                            "sortorder": 'asc',
                                          });
                                        },
                                        child: const Text(
                                          "Reset",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                            color: Color.fromARGB(
                                              255,
                                              51,
                                              51,
                                              51,
                                            ),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          //sorting
                          const SizedBox(height: 8),
                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Sort By",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black38,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // sort order
                                    GestureDetector(
                                      onTap: () {
                                        setLocalState(() {
                                          final isAsc =
                                              localSelection["sortorder"] ==
                                              "asc";
                                          localSelection["sortorder"] = isAsc
                                              ? "desc"
                                              : "asc";
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              spreadRadius: 0.2,
                                              offset: Offset(0, 4), // x, y
                                            ),
                                          ],
                                          color: Colors.white70,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                              56,
                                              0,
                                              0,
                                              0,
                                            ),
                                            width: 0,
                                          ),
                                        ),
                                        child: Icon(
                                          localSelection["sortorder"] == "asc"
                                              ? Icons.arrow_upward_rounded
                                              : Icons.arrow_downward,
                                          size: 24,
                                          color: AppColors.primaryVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setLocalState(() {
                                          localSelection["sortby"] =
                                              "createdat";
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width:
                                                localSelection["sortby"] ==
                                                    "createdat"
                                                ? 0
                                                : 2,
                                            color:
                                                localSelection["sortby"] ==
                                                    "createdat"
                                                ? AppColors.primary
                                                : Colors.transparent,
                                          ),
                                          borderRadius:
                                              BorderRadiusGeometry.circular(18),
                                        ),
                                        elevation: 2,
                                        backgroundColor:
                                            localSelection["sortby"] ==
                                                "createdat"
                                            ? AppColors.primary
                                            : const Color.fromARGB(
                                                179,
                                                255,
                                                168,
                                                7,
                                              ),
                                      ),
                                      child: const Text(
                                        "Created At",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(
                                            255,
                                            121,
                                            59,
                                            18,
                                          ),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {
                                        setLocalState(() {
                                          localSelection["sortby"] =
                                              "updatedat";
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width:
                                                localSelection["sortby"] ==
                                                    "updatedat"
                                                ? 0
                                                : 2,
                                            color:
                                                localSelection["sortby"] ==
                                                    "updatedat"
                                                ? AppColors.primary
                                                : Colors.transparent,
                                          ),
                                          borderRadius:
                                              BorderRadiusGeometry.circular(18),
                                        ),
                                        elevation: 2,
                                        backgroundColor:
                                            localSelection["sortby"] ==
                                                "updatedat"
                                            ? AppColors.primary
                                            : const Color.fromARGB(
                                                179,
                                                255,
                                                168,
                                                7,
                                              ),
                                      ),
                                      child: const Text(
                                        "Updated At",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(
                                            255,
                                            121,
                                            59,
                                            18,
                                          ),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {
                                        setLocalState(() {
                                          localSelection["sortby"] = "priority";
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width:
                                                localSelection["sortby"] ==
                                                    "priority"
                                                ? 0
                                                : 2,
                                            color:
                                                localSelection["sortby"] ==
                                                    "priority"
                                                ? AppColors.primary
                                                : Colors.transparent,
                                          ),
                                          borderRadius:
                                              BorderRadiusGeometry.circular(18),
                                        ),
                                        elevation: 2,
                                        backgroundColor:
                                            localSelection["sortby"] ==
                                                "priority"
                                            ? AppColors.primary
                                            : const Color.fromARGB(
                                                179,
                                                255,
                                                168,
                                                7,
                                              ),
                                      ),
                                      child: const Text(
                                        "Priority",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(
                                            255,
                                            121,
                                            59,
                                            18,
                                          ),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 2,
                            color: const Color.fromARGB(255, 241, 241, 241),
                            radius: BorderRadius.circular(2),
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Filter By",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black38,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          mainAxisSpacing: 16,
                                          crossAxisSpacing: 16,
                                        ),
                                    itemCount: userTags.length,
                                    itemBuilder: (context, index) {
                                      final currentTag = userTags[index];
                                      final iconData = TagsMaterialIconsList
                                          .tagsIconsList
                                          .firstWhere(
                                            (element) =>
                                                element.keys.first ==
                                                currentTag.materialIconName,
                                            orElse: () => {
                                              'default': Icons.label,
                                            },
                                          )
                                          .values
                                          .first;

                                      bool isCurrentItemSeleted =
                                          localSelection["filterby"].any(
                                            (tagId) =>
                                                tagId == currentTag.tagId,
                                          );

                                      return InkWell(
                                        onTap: () {
                                          if (isCurrentItemSeleted) {
                                            setLocalState(() {
                                              localSelection["filterby"]
                                                  .removeWhere(
                                                    (tagId) =>
                                                        tagId ==
                                                        userTags[index].tagId,
                                                  );
                                            });
                                          } else {
                                            setLocalState(() {
                                              localSelection["filterby"].add(
                                                userTags[index].tagId,
                                              );
                                            });
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isCurrentItemSeleted
                                                ? AppColors.title.withOpacity(
                                                    0.1,
                                                  )
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isCurrentItemSeleted
                                                  ? AppColors.title
                                                  : Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                iconData,
                                                color: isCurrentItemSeleted
                                                    ? AppColors.title
                                                    : AppColors.body,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                currentTag.customTagName,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isCurrentItemSeleted
                                                      ? AppColors.title
                                                      : AppColors.body,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, localSelection);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        255,
                                        129,
                                        3,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      "Apply Fitler",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ) ??
        selection;
    return result;
  }
}
