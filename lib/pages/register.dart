import 'dart:collection';
import 'dart:convert';

import 'package:bengkelan/lib/db/handler.dart';
import 'package:bengkelan/lib/widget_theme.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // User identification stuffs
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _phonePrefixController = TextEditingController();

  // Address
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();

  // Cred stuffs
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dropdowns helper variable
  final HashMap<int, String> _provinces = HashMap(); // provinceID, proviceName
  final HashMap<int, HashMap<int, String>> _regions =
      HashMap(); // provinceID -> regionID, regionName

  int _selectedProvince = 1;
  int _selectedRegions = 1;

  @override
  @mustCallSuper
  void initState() {
    DatabaseHandler.get()
        .getAll(table: "province", fields: "id, provinceName")
        .then((rows) {
          for (var value in rows) {
            print("Provinces: ");
            print(value);
            Map<String, dynamic> row = value as Map<String, dynamic>;

            _provinces.putIfAbsent(row["id"], () {
              return row["provinceName"];
            });
          }
        });

    DatabaseHandler.get()
        .getAll(table: "region", fields: "id, province_id, name")
        .then((rows) {
          for (var value in rows) {
            print("Regions: ");
            print(value);

            Map<String, dynamic> row = value as Map<String, dynamic>;

            _regions.putIfAbsent(row["province_id"], () {
              return HashMap();
            });

            _regions[row["province_id"]]!.putIfAbsent(row["id"], () {
              return row["name"];
            });
          }
          setState(
            () {},
          ); //This is to force Province and Region dropdown button to show up lists of available provinces and regions. Very hacky I know
        });
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Work around on error showing up before state intialization is finished
    if (_provinces.isEmpty || _regions.isEmpty) {
      return Scaffold();
    }

    return Scaffold(
      body: Container(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 32, vertical: 60),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "Register",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 18),
                ),
                Expanded(
                  // Customer name BEGIN
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text("First Name (required)"),
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your first name";
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Middle Name"),
                            Expanded(
                              child: TextFormField(
                                controller: _middleNameController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text("Last  Name (required)"),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your first name";
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ), // Customer Name END
                Expanded(
                  // Contact BEGIN
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            const Text("Email"),
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text("Phone Prefix"),
                            Expanded(
                              child: TextFormField(
                                controller: _phonePrefixController,
                                validator: (value) {
                                  if (_phoneNumberController.text.isNotEmpty &&
                                      (value == null || value.isEmpty)) {
                                    return "Please enter your phone prefix";
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            const Text("Phone Number"),
                            Expanded(
                              child: TextFormField(
                                controller: _phoneNumberController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ), // Contact END
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Text("Province"),
                            DropdownButtonFormField(
                              value: _selectedProvince,
                              items: _provinces.keys.map((id) {
                                return DropdownMenuItem(
                                  value: id,
                                  child: Text(_provinces[id]!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedProvince = value!;
                                  _selectedRegions =
                                      _regions[_selectedProvince]!.keys.first;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            const Text("Regions"),
                            DropdownButtonFormField(
                              value: _selectedRegions,
                              items: _regions[_selectedProvince]!.keys.map((
                                id,
                              ) {
                                return DropdownMenuItem(
                                  value: id,
                                  child: Text(
                                    _regions[_selectedProvince]![id]!,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRegions = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            const Text("Address"),
                            TextFormField(
                              controller: _addressController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your address";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            const Text("Zip Code"),
                            TextFormField(
                              controller: _zipCodeController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your zip code";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Text("Username"),
                Expanded(
                  child: TextFormField(
                    controller: _usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your username";
                      }

                      return null;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 8),
                ),
                const Text("Password"),
                Expanded(
                  child: TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }

                      return null;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsetsGeometry.symmetric(vertical: 18),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: CancelButtonColor(),
                        ),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _handleRegistration();
                            Navigator.of(context).pop();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: RegisterButtonColor(),
                        ),
                        child: const Text("Register"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    var pwBytes = utf8.encode(_passwordController.text);
    var pwDigest = sha256.convert(pwBytes);

    int addressId = 0;
    int userId = 0;

    // Async chanining to synchornous operations is some cursed stuffs lmao
    await DatabaseHandler.get().insert(
      table: "address",
      insertData: {
        "region_id": _selectedRegions,
        "full_address": _addressController.text,
        "zip_code": int.parse(_zipCodeController.text),
      },
    );

    await DatabaseHandler.get()
        .getOne(
          table: "address",
          fields: "id",
          where: {
            "full_address": _addressController.text,
            "zip_code": int.parse(_zipCodeController.text),
          },
        )
        .then((value) {
          addressId = value["id"];
        });

    await DatabaseHandler.get().insert(
      table: "user",
      insertData: {
        "first_name": _firstNameController.text,
        "middle_name": _middleNameController.text,
        "last_name": _lastNameController.text,
        "email": _emailController.text,
        "phone_number": _phoneNumberController.text,
        "phone_prefix": int.parse(_phonePrefixController.text),
        "address_id": addressId,
      },
    );

    await DatabaseHandler.get()
        .getOne(
          table: "user",
          fields: "id",
          where: {
            "first_name": _firstNameController.text,
            "address_id": addressId,
          },
        )
        .then((value) {
          userId = value["id"];
        });

    await DatabaseHandler.get()
        .insert(
          table: "user_credential",
          insertData: {
            "id": userId,
            "username": _usernameController.text,
            "password": pwDigest.toString(),
          },
        )
        .timeout(
          Duration(seconds: 5),
          onTimeout: () async {
            await DatabaseHandler.get().delete(
              table: "user",
              where: {"id": userId},
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Failed registering due to internal app error. Reasons: Failed to add user credential.",
                ),
              ),
            );

            return BigInt.zero;
          },
        );
  }
}
