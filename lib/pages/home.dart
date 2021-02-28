import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State {
  // Chave para o Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Chave para o widget do nome
  final GlobalKey<FormFieldState> _nomeKey = GlobalKey<FormFieldState>();
  // Chave para o widget da idade
  final GlobalKey<FormFieldState> _idadeKey = GlobalKey<FormFieldState>();
  // Chave para o widget do estado civil
  final GlobalKey<FormFieldState> _estcivKey = GlobalKey<FormFieldState>();
  // Chave para o widget da atuacao
  final GlobalKey<FormFieldState> _atuacaoKey = GlobalKey<FormFieldState>();
  // Modelo de dados
  final _user = User();
  // Scopo de foco para a aplicacao
  FocusScopeNode _focusScopeNode;
  // Gerenciar o foco do widget para nome
  FocusNode _nomeFocusNode;
  // Gerenciar o foco do widget para idade
  FocusNode _idadeFocusNode;
  // Orientacao do stepper
  StepperType _stepperType = StepperType.horizontal;
  // Step corrente
  int _current_step = 0;

  @override
  void initState(){
    super.initState();
    _nomeFocusNode = FocusNode();
    _idadeFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_){
      FocusScope.of(context).requestFocus(_nomeFocusNode);
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    _nomeFocusNode.dispose();
    _idadeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hardware = _user.preferencias[User.PreferenciasHardware];
    bool desenvolvimento = _user.preferencias[User.PreferenciasDesenvolvimento];
    bool redes = _user.preferencias[User.PreferenciasRedes];
    _focusScopeNode = FocusScope.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Profile')),
      body: Stepper(
        currentStep: this._current_step,
        type: _stepperType,
        steps: <Step>[
          Step(
            title: Text('Identificacao'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  autovalidate: true,
                  key: _nomeKey,
                  focusNode: _nomeFocusNode,
                  initialValue: _user.nome,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) => _validateNome(value),
                  onChanged: (value) => setState(() => _user.nome = value),
                ),
                TextFormField(
                  autovalidate: true,
                  key: _idadeKey,
                  focusNode: _idadeFocusNode,
                  initialValue:
                    (_user.idade ?? 0)>=18 ? _user.idade.toString() : '',
                  inputFormatters:
                    [WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Idade'),
                  validator: (value) => _validateIdade(value),
                  onChanged: (value) =>
                    setState(() => _user.idade = int.tryParse(value)),
                ),
              ]
            ),
            isActive: true,
          ),
          Step(
            title: Text('Dados'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FormField(
                  autovalidate: true,
                  key: _estcivKey,
                  validator: (value) => _validateEstCiv(value),
                  initialValue: _user.estciv,
                  builder: (FormFieldState<String> state) {
                    return Column(children: <Widget>[
                      ListTile(
                        title: Text('Estado Civil:'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Solteiro'),
                        value: 'solteiro',
                        groupValue: state.value,
                        onChanged: (value) {
                          _user.estciv = value;
                          state.didChange(value);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Casado'),
                        value: 'casado',
                        groupValue: state.value,
                        onChanged: (value) {
                          _user.estciv = value;
                          state.didChange(value);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Outro'),
                        value: 'outro',
                        groupValue: state.value,
                        onChanged: (value) {
                          _user.estciv = value;
                          state.didChange(value);
                        },
                      ),
                      state.hasError ?
                        Text(
                          state.errorText,
                          style: TextStyle(color: Colors.red),
                        )
                      :
                        Container()
                    ]);
                  }
                ),
                Divider(),
                FormField(
                  autovalidate: true,
                  key: _atuacaoKey,
                  validator: (value) => _validateAtuacao(value),
                  initialValue: _user.atuacao,
                  builder: (FormFieldState<String> state) {
                    return Column(children: <Widget>[
                      ListTile(
                        title: Text('Atuacao'),
                        trailing: DropdownButton<String>(
                          value: state.value,
                          icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          onChanged: (value) {
                            _user.atuacao = value;
                            state.didChange(value);
                          },
                          items: _user.Atuacao
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }
                          ).toList(),
                        ),
                      ),
                      state.hasError ?
                        Text(
                          state.errorText,
                          style: TextStyle(color: Colors.red),
                        )
                      :
                        Container()
                    ]);
                  }
                ),
              ]
            ),
            isActive: true,
          ),
          Step(
            title: Text('Preferencias'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FormField(
                  initialValue: _user.newsletter?? false,
                  builder: (FormFieldState<bool> state) {
                    return SwitchListTile(
                      title: const Text('Enviar Newsletter'),
                      value: state.value,
                      onChanged: (value) {
                        _user.newsletter = value;
                        state.didChange(value);
                      },
                    );
                  }
                ),
                Divider(),
                FormField(
                  initialValue: hardware?? false,
                  builder: (FormFieldState<bool> state) {
                    return CheckboxListTile(
                      title: const Text('Hardware'),
                      value: state.value,
                      onChanged: (value) {
                        _user.preferencias[User.PreferenciasHardware] = value = value;
                        state.didChange(value);
                      },
                    );
                  }
                ),
                FormField(
                  initialValue: desenvolvimento?? false,
                  builder: (FormFieldState<bool> state) {
                    return CheckboxListTile(
                      title: const Text('Desenvolvimento'),
                      value: state.value,
                      onChanged: (value) {
                        _user.preferencias[User.PreferenciasDesenvolvimento] = value = value;
                        state.didChange(value);
                      },
                    );
                  }
                ),
                FormField(
                  initialValue: redes?? false,
                  builder: (FormFieldState<bool> state) {
                    return CheckboxListTile(
                      title: const Text('Redes'),
                      value: state.value,
                      onChanged: (value) {
                        _user.preferencias[User.PreferenciasRedes] = value = value;
                        state.didChange(value);
                      }
                    );
                  }
                ),
              ]
            ),
            isActive: true,
          ),
        ],
        onStepTapped: (step) =>
          setState(() => _current_step = step),
        onStepContinue: () {
          setState(() {
            if (_current_step < 2) {
              _current_step = _current_step + 1;
            } else {
              _current_step = 0;
            }
          });
        },
        onStepCancel: () {
          setState(() {
            if (_current_step > 0) {
              _current_step = _current_step - 1;
            } else {
              _current_step = 0;
            }
          });
        },
      ),
      bottomNavigationBar: ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
              onPressed: _switchStepType,
              child: Text('Orientacao')
          ),
          RaisedButton(
              onPressed: () => _user.show(),
              child: Text('Exibir')
          ),
          RaisedButton(
              onPressed: () => _submit(),
              child: Text('Save')
          ),
        ],
      ),
    );
  }

  //
  // Validar o nome
  //
  String _validateNome(String value) {
    String ret = null;
    value = value.trim();
    if ( value.isEmpty )
      ret = "Enter com o nome";
    return ret;
  }

  //
  // Validar a idade
  //
  String _validateIdade(String value) {
    String ret = null;
    value = value.trim();
    if ( value.isEmpty )
      ret = "Idade e obrigatoria";
    else {
      int _valueAsInteger = int.tryParse(value);
      if ( _valueAsInteger == null )
        ret = "Valor invalido";
      else {
        if ( _valueAsInteger < 18 )
          ret = "Valor deve ser maior que 18";
      }
    }
    return ret;
  }

  //
  // Validar o estado civil
  //
  String _validateEstCiv(String value) {
    String ret = null;
    if ( value == null )
      ret = "Enter com o estado civil";
    return ret;
  }

  //
  // Validar a atuacao
  //
  String _validateAtuacao(String value) {
    String ret = null;
    if ( value == null )
      ret = "Enter com o estado civil";
    return ret;
  }

  //
  // Altera a orientacao do stepper
  //
  _switchStepType() {
    setState(() =>
    _stepperType == StepperType.horizontal ?
      _stepperType = StepperType.vertical
    :
      _stepperType = StepperType.horizontal);
  }

  //
  // Verifica e salva os dados do formulario
  //
  _submit() {
    if ( _validateNome(_user.nome)==null ) {
      if ( _validateIdade(_user.idade.toString())==null ) {
        if ( _validateEstCiv(_user.estciv)==null ) {
          if ( _validateAtuacao(_user.atuacao)==null ) {
            _user.show();
            _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text('Submitting form')));
          } else {
            setState(() => _current_step = 1);
          }
        } else {
          setState(() => _current_step = 1);
        }
      } else {
        setState(() => _current_step = 0);
        _focusScopeNode.requestFocus(_idadeFocusNode);
      }
    } else {
      setState(() => _current_step = 0);
      _focusScopeNode.requestFocus(_nomeFocusNode);
    }
  }
}
