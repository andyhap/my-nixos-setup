{ lib, ... }:

{
  options.mySettings = {
    starshipTheme = lib.mkOption {
      type = lib.types.enum ["catppuccin" "bracketed"];
      description = "Pilih tema starship: catppuccin atau future.";
    };
  };
}
