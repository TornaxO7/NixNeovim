{ lib, customOptions, config }:

let
  inherit (lib)
    elem
    stringAsChars
    stringToCharacters
    toLower;
  inherit (builtins) head;

  # takes camalCase string and converts it to snake_case
  camelToSnake = string:
    let

      isChar  = x:
        elem x lowerCaseLetters || elem x upperCaseLetters;

      upperCaseLetters = [ "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" ];
      lowerCaseLetters = [ "a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z" ];

      isUpper = x: elem x upperCaseLetters; # check if x is uppercase

      # exchange any uppercase x letter by '_x', leave lower case letters
      exchangeIfUpper = (x:
          if isUpper x then
            "_${toLower x}"
          else
            x
        );

      chars = stringToCharacters string;

      firstChar = head chars;

    # in if !isUpper (head chars)  then
    #   stringAsChars exchangeIfUpper string
    # else
    #   string;
    in if isUpper firstChar then # do nothing if first char is uppercase
      string
    else if ! isChar firstChar then # do nothing first char is no alphabetical letter
      string
    else
      stringAsChars exchangeIfUpper string;

  repeatChar = char: n:
    if n == 0 then
      ""
    else
      "  " + repeatChar char (n - 1); # 2 spaces

  # create indentation string
  indent = depth: repeatChar " " depth;

  object = import ./object.nix { inherit lib indent camelToSnake; };
  plugin = import ./mk_plugin.nix {
    inherit
      lib
      customOptions
      camelToSnake
      config
      indent;
    inherit (object)
      toLuaObject;
  };
in {

  # exported functions
  inherit
    camelToSnake
    indent
    plugin
    object;
  inherit (object)
    toLuaObject'
    toLuaObject
    boolToInt
    boolToInt';
  inherit (plugin)
    convertModuleOptions
    defaultModuleOptions
    mkLuaPlugin;

}
