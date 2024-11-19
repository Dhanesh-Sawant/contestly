import 'package:contestify/Credentials/supabase_credentials.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final Map<String, String> _questions = {
    "A widget on the Home screen of the mobile, showing the most recent upcoming contests": "A",
    "Detailed stats of the attempted contests": "B",
    "Able to add short notes for the question after upsolving it, so that it is easy for revision.": "C",
    "Displaying one random question you solved previously.": "D",
    "Daily blogs, interview experiences etc.": "E",
    "Show daily problems of Leetcode and GeeksforGeeks.": "F"
  };

  final Map<String, bool> _selectedFeatures = {};
  final TextEditingController _customFeedbackController = TextEditingController();

  bool chosen = false;
  late Future<void> _choicesFuture;

  Future<void> choices() async {
    try {
      final currentUserEmail = SupabaseCredentials.supabaseClient.auth.currentUser?.email;
      if (currentUserEmail != null) {
        final response = await SupabaseCredentials.supabaseClient
            .from('choices')
            .select('email')
            .eq('email', currentUserEmail);

        if (response.isNotEmpty) {
          setState(() {
            chosen = true;
          });
        } else {
          setState(() {
            chosen = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching choices: $e');
      setState(() {
        chosen = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    for (String question in _questions.keys) {
      _selectedFeatures[question] = false;
    }
    _choicesFuture = choices();
  }

  Future<void> _handleSubmit() async {
    final selectedFeatures = _selectedFeatures.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    print("Selected Features: $selectedFeatures");

    final customFeedback = _customFeedbackController.text;

    // Store custom feedback if provided
    if (customFeedback.isNotEmpty) {
      final data = {
        'email': SupabaseCredentials.supabaseClient.auth.currentUser?.email,
        'feedback': customFeedback,
      };
      await SupabaseCredentials.supabaseClient.from('custom_feedback').insert(data);
    }

    // Update feedback counts
    List<String> x = [];
    for (String question in selectedFeatures) {
      String code = _questions[question]!;
      x.add(code);
    }

    await _updateFeedbackCount(x);

    print('Selected Features: $selectedFeatures');
    print('Custom Feedback: $customFeedback');

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text('Thank you for your feedback!', style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      },
    );

    // Close the dialog and pop the screen after a delay
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FeedbackScreen()));// Navigate back
    });
  }

  Future<void> _updateFeedbackCount(List<String> code) async {

    final response = await SupabaseCredentials.supabaseClient
        .from('feedback_count')
        .select()
        .single();

    final newdata = {
      'temp' : 'TEMP',
      'A' : response['A'],
      'B' : response['B'],
      'C' : response['C'],
      'D' : response['D'],
      'E' : response['E'],
      'F' : response['F']
    };

    for(String s in code){
      newdata[s] = newdata[s] + 1;
    }

    await SupabaseCredentials.supabaseClient.from('feedback_count').upsert(newdata,onConflict: 'temp');
    if(!chosen) {
      await SupabaseCredentials.supabaseClient.from('choices').insert({
        'email': SupabaseCredentials.supabaseClient.auth.currentUser?.email
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Features Request'),
      ),
      body: FutureBuilder(
        future: _choicesFuture,
    builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }else { return SingleChildScrollView(
            child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
            children: [
              !chosen ? Column(
                children: _questions.keys.map((question) {
                  return CheckboxListTile(
                    title: Text(question),
                    value: _selectedFeatures[question],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedFeatures[question] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ) : Text(''),
              SizedBox(height: 16),
              TextField(
                controller: _customFeedbackController,
                decoration: InputDecoration(
                  labelText: 'Custom Feedback',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text('Submit'),
              ),
            ],
                    ),
                  ),
          );}}
      )
    );
  }
}
