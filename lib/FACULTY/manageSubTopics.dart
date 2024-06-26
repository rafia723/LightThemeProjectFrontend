
import 'package:biit_directors_dashbooard/API/api.dart';
import 'package:biit_directors_dashbooard/customWidgets.dart';
import 'package:flutter/material.dart';


class ManageSubTopics extends StatefulWidget {
  final String coursename;
  final int cid;
  final int tid;
  final String topicName;
  const ManageSubTopics({
    Key? key,
    required this.coursename,
    required this.cid,
    required this.tid,
    required this.topicName,
  }) : super(key: key);

  @override
  State<ManageSubTopics> createState() => _ManageSubTopicsState();
}

class _ManageSubTopicsState extends State<ManageSubTopics> {
  List<dynamic> topiclist = [];
  List<dynamic> subtopiclist = [];
  int? selectedtopicId;
  String? selectedtopicDD;
  TextEditingController subTopicController = TextEditingController();
  bool isUpdateMode = false;
  int? selectedSubTopicID; //in update mode

 Future<void> loadTopicofCourse(int cid) async {
    try {
      topiclist=await APIHandler().loadTopics(cid);
        setState(() {});
      } 
     catch (e) {
      if(mounted){
        showErrorDialog(context, e.toString());
      }
    }
  }
 

   Future<void> loadSubTopicOfTopic(int tid) async {
    try {
      subtopiclist=await APIHandler().loadSubTopic(tid);
        setState(() {});
      } 
     catch (e) {
      if(mounted){
        showErrorDialog(context, e.toString());
      }
    }
  }

  Future<void> addSubTopic() async {
    try {
      // Get the topic text from the text field
      String subTopicText = subTopicController.text.trim();

      // Validate if topic text is not empty
      if (subTopicText.isEmpty) {
        if(mounted){
          showErrorDialog(context, 'Please enter a  sub-topic.');
        }
        return;
      }
      int code = await APIHandler().addSubTopic(subTopicText, selectedtopicId!);
      if (code == 200) {

         if(mounted){
          showSuccesDialog(context, 'Sub-Topic added.');
        }
        // Clear the text field
        subTopicController.clear();
          setState(() {
         
          loadSubTopicOfTopic(selectedtopicId!);
        });
      } else {
        if(mounted){
          showErrorDialog(context, 'Failed to add Sub-Topic. Please try again later.');
        }
      
      }
    } catch (e) {
      // Handle errors
       if(mounted){
          showErrorDialog(context, e.toString());
        }
    }
  }

  @override
  void initState() {
    super.initState();
    selectedtopicId = widget.tid;
    loadTopicofCourse(widget.cid);
    loadSubTopicOfTopic(widget.tid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context: context, title: 'Sub-Topics'),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Course',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '    ${widget.coursename}',
                    style: const TextStyle( fontSize: 16,fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Topic',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(26, 112, 106, 106),
                          borderRadius: BorderRadius.circular(
                              5), // Optional: Add border radius
                        ),
                        child: DropdownButton<String>(
                          hint: Text(widget.topicName),
                          isExpanded: true,
                          elevation: 9,
                          value: selectedtopicDD,
                          items: topiclist.map((e) {
                            return DropdownMenuItem<String>(
                              value: e['t_id'].toString(),
                              onTap: () {
                                setState(() {
                                  selectedtopicId = e['t_id'];
                                  subTopicController.clear();
                                  isUpdateMode = false;
                                });
                              },
                              child: Text(
                                e['t_name'],
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedtopicDD = newValue!;
                              loadSubTopicOfTopic(selectedtopicId!);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sub Topic',
                    style: TextStyle(
           
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        focusColor: Colors.black,
                        fillColor: Colors.white70,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                      ),
                      controller: subTopicController,
                      maxLines: 1,
                    ),
                  ),
                  Center(
                      child: customElevatedButton(
                          onPressed: () async {
                            if (isUpdateMode == false) {
                              addSubTopic();
                            } else {
                              int stid = selectedSubTopicID!;
                              Map<String, dynamic> stData = {
                                "st_name": subTopicController.text,
                                "t_id": selectedtopicId,
                              };

                              int code = await APIHandler()
                                  .updateSubTopic(stid, stData);
                              if (code == 200) {
                                  if(mounted){
                                  showSuccesDialog(context, 'Sub-topic updated');
                                }
                             
                                subTopicController.clear();
                                setState(() {
                                  loadSubTopicOfTopic(selectedtopicId!);
                                  isUpdateMode = false;
                                });
                              } else {
                                if(mounted){
                                  showErrorDialog(context, 'Error updating Sub-topic');
                                }
                                
                              }
                            }
                          },
                          buttonText: isUpdateMode ? 'Update' : 'Add')),
                  Expanded(
                    child: ListView.builder(
                        itemCount: subtopiclist.length,
                        itemBuilder: (context, index) {
                          return Card(
                               elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              color: Colors.white.withOpacity(0.8),
                              // color: Colors.transparent,
                              child: ListTile(
                                  title: Text(
                                    subtopiclist[index]['st_name'],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            // Find the index of the item with matching t_id
                                            int indexx = topiclist.indexWhere(
                                                (e) =>
                                                    e['t_id'] ==
                                                    subtopiclist[index]
                                                        ['t_id']);
                                            setState(() {
                                              selectedSubTopicID =
                                                  subtopiclist[index]['st_id'];
                                            });
                                            if (indexx != -1) {
                                              // If item with matching c_id is found
                                              setState(() {
                                                // Set selectedCourseId
                                                selectedtopicId =
                                                    topiclist[indexx]['t_id'];
                                                // Set selectedCourse based on index
                                                // selectedCourse =
                                                //     clist[indexx]['c_code'];
                                                // Toggle the update mode
                                                isUpdateMode = true;
                                              });
                                            }
                                            // Set CLO text to desc TextFormField
                                            subTopicController.text =
                                                subtopiclist[index]['st_name'];

                                            setState(() {});
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                          )),
                                    ],
                                  )));
                        }),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
