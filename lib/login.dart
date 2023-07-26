import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  bool showPassword = false;
  bool atlasFolderValid = false;

  final TextEditingController username = TextEditingController(text: "");
  final TextEditingController password = TextEditingController(text: "");
  final TextEditingController atlasFolder = TextEditingController(text: "");
  final TextEditingController evosServer = TextEditingController(text: "");
  String errorMessage = "";

  final String configPath =
      "./Games/Atlas Reactor/Live/Config/AtlasReactorConfig.json";
  final String execPath = "./Games/Atlas Reactor/Live/Win64/AtlasReactor.exe";

  Map atlasConfigMap = {
    "PlatformUserName": "",
    "PlatformPassword": "",
    "DirectoryServerAddress": "",
    "EnableLogging": true,
    "MinConsoleLogLevel": "Everything",
    "MinFileLogLevel": "Everything",
    "DevMode": false,
    "AutoLaunchTutorial": false,
    "PlatformConfig": {"AllowRequestTickets": true}
  };

  setAtlasFolder() async {
    String? folder = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "Pick Atlas Folder");

    if (folder == null) {
      return;
    } else {
      atlasFolder.text = folder;
    }
    var execAbsPath = p.join(folder, execPath);

    if (!File(execAbsPath).existsSync()) {
      setState(() {
        errorMessage = "Invalid Folder";
        atlasFolderValid = false;
      });
    } else {
      var configAbsPath = p.join(folder, configPath);
      var conf = File(configAbsPath);

      try {
        atlasConfigMap = jsonDecode(await conf.readAsString());
      } on PathNotFoundException {
        conf.create();
        conf.writeAsString(jsonEncode(atlasConfigMap));
      }

      setState(() {
        atlasFolderValid = true;
        username.text = atlasConfigMap["PlatformUserName"];
        password.text = atlasConfigMap["PlatformPassword"];
        evosServer.text = atlasConfigMap["DirectoryServerAddress"];
      });
    }
  }

  startAtlas() async {
    atlasConfigMap["PlatformUserName"] = username.text;
    atlasConfigMap["PlatformPassword"] = password.text;
    atlasConfigMap["DirectoryServerAddress"] = evosServer.text;

    var configAbsPath = p.join(atlasFolder.text, configPath);
    var execAbsPath = p.join(atlasFolder.text, execPath);

    await File(configAbsPath).writeAsString(jsonEncode(atlasConfigMap));
    Process.start(execAbsPath, []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            TextField(
              controller: atlasFolder,
              readOnly: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Atlas Folder (steamapps/common/Atlas Reactor/)"),
              onTap: setAtlasFolder,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: evosServer,
              enabled: atlasFolderValid,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "EvoS Server Url"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: username,
              enabled: atlasFolderValid,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Username"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: password,
                  obscureText: !showPassword,
                  enabled: atlasFolderValid,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Password"),
                )),
                Checkbox(
                  value: showPassword,
                  onChanged: (val) => {
                    setState(() {
                      showPassword = val!;
                    })
                  },
                  tristate: false,
                )
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton(
                onPressed: startAtlas,
                child: const Text(
                  "Start",
                  style: TextStyle(fontSize: 20),
                ))
          ],
        ),
      ),
    );
  }
}
