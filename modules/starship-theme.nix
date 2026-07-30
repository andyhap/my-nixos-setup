{ lib, ... }:

{
  options.mySettings = {
    starshipTheme = lib.mkOption {
      type = lib.types.enum ["catppuccin" "future"];
      description = "Pilih tema starship: catppuccin atau future.";
    };
  };
}
