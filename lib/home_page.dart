import 'package:db_practise/data/local/db_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {});
  }

  void deleteNote(int sno) async {
    await dbRef!.deleteNote(sno);
    getNotes();
  }

  void editNote(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BottomSheetView(
          dbRef: dbRef,
          refreshNotes: getNotes,
          isEditMode: true,
          note: note,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Notes'))),
      body:
          allNotes.isNotEmpty
              ? ListView.builder(
                itemCount: allNotes.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    leading: Text(
                      '${allNotes[index][DBHelper.COLUMN_NOTE_SNO]}',
                    ),
                    title: Text(allNotes[index][DBHelper.COLUMN_NOTE_TITLE]),
                    subtitle: Text(allNotes[index][DBHelper.COLUMN_NOTE_DESC]),
                    trailing: SizedBox(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => editNote(allNotes[index]),
                            child: Icon(Icons.edit, color: Colors.blue),
                          ),
                          GestureDetector(
                            onTap:
                                () => deleteNote(
                                  allNotes[index][DBHelper.COLUMN_NOTE_SNO],
                                ),
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
              : Center(child: Text('No Notes yet!!')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return BottomSheetView(dbRef: dbRef, refreshNotes: getNotes);
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class BottomSheetView extends StatefulWidget {
  final DBHelper? dbRef;
  final Function refreshNotes;
  final bool isEditMode;
  final Map<String, dynamic>? note;

  const BottomSheetView({super.key, 
    required this.dbRef,
    required this.refreshNotes,
    this.isEditMode = false,
    this.note,
  });

  @override
  State<StatefulWidget> createState() => _BottomSheetViewState();
}

class _BottomSheetViewState extends State<BottomSheetView> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.note != null) {
      titleController.text = widget.note![DBHelper.COLUMN_NOTE_TITLE];
      descController.text = widget.note![DBHelper.COLUMN_NOTE_DESC];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isEditMode ? 'Edit Note' : 'Add Note',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: "Enter title here",
              labelText: 'Title *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Enter description here",
              labelText: 'Description *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
          SizedBox(height: 15),
          if (errorMsg.isNotEmpty)
            Text(
              errorMsg,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 2, color: Colors.black),
                  ),
                  onPressed: () async {
                    var title = titleController.text.trim();
                    var desc = descController.text.trim();

                    if (title.isNotEmpty && desc.isNotEmpty) {
                      bool check;
                      if (widget.isEditMode) {
                        check = await widget.dbRef!.updateNote(
                          mTitle: title,
                          mDesc: desc,
                          sno: widget.note![DBHelper.COLUMN_NOTE_SNO],
                        );
                      } else {
                        check = await widget.dbRef!.addNote(
                          mTitle: title,
                          mDesc: desc,
                        );
                      }

                      if (check) {
                        widget.refreshNotes();
                        Navigator.pop(context);
                      }
                    } else {
                      setState(() {
                        errorMsg = "* Please fill all required fields";
                      });
                    }
                  },
                  child: Text(widget.isEditMode ? 'Update Note' : 'Add Note'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 2, color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
